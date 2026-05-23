import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:smarthealth_shep/core/exceptions/network_exception.dart';
import 'package:smarthealth_shep/features/booking/data/local/booking_dao.dart';
import 'package:smarthealth_shep/features/family/data/local/family_member_dao.dart';
import 'package:smarthealth_shep/features/booking/models/booking_confirmation.dart';
import 'package:smarthealth_shep/features/booking/models/patient_option.dart';
import 'package:smarthealth_shep/features/booking/models/time_slot.dart';
import 'package:smarthealth_shep/shared/data/local/provider_dao.dart';
import 'package:smarthealth_shep/shared/data/mock_data.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

const _logName = 'BookingRepository';
const _defaultDurationMinutes = 30;

/// Availability, patient list, and booking submission for the booking flow.
class BookingRepository {
  BookingRepository({
    ProviderDao? providerDao,
    FamilyMemberDao? familyMemberDao,
    BookingDao? bookingDao,
    Connectivity? connectivity,
  })  : _providerDao = providerDao ?? ProviderDao(),
        _familyDao = familyMemberDao ?? FamilyMemberDao(),
        _bookingDao = bookingDao ?? BookingDao(),
        _connectivity = connectivity ?? Connectivity();

  final ProviderDao _providerDao;
  final FamilyMemberDao _familyDao;
  final BookingDao _bookingDao;
  final Connectivity _connectivity;

  static const slotTimes = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
  ];

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<ProviderModel?> getProvider(String providerId) async {
    final local = await _providerDao.getById(providerId);
    if (local != null) return local;

    for (final provider in MockData.providers) {
      if (provider.id == providerId) return provider;
    }
    return null;
  }

  /// Weekdays within the next [daysAhead] days that accept bookings.
  List<DateTime> availableDates({int daysAhead = 60}) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final dates = <DateTime>[];

    for (var i = 0; i <= daysAhead; i++) {
      final day = start.add(Duration(days: i));
      if (day.weekday == DateTime.sunday) continue;
      dates.add(day);
    }
    return dates;
  }

  bool isDateAvailable(DateTime day, List<DateTime> availableDates) {
    final normalized = DateTime(day.year, day.month, day.day);
    return availableDates.any(
      (d) =>
          d.year == normalized.year &&
          d.month == normalized.month &&
          d.day == normalized.day,
    );
  }

  Future<List<TimeSlot>> getTimeSlots(String providerId, DateTime date) async {
    developer.log(
      'Generating slots for $providerId on ${date.toIso8601String()}',
      name: _logName,
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));

    final seed = providerId.hashCode + date.day + date.month * 31;
    return slotTimes.map((time) {
      final index = slotTimes.indexOf(time);
      final lunchBlock = time == '12:00' || time == '12:30';
      final pseudoRandom = (seed + index * 7) % 5 == 0;
      return TimeSlot(
        time: time,
        isAvailable: !lunchBlock && !pseudoRandom,
      );
    }).toList();
  }

  Future<List<PatientOption>> getPatients() async {
    final members = await _familyDao.getAll();
    return [
      PatientOption.self,
      ...members.map(
        (m) => PatientOption(
          id: m.id,
          name: m.name,
          relationship: m.relationship,
        ),
      ),
    ];
  }

  PatientOption? findPatient(List<PatientOption> patients, String id) {
    for (final patient in patients) {
      if (patient.id == id) return patient;
    }
    return null;
  }

  Future<BookingConfirmation> confirmBooking({
    required ProviderModel provider,
    required DateTime date,
    required String time,
    required PatientOption patient,
    String? notes,
  }) async {
    if (!await isOnline()) {
      throw const NetworkException('Booking requires internet');
    }

    developer.log('Submitting booking to API', name: _logName);
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final reference = await _bookingDao.nextReferenceNumber();
    final confirmation = BookingConfirmation(
      referenceNumber: reference,
      providerId: provider.id,
      providerName: provider.name,
      facilityName: provider.facilityName ?? provider.name,
      date: DateTime(date.year, date.month, date.day),
      time: time,
      durationMinutes: _defaultDurationMinutes,
      patientName: patient.name,
      notes: notes?.trim().isEmpty ?? true ? null : notes?.trim(),
    );

    return _bookingDao.saveConfirmed(confirmation);
  }

  Future<void> saveDraft({
    required String providerId,
    required DateTime date,
    required String time,
    required String patientId,
    String? notes,
  }) async {
    developer.log('Saving booking draft locally', name: _logName);
    await _bookingDao.saveDraft(
      providerId: providerId,
      date: date,
      time: time,
      patientId: patientId,
      notes: notes,
    );
  }
}
