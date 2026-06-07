import 'dart:convert';

import 'package:smarthealth_shep/core/storage/app_database.dart';
import 'package:smarthealth_shep/features/appointments/models/appointment_model.dart';
import 'package:sqflite/sqflite.dart';

/// Reads and updates persisted appointments in the shared bookings table.
class AppointmentDao {
  AppointmentDao({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<Database> get _db => _database.database;

  Future<List<AppointmentModel>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      'bookings',
      orderBy: 'created_at DESC',
    );
    return rows.map(_rowToModel).toList();
  }

  Future<AppointmentModel?> getById(String id) async {
    final db = await _db;
    final rows = await db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToModel(rows.first);
  }

  Future<void> save(AppointmentModel appointment) async {
    final db = await _db;
    final now = DateTime.now().toUtc();
    final json = appointment.copyWith(updatedAt: now).toJson();
    await db.insert(
      'bookings',
      {
        'id': appointment.id,
        'reference': appointment.referenceNumber,
        'data_json': jsonEncode(json),
        'created_at': now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveAll(List<AppointmentModel> appointments) async {
    for (final appointment in appointments) {
      await save(appointment);
    }
  }

  Future<void> update(AppointmentModel appointment) async {
    await save(appointment);
  }

  Future<bool> isEmpty() async {
    final db = await _db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM bookings'),
    );
    return (count ?? 0) == 0;
  }

  Future<void> purgeSeedRows() async {
    final db = await _db;
    await db.delete(
      'bookings',
      where: "id LIKE 'appt_seed_%' OR reference LIKE 'SH-SEED-%'",
    );
  }

  Future<void> deleteTerminal() async {
    final db = await _db;
    final all = await getAll();
    for (final appointment in all) {
      if (appointment.isTerminal) {
        await db.delete(
          'bookings',
          where: 'id = ?',
          whereArgs: [appointment.id],
        );
      }
    }
  }

  Future<void> upsertFromApi(AppointmentModel appointment) async {
    final existing = await getById(appointment.id);
    if (existing != null) {
      final merged = existing.copyWith(
        referenceNumber: appointment.referenceNumber,
        providerId: appointment.providerId,
        providerName: appointment.providerName,
        facilityName: appointment.facilityName,
        scheduledAt: appointment.scheduledAt,
        durationMinutes: appointment.durationMinutes,
        patientId: appointment.patientId,
        status: appointment.status,
        notes: appointment.notes,
        syncStatus: 'synced',
        updatedAt: appointment.updatedAt,
      );
      await save(merged);
      return;
    }
    await save(appointment);
  }

  AppointmentModel _rowToModel(Map<String, Object?> row) {
    final json =
        jsonDecode(row['data_json']! as String) as Map<String, dynamic>;
    json['id'] ??= row['id'];
    json['referenceNumber'] ??= row['reference'];
    return AppointmentModel.fromJson(json);
  }
}
