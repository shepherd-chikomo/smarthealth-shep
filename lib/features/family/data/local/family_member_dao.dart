import 'dart:convert';

import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/storage/app_database.dart';
import 'package:smarthealth_shep/shared/data/mock_data.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';
import 'package:sqflite/sqflite.dart';

/// Local SQLite CRUD for family members.
class FamilyMemberDao {
  FamilyMemberDao({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<Database> get _db => _database.database;

  Future<List<FamilyMemberModel>> getAll() async {
    await _ensureSeeded();
    final db = await _db;
    final rows = await db.query(
      'family_members',
      orderBy: 'is_primary DESC, name COLLATE NOCASE ASC',
    );
    return rows.map(_rowToModel).toList();
  }

  Future<FamilyMemberModel?> getById(String id) async {
    final db = await _db;
    final rows = await db.query(
      'family_members',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToModel(rows.first);
  }

  Future<void> insert(FamilyMemberModel member) async {
    final db = await _db;
    if (member.isPrimaryAccountHolder) {
      await _clearPrimaryFlags(db);
    }
    await db.insert(
      'family_members',
      _modelToRow(member),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(FamilyMemberModel member) async {
    final db = await _db;
    if (member.isPrimaryAccountHolder) {
      await _clearPrimaryFlags(db, exceptId: member.id);
    }
    await db.update(
      'family_members',
      _modelToRow(member),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('family_members', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _ensureSeeded() async {
    if (!AppConfig.seedMockDataOnEmpty) return;

    final db = await _db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM family_members'),
    );
    if ((count ?? 0) > 0) return;

    final batch = db.batch();
    for (final member in MockData.familyMembers) {
      batch.insert(
        'family_members',
        _modelToRow(member),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> _clearPrimaryFlags(Database db, {String? exceptId}) async {
    if (exceptId == null) {
      await db.update('family_members', {'is_primary': 0});
      return;
    }
    await db.update(
      'family_members',
      {'is_primary': 0},
      where: 'id != ?',
      whereArgs: [exceptId],
    );
  }

  FamilyMemberModel _rowToModel(Map<String, Object?> row) {
    final conditionsRaw = row['medical_conditions'] as String? ?? '[]';
    List<String> conditions;
    try {
      conditions = (jsonDecode(conditionsRaw) as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    } catch (_) {
      conditions = const [];
    }

    final genderRaw = row['gender'] as String?;
    FamilyGender? gender;
    if (genderRaw != null) {
      for (final value in FamilyGender.values) {
        if (value.name == genderRaw) {
          gender = value;
          break;
        }
      }
    }

    return FamilyMemberModel(
      id: row['id']! as String,
      name: row['name']! as String,
      relationship: row['relationship']! as String,
      dateOfBirth: row['date_of_birth'] as String?,
      gender: gender,
      medicalConditions: conditions,
      allergies: row['allergies'] as String?,
      isPrimaryAccountHolder: (row['is_primary'] as int? ?? 0) == 1,
    );
  }

  Map<String, Object?> _modelToRow(FamilyMemberModel member) {
    return {
      'id': member.id,
      'name': member.name,
      'relationship': member.relationship,
      'date_of_birth': member.dateOfBirth,
      'gender': member.gender?.name,
      'medical_conditions': jsonEncode(member.medicalConditions),
      'allergies': member.allergies,
      'is_primary': member.isPrimaryAccountHolder ? 1 : 0,
    };
  }
}
