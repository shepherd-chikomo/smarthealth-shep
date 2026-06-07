import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:smarthealth_shep/core/cloud/cloud_account_model.dart';
import 'package:smarthealth_shep/core/storage/app_database.dart';

class CloudAccountDao {
  static const _rowId = 'primary';

  Future<void> upsert(CloudAccount account) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'cloud_account',
      {
        'id': _rowId,
        'payload_json': jsonEncode(account.toJson()),
        'updated_at': account.updatedAt.toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<CloudAccount?> read() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'cloud_account',
      where: 'id = ?',
      whereArgs: [_rowId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final json =
        jsonDecode(rows.first['payload_json'] as String) as Map<String, dynamic>;
    return CloudAccount.fromJson(json);
  }

  Future<void> clear() async {
    final db = await AppDatabase.instance.database;
    await db.delete('cloud_account', where: 'id = ?', whereArgs: [_rowId]);
  }
}
