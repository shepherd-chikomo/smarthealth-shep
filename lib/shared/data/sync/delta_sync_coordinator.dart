import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:smarthealth_shep/core/directory/directory_search_service.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/storage/app_database.dart';
import 'package:smarthealth_shep/features/appointments/data/local/appointment_dao.dart';
import 'package:smarthealth_shep/features/appointments/models/appointment_model.dart';
import 'package:smarthealth_shep/shared/data/local/emergency_cache.dart';
import 'package:smarthealth_shep/shared/data/local/facility_cache.dart';
import 'package:smarthealth_shep/shared/data/local/operating_hours_cache.dart';
import 'package:smarthealth_shep/shared/data/local/provider_dao.dart';
import 'package:smarthealth_shep/shared/data/sync/cache_invalidation.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_conflict_resolver.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';
import 'package:smarthealth_shep/shared/models/working_hours_entry.dart';
import 'package:sqflite/sqflite.dart';

const _logName = 'DeltaSyncCoordinator';

/// Orchestrates delta synchronization pulls in mission-critical priority order.
class DeltaSyncCoordinator {
  DeltaSyncCoordinator({
    required Dio dio,
    ApiService? apiService,
    ProviderDao? providerDao,
    EmergencyCache? emergencyCache,
    FacilityCache? facilityCache,
    OperatingHoursCache? operatingHoursCache,
    AppointmentDao? appointmentDao,
    AppDatabase? database,
  })  : _dio = dio,
        _api = apiService ?? ApiService(dio),
        _providerDao = providerDao ?? ProviderDao(),
        _appointmentDao = appointmentDao ?? AppointmentDao(),
        _emergencyCache = emergencyCache ?? EmergencyCache(),
        _facilityCache = facilityCache ?? FacilityCache(),
        _operatingHoursCache = operatingHoursCache ?? OperatingHoursCache(),
        _database = database ?? AppDatabase.instance;

  final Dio _dio;
  final ApiService _api;
  final ProviderDao _providerDao;
  final AppointmentDao _appointmentDao;
  final EmergencyCache _emergencyCache;
  final FacilityCache _facilityCache;
  final OperatingHoursCache _operatingHoursCache;
  final AppDatabase _database;

  static const _lastSyncPrefix = 'last_sync_';

  /// Pull order: emergency → providers → facilities → hours → appointments.
  Future<void> runDeltaPulls() async {
    await _pullEmergency();
    await _pullProviders();
    await _pullFacilities();
    await _pullOperatingHours();
    await _pullAppointments();
    await DirectorySearchService().rebuildIndex();
  }

