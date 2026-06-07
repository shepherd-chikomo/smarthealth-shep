import 'package:sqflite/sqflite.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_crypto.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_models.dart';
import 'package:smarthealth_shep/core/storage/app_database.dart';

class HealthVaultDao {
  HealthVaultDao({HealthVaultCrypto? crypto})
      : _crypto = crypto ?? HealthVaultCrypto();

  final HealthVaultCrypto _crypto;

  Future<void> upsert(HealthVaultRecord record) async {
    final db = await AppDatabase.instance.database;
    final envelope = await _crypto.encryptJson(record.toJson());
    await db.insert(
      'health_vault',
      {
        'subject_id': record.subjectId,
        'encrypted_payload': envelope,
        'updated_at': record.updatedAt.toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<HealthVaultRecord?> getBySubject(String subjectId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'health_vault',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final envelope = rows.first['encrypted_payload'] as String;
    final json = await _crypto.decryptJson(envelope);
    return HealthVaultRecord.fromJson(json);
  }

  Future<List<HealthVaultRecord>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('health_vault', orderBy: 'updated_at DESC');
    final records = <HealthVaultRecord>[];
    for (final row in rows) {
      final envelope = row['encrypted_payload'] as String;
      final json = await _crypto.decryptJson(envelope);
      records.add(HealthVaultRecord.fromJson(json));
    }
    return records;
  }

  Future<void> deleteSubject(String subjectId) async {
    final db = await AppDatabase.instance.database;
    await db.delete(
      'health_vault',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );
  }

  Future<void> wipeAll() async {
    final db = await AppDatabase.instance.database;
    await db.delete('health_vault');
    await _crypto.wipeKey();
  }
}
