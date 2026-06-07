import 'dart:convert';

import 'package:smarthealth_shep/core/storage/app_database.dart';

/// Local audit trail for health data sharing and sensitive actions.
class AuditLog {
  Future<void> record({
    required String action,
    String? subjectId,
    Map<String, Object?> details = const {},
  }) async {
    final db = await AppDatabase.instance.database;
    await db.insert('audit_log', {
      'id': 'audit_${DateTime.now().microsecondsSinceEpoch}',
      'action': action,
      'subject_id': subjectId,
      'details_json': jsonEncode(details),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<List<Map<String, Object?>>> recent({int limit = 50}) async {
    final db = await AppDatabase.instance.database;
    return db.query(
      'audit_log',
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  Future<void> wipe() async {
    final db = await AppDatabase.instance.database;
    await db.delete('audit_log');
  }
}