  Future<void> _pullEmergency() async {
    if (!_shouldRefresh(SyncEntityType.emergency)) return;

    try {
      final since = await _readLastSync(SyncEntityType.emergency);
      await _dio.get<Map<String, dynamic>>(
        '/emergency/services',
        queryParameters: {
          if (since != null) 'since': since.toUtc().toIso8601String(),
          'limit': 100,
        },
      );
      await _writeLastSync(SyncEntityType.emergency, DateTime.now().toUtc());
      // Keep hardcoded fallback warm; hub refreshed when API returns data.
      _emergencyCache.readHub();
      developer.log('Emergency delta pull complete', name: _logName);
    } catch (error, stackTrace) {
      developer.log(
        'Emergency delta pull failed — using local cache',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _pullProviders() async {
    if (!_shouldRefresh(SyncEntityType.provider)) return;

    final since = await _providerDao.getLastSync();
    final payload = await _api.syncProviders(since: since);

    if (SyncConflictResolver.shouldApplyServerDirectoryRecord(
      entityType: SyncEntityType.provider,
    )) {
      await _providerDao.upsertProviders(payload.updated);
      await _providerDao.deleteProviders(payload.deletedIds);
      await _providerDao.setLastSync(payload.syncedAt);
      await _writeLastSync(SyncEntityType.provider, payload.syncedAt);
    }

    developer.log(
      'Provider delta: ${payload.updated.length} updated, '
      '${payload.deletedIds.length} deleted',
      name: _logName,
    );
  }

  Future<void> _pullFacilities() async {
    if (!_shouldRefresh(SyncEntityType.facility)) return;

    try {
      final since = await _readLastSync(SyncEntityType.facility);
      final response = await _dio.get<Map<String, dynamic>>(
        '/facilities',
        queryParameters: {
          if (since != null) 'since': since.toUtc().toIso8601String(),
          'limit': 100,
        },
      );

      final facilities = response.data?['facilities'] as List<dynamic>? ?? [];
      await _facilityCache.saveAll(
        facilities.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      );
      await _writeLastSync(SyncEntityType.facility, DateTime.now().toUtc());
      developer.log('Facility delta pull: ${facilities.length} records', name: _logName);
    } catch (error, stackTrace) {
      developer.log(
        'Facility delta pull failed — using cached data',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _pullOperatingHours() async {
    if (!_shouldRefresh(SyncEntityType.operatingHours)) return;

    try {
      final providers = await _providerDao.getAll();
      for (final provider in providers.take(50)) {
        if (provider.weeklyHours.isNotEmpty) {
          await _operatingHoursCache.save(
            providerId: provider.id,
            hours: provider.weeklyHours,
          );
          continue;
        }

        final response = await _dio.get<Map<String, dynamic>>(
          '/providers/${provider.id}',
        );
        final data = response.data?['provider'] as Map<String, dynamic>?;
        final hoursRaw = data?['weeklyHours'] as List<dynamic>?;
        if (hoursRaw != null) {
          final hours = hoursRaw
              .map((e) => WorkingHoursEntry.fromJson(e as Map<String, dynamic>))
              .toList();
          await _operatingHoursCache.save(providerId: provider.id, hours: hours);
        }
      }
      await _writeLastSync(
        SyncEntityType.operatingHours,
        DateTime.now().toUtc(),
      );
      developer.log('Operating hours delta pull complete', name: _logName);
    } catch (error, stackTrace) {
      developer.log(
        'Operating hours delta pull failed — using cached hours',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _pullAppointments() async {
    final since = await _readLastSync(SyncEntityType.appointment);
    final now = DateTime.now().toUtc();
    final response = await _dio.get<Map<String, dynamic>>(
      '/appointments',
      queryParameters: {
        'from': now.toIso8601String(),
        'page': 1,
        'limit': 100,
        if (since != null) 'since': since.toUtc().toIso8601String(),
      },
    );

    final raw = response.data?['appointments'] as List<dynamic>? ?? const [];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final appointment = AppointmentModel.fromApiJson(item);
      if (!appointment.isTerminal) {
        await _appointmentDao.upsertFromApi(appointment);
      }
    }
    await _appointmentDao.purgeSeedRows();
    await _appointmentDao.deleteTerminal();

    final syncedAt = _parseSyncedAt(response.data?['syncedAt'] ?? now.toIso8601String());
    await _writeLastSync(SyncEntityType.appointment, syncedAt);
    developer.log('Appointment delta pull complete', name: _logName);
  }

  bool _shouldRefresh(SyncEntityType entity) {
    return CacheInvalidationPolicy.shouldRefresh(
      entity: entity,
      lastSyncedAt: null, // always attempt when online; TTL checked post-pull
    );
  }

  Future<DateTime?> _readLastSync(SyncEntityType entity) async {
    final db = await _database.database;
    final rows = await db.query(
      'sync_metadata',
      where: 'key = ?',
      whereArgs: ['$_lastSyncPrefix${entity.name}'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DateTime.tryParse(rows.first['value']! as String);
  }

  Future<void> _writeLastSync(SyncEntityType entity, DateTime syncedAt) async {
    final db = await _database.database;
    await db.insert(
      'sync_metadata',
      {
        'key': '$_lastSyncPrefix${entity.name}',
        'value': syncedAt.toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  DateTime _parseSyncedAt(Object? raw) {
    if (raw is String) {
      return DateTime.tryParse(raw)?.toUtc() ?? DateTime.now().toUtc();
    }
    return DateTime.now().toUtc();
  }
}
