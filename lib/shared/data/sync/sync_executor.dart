import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/storage/app_database.dart';
import 'package:smarthealth_shep/shared/data/local/provider_dao.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_conflict_resolver.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';
import 'package:sqflite/sqflite.dart';

const _logName = 'SyncExecutor';

/// Applies queued mutations and delta pulls against the remote API.
class SyncExecutor {
  SyncExecutor({
    required Dio dio,
    ApiService? apiService,
    ProviderDao? providerDao,
    AppDatabase? database,
    this.baseUrl = 'https://api.smarthealth.example/v1',
  })  : _dio = dio,
        _api = apiService ?? ApiService(dio, baseUrl: baseUrl),
        _providerDao = providerDao ?? ProviderDao(),
        _database = database ?? AppDatabase.instance;

  final Dio _dio;
  final ApiService _api;
  final ProviderDao _providerDao;
  final AppDatabase _database;
  final String baseUrl;

  static const _lastSyncPrefix = 'last_sync_';

  Future<Database> get _db => _database.database;

  /// Runs delta sync pulls in priority order (server wins for directory data).
  Future<void> runDeltaPulls() async {
    await _pullEmergency();
    await _pullProviders();
    await _pullAppointments();
  }

  Future<void> processQueueItem(SyncQueueItem item) async {
    developer.log(
      'Processing ${item.mutationType.label} ${item.entityType.name}/${item.entityId}',
      name: _logName,
    );

    switch (item.entityType) {
      case SyncEntityType.family:
        await _pushFamilyMutation(item);
      case SyncEntityType.appointment:
        await _pushAppointmentMutation(item);
      case SyncEntityType.provider:
        await _pushProviderMutation(item);
      case SyncEntityType.emergency:
        await _pushEmergencyMutation(item);
    }
  }

  Future<void> _pullEmergency() async {
    final since = await _readLastSync(SyncEntityType.emergency);
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/emergency/sync',
      queryParameters: {
        if (since != null) 'since': since.toUtc().toIso8601String(),
      },
    );

    final data = response.data ?? {};
    final syncedAt = _parseSyncedAt(data['syncedAt']);
    await _writeLastSync(SyncEntityType.emergency, syncedAt);
    developer.log('Emergency delta pull complete', name: _logName);
  }

  Future<void> _pullProviders() async {
    final since = await _providerDao.getLastSync();
    final payload = await _api.syncProviders(since: since);

    if (SyncConflictResolver.shouldApplyServerDirectoryRecord(
      entityType: SyncEntityType.provider,
    )) {
      await _providerDao.upsertProviders(payload.updated);
      await _providerDao.deleteProviders(payload.deletedIds);
      await _providerDao.setLastSync(payload.syncedAt);
    }

    developer.log(
      'Provider delta pull: ${payload.updated.length} updated, '
      '${payload.deletedIds.length} deleted',
      name: _logName,
    );
  }

  Future<void> _pullAppointments() async {
    final since = await _readLastSync(SyncEntityType.appointment);
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/appointments/sync',
      queryParameters: {
        if (since != null) 'since': since.toUtc().toIso8601String(),
      },
    );

    final data = response.data ?? {};
    final syncedAt = _parseSyncedAt(data['syncedAt']);
    await _writeLastSync(SyncEntityType.appointment, syncedAt);
    developer.log('Appointment delta pull complete', name: _logName);
  }

  Future<void> _pushFamilyMutation(SyncQueueItem item) async {
    final path = '$baseUrl/family/${item.entityId}';

    switch (item.mutationType) {
      case SyncMutationType.create:
      case SyncMutationType.update:
        final response = await _dio.put<Map<String, dynamic>>(
          path,
          data: item.payload,
        );
        await _resolveUserDataConflict(
          item: item,
          serverBody: response.data,
        );
      case SyncMutationType.delete:
        await _dio.delete<void>(path);
    }
  }

  Future<void> _pushAppointmentMutation(SyncQueueItem item) async {
    final path = '$baseUrl/appointments/${item.entityId}';

    switch (item.mutationType) {
      case SyncMutationType.create:
      case SyncMutationType.update:
        final response = await _dio.post<Map<String, dynamic>>(
          path,
          data: item.payload,
        );
        await _resolveUserDataConflict(
          item: item,
          serverBody: response.data,
        );
      case SyncMutationType.delete:
        await _dio.delete<void>(path);
    }
  }

  Future<void> _pushProviderMutation(SyncQueueItem item) async {
    final path = '$baseUrl/providers/${item.entityId}';
    switch (item.mutationType) {
      case SyncMutationType.create:
      case SyncMutationType.update:
        await _dio.put<Map<String, dynamic>>(path, data: item.payload);
      case SyncMutationType.delete:
        await _dio.delete<void>(path);
    }
  }

  Future<void> _pushEmergencyMutation(SyncQueueItem item) async {
    final path = '$baseUrl/emergency/${item.entityId}';
    switch (item.mutationType) {
      case SyncMutationType.create:
      case SyncMutationType.update:
        await _dio.put<Map<String, dynamic>>(path, data: item.payload);
      case SyncMutationType.delete:
        await _dio.delete<void>(path);
    }
  }

  Future<void> _resolveUserDataConflict({
    required SyncQueueItem item,
    required Map<String, dynamic>? serverBody,
  }) async {
    if (serverBody == null) return;

    final serverUpdatedRaw = serverBody['updatedAt'] as String?;
    final serverUpdated = serverUpdatedRaw != null
        ? DateTime.tryParse(serverUpdatedRaw)?.toUtc()
        : null;

    final applyLocal = SyncConflictResolver.shouldApplyLocalMutation(
      entityType: item.entityType,
      clientUpdatedAt: item.clientUpdatedAt,
      serverUpdatedAt: serverUpdated,
    );

    if (!applyLocal) {
      developer.log(
        'Server wins LWW for ${item.entityType.name}/${item.entityId}',
        name: _logName,
      );
    }
  }

  Future<DateTime?> _readLastSync(SyncEntityType entity) async {
    final db = await _db;
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
    final db = await _db;
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
