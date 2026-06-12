import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:smarthealth_core/smarthealth_core.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class AuditService {
  AuditService(this._db);

  final AppDatabase _db;

  Future<void> record({
    required String action,
    String? subjectId,
    String? facilityId,
    String? providerId,
    Map<String, Object?> details = const {},
  }) async {
    final entry = AuditLogEntry(
      id: _uuid.v4(),
      action: action,
      createdAt: DateTime.now().toUtc(),
      subjectId: subjectId,
      facilityId: facilityId,
      providerId: providerId,
      details: details,
    );

    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion.insert(
            id: entry.id,
            action: entry.action,
            subjectId: Value(entry.subjectId),
            facilityId: Value(entry.facilityId),
            providerId: Value(entry.providerId),
            detailsJson: Value(jsonEncode(entry.details)),
            createdAt: entry.createdAt,
          ),
        );
  }

  Future<void> flushToServer(
    Future<void> Function(List<AuditLogEntry> batch) upload,
  ) async {
    final pending = await (_db.select(_db.auditLogs)
          ..where((t) => t.synced.equals(false)))
        .get();

    if (pending.isEmpty) return;

    final batch = pending
        .map(
          (r) => AuditLogEntry(
            id: r.id,
            action: r.action,
            createdAt: r.createdAt,
            subjectId: r.subjectId,
            facilityId: r.facilityId,
            providerId: r.providerId,
            details: jsonDecode(r.detailsJson) as Map<String, Object?>,
          ),
        )
        .toList();

    await upload(batch);

    for (final row in pending) {
      await (_db.update(_db.auditLogs)..where((t) => t.id.equals(row.id)))
          .write(const AuditLogsCompanion(synced: Value(true)));
    }
  }
}
