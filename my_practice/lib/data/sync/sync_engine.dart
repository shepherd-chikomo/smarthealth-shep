import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/remote/facility_api_client.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class SyncEngine {
  SyncEngine({
    required AppDatabase db,
    required SyncApiClient api,
    Connectivity? connectivity,
  })  : _db = db,
        _api = api,
        _connectivity = connectivity ?? Connectivity();

  final AppDatabase _db;
  final SyncApiClient _api;
  final Connectivity _connectivity;

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<int> pendingCount() async {
    return (await _db.select(_db.syncQueue).get()).length;
  }

  Future<void> syncAll(String facilityId) async {
    if (!await isOnline) return;
    await flushQueue();
    await bootstrap(facilityId);
    await pullDelta(facilityId);
    await flushQueue();
  }

  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    await _db.into(_db.syncQueue).insert(
          SyncQueueCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payloadJson: jsonEncode(payload),
            createdAt: DateTime.now().toUtc(),
          ),
        );
    if (await isOnline) {
      await flushQueue();
    }
  }

  Future<void> flushQueue() async {
    if (!await isOnline) return;

    final pending = await (_db.select(_db.syncQueue)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    if (pending.isEmpty) return;

    final mutations = pending
        .map(
          (item) => {
            'entityType': item.entityType,
            'entityId': item.entityId,
            'operation': item.operation,
            'payload': jsonDecode(item.payloadJson),
          },
        )
        .toList();

    try {
      await _api.pushMutations(mutations);
      for (final item in pending) {
        await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(item.id)))
            .go();
      }
    } on DioException {
      // Retry on next connectivity event.
    }
  }

  Future<void> pullDelta(String facilityId) async {
    if (!await isOnline) return;

    final cursor = await (_db.select(_db.syncCursors)
          ..where(
            (t) =>
                t.entityType.equals('all') & t.facilityId.equals(facilityId),
          ))
        .getSingleOrNull();

    final since =
        cursor?.lastSyncedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final delta = await _api.delta(since);
    final now = DateTime.now().toUtc();

    await _applyAppointments(
      delta['appointments'] as List<dynamic>? ?? [],
      facilityId,
      now,
    );
    await _applyQueue(
      delta['queue'] as List<dynamic>? ?? [],
      facilityId,
      now,
    );
    await _applyPatients(delta['patients'] as List<dynamic>? ?? [], now);

    await _db.into(_db.syncCursors).insertOnConflictUpdate(
          SyncCursorsCompanion.insert(
            entityType: 'all',
            facilityId: facilityId,
            lastSyncedAt: now,
          ),
        );
  }

  Future<void> bootstrap(String facilityId) async {
    if (!await isOnline) return;
    final data = await _api.bootstrap();
    final now = DateTime.now().toUtc();

    await _applyQueue(data['queue'] as List<dynamic>? ?? [], facilityId, now);
    await _applyAppointments(
      data['appointments'] as List<dynamic>? ?? [],
      facilityId,
      now,
    );
    await _applyPatients(data['patients'] as List<dynamic>? ?? [], now);
  }

  Future<void> _applyQueue(
    List<dynamic> items,
    String facilityId,
    DateTime now,
  ) async {
    for (final raw in items) {
      final m = raw as Map<String, dynamic>;
      await _db.into(_db.queueEntries).insertOnConflictUpdate(
            QueueEntriesCompanion.insert(
              id: m['id'] as String? ?? _uuid.v4(),
              serverId: Value(m['id'] as String?),
              facilityId: facilityId,
              patientId: m['patientId'] as String? ?? 'unknown',
              status: m['status'] as String? ?? 'waiting',
              arrivedAt: DateTime.tryParse(m['arrivedAt'] as String? ?? '') ??
                  now,
              updatedAt: now,
              position: Value(m['position'] as int? ?? 0),
              triageStatus: Value(m['triageStatus'] as String?),
              syncStatus: const Value('synced'),
            ),
          );
    }
  }

  Future<void> _applyAppointments(
    List<dynamic> items,
    String facilityId,
    DateTime now,
  ) async {
    for (final raw in items) {
      final m = raw as Map<String, dynamic>;
      await _db.into(_db.appointments).insertOnConflictUpdate(
            AppointmentsCompanion.insert(
              id: m['id'] as String,
              serverId: Value(m['id'] as String),
              facilityId: facilityId,
              patientId: m['patientId'] as String? ?? 'unknown',
              status: m['status'] as String? ?? 'pending',
              scheduledAt: DateTime.parse(m['scheduledAt'] as String),
              updatedAt: now,
              providerId: Value(m['providerId'] as String?),
              referenceNumber: Value(m['referenceNumber'] as String?),
              appointmentType: Value(m['appointmentType'] as String?),
              syncStatus: const Value('synced'),
            ),
          );
    }
  }

  Future<void> _applyPatients(List<dynamic> items, DateTime now) async {
    for (final raw in items) {
      if (raw is! Map<String, dynamic>) continue;
      final m = raw;
      final id = m['id'] as String?;
      if (id == null || id.isEmpty) continue;
      final metadata = m['metadata'];
      final metaMap = metadata is Map<String, dynamic> ? metadata : null;
      final insuranceRaw =
          m['insuranceInfo'] ?? m['insurance_info'] ?? metaMap?['medicalAid'];
      await _db.into(_db.patients).insertOnConflictUpdate(
            PatientsCompanion.insert(
              id: id,
              serverId: Value(id),
              firstName:
                  m['firstName'] as String? ?? m['first_name'] as String? ?? '',
              lastName:
                  m['lastName'] as String? ?? m['last_name'] as String? ?? '',
              phone: Value(m['phone'] as String?),
              email: Value(m['email'] as String?),
              nationalId: Value(
                m['nationalId'] as String? ?? m['national_id'] as String?,
              ),
              smarthealthPatientId: Value(
                m['smarthealthPatientId'] as String? ??
                    metaMap?['smarthealthPatientId'] as String?,
              ),
              gender: Value(m['gender'] as String?),
              dateOfBirth: Value(
                m['dateOfBirth'] != null
                    ? DateTime.tryParse(m['dateOfBirth'] as String)
                    : m['date_of_birth'] != null
                        ? DateTime.tryParse(m['date_of_birth'] as String)
                        : null,
              ),
              insuranceInfo: Value(insuranceRaw?.toString()),
              updatedAt: now,
              syncStatus: const Value('synced'),
            ),
          );
    }
  }
}
