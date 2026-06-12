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

    final since = cursor?.lastSyncedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final delta = await _api.delta(since);
    final now = DateTime.now().toUtc();

    await _db.into(_db.syncCursors).insertOnConflictUpdate(
          SyncCursorsCompanion.insert(
            entityType: 'all',
            facilityId: facilityId,
            lastSyncedAt: now,
          ),
        );

    // Apply delta payloads — simplified merge for bootstrap entities.
    final appointments = delta['appointments'] as List<dynamic>? ?? [];
    for (final raw in appointments) {
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
            ),
          );
    }
  }

  Future<void> bootstrap(String facilityId) async {
    if (!await isOnline) return;
    final data = await _api.bootstrap();
    final now = DateTime.now().toUtc();

    final queue = data['queue'] as List<dynamic>? ?? [];
    for (final raw in queue) {
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
            ),
          );
    }

    await pullDelta(facilityId);
  }
}
