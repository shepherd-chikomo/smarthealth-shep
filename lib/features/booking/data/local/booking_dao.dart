import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:smarthealth_shep/core/storage/app_database.dart';
import 'package:smarthealth_shep/features/booking/models/booking_confirmation.dart';
import 'package:sqflite/sqflite.dart';

/// Persists booking drafts (offline) and confirmed appointments locally.
class BookingDao {
  BookingDao({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<Database> get _db => _database.database;

  Future<void> saveDraft({
    required String providerId,
    required DateTime date,
    required String time,
    required String patientId,
    String? notes,
  }) async {
    final db = await _db;
    final id = 'draft_${DateTime.now().millisecondsSinceEpoch}';
    await db.insert('booking_drafts', {
      'id': id,
      'provider_id': providerId,
      'data_json': jsonEncode({
        'providerId': providerId,
        'date': date.toIso8601String(),
        'time': time,
        'patientId': patientId,
        'notes': notes,
      }),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<BookingConfirmation> saveConfirmed(BookingConfirmation booking) async {
    final db = await _db;
    await db.insert('bookings', {
      'id': booking.referenceNumber,
      'reference': booking.referenceNumber,
      'data_json': jsonEncode({
        'referenceNumber': booking.referenceNumber,
        'providerId': booking.providerId,
        'providerName': booking.providerName,
        'facilityName': booking.facilityName,
        'date': booking.date.toIso8601String(),
        'time': booking.time,
        'durationMinutes': booking.durationMinutes,
        'patientName': booking.patientName,
        'notes': booking.notes,
      }),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    return booking;
  }

  /// Generates the next reference number: SH-YYYYMMDD-###.
  Future<String> nextReferenceNumber() async {
    final db = await _db;
    final todayKey = DateFormat('yyyyMMdd').format(DateTime.now());

    final rows = await db.query(
      'booking_ref_counter',
      where: 'date_key = ?',
      whereArgs: [todayKey],
      limit: 1,
    );

    final next = rows.isEmpty ? 1 : (rows.first['counter']! as int) + 1;

    await db.insert(
      'booking_ref_counter',
      {'date_key': todayKey, 'counter': next},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return 'SH-$todayKey-${next.toString().padLeft(3, '0')}';
  }
}
