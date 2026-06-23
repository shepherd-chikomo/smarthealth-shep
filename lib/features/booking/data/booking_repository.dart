import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/exceptions/network_exception.dart';
import 'package:smarthealth_shep/features/appointments/data/appointments_repository.dart';
import 'package:smarthealth_shep/features/booking/data/local/booking_dao.dart';
import 'package:smarthealth_shep/features/family/data/local/family_member_dao.dart';
import 'package:smarthealth_shep/features/booking/models/booking_confirmation.dart';
import 'package:smarthealth_shep/features/booking/models/booking_consent_options.dart';
import 'package:smarthealth_shep/features/booking/models/patient_option.dart';
import 'package:smarthealth_shep/features/booking/models/time_slot.dart';
import 'package:smarthealth_shep/shared/data/local/provider_dao.dart';
import 'package:smarthealth_shep/shared/data/mock_data.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_service.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

const _logName = 'BookingRepository';
const _defaultDurationMinutes = 30;

/// Result of booking confirmation including offline sync status.
class BookingResult {
  const BookingResult({
    required this.confirmation,
    required this.isPendingSync,
    required this.localId,
  });

  final BookingConfirmation confirmation;
  final bool isPendingSync;
  final String localId;
}

/// Availability, patient list, and offline-first booking submission.
class BookingRepository {
  BookingRepository({
    ProviderDao? providerDao,
    FamilyMemberDao? familyMemberDao,
    BookingDao? bookingDao,
    SyncService? syncService,
    Connectivity? connectivity,
    AppointmentsRepository? appointmentsRepository,
    ApiService? api,
  })  : _providerDao = providerDao ?? ProviderDao(),
        _familyDao = familyMemberDao ?? FamilyMemberDao(),
        _bookingDao = bookingDao ?? BookingDao(),
        _appointmentsRepository =
            appointmentsRepository ?? AppointmentsRepository(),
        _syncService = syncService ?? SyncService.instance ?? SyncService.forBackground(),
        _connectivity = connectivity ?? Connectivity(),
        _api = api ?? ApiService(createApiDio());

  final ProviderDao _providerDao;
  final FamilyMemberDao _familyDao;
  final BookingDao _bookingDao;
  final AppointmentsRepository _appointmentsRepository;
  final SyncService _syncService;
  final Connectivity _connectivity;
  final ApiService _api;

  static const slotTimes = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '12:00', '12:30', '13:00', '13:30',
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
  ];

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<ProviderModel?> getProvider(String providerId) async {
    final local = await _providerDao.getById(providerId);
    if (local != null) return local;

    if (await isOnline()) {
      try {
        final remote = await _api.getProviderById(providerId);
        if (remote != null) return remote;
      } catch (error, stackTrace) {
        developer.log(
          'Remote provider fetch failed',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (AppConfig.allowMockFallbacks) {
      for (final provider in MockData.providers) {
        if (provider.id == providerId) return provider;
      }
    }
    return null;
  }

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

  Future<List<TimeSlot>> getTimeSlots(
    String providerId,
    DateTime date, {
    String? facilityId,
    String? serviceId,
  }) async {
    if (facilityId != null && await isOnline()) {
      try {
        final days = await _api.fetchFacilityAvailability(
          facilityId,
          serviceId: serviceId,
          days: 14,
        );
        final key = '${date.year.toString().padLeft(4, '0')}-'
            '${date.month.toString().padLeft(2, '0')}-'
            '${date.day.toString().padLeft(2, '0')}';
        for (final day in days) {
          if (day.date != key) continue;
          return day.slots
              .where((slot) => slot.providerId == providerId)
              .map((slot) => TimeSlot(time: slot.time, isAvailable: true))
              .toList();
        }
        return const [];
      } catch (error, stackTrace) {
        developer.log(
          'Remote slot fetch failed, using fallback',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

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

  /// Confirms booking: saves locally, then POSTs to server when online.
  Future<BookingResult> confirmBooking({
    required ProviderModel provider,
    required DateTime date,
    required String time,
    required PatientOption patient,
    String? notes,
    String? facilityId,
    String? serviceId,
    BookingConsentOptions? consent,
    Map<String, dynamic>? profileSnapshot,
  }) async {
    final localId = 'appt_${DateTime.now().millisecondsSinceEpoch}';
    final reference = await _bookingDao.nextReferenceNumber();
    final now = DateTime.now().toUtc();

    final scheduledAt = _combineDateTime(date, time);
    final resolvedFacilityId = await _resolveFacilityId(
      provider: provider,
      facilityId: facilityId,
    );
    if (resolvedFacilityId == null) {
      throw StateError(
        'Could not determine the facility for this booking. '
        'Please go back and try again from the facility page.',
      );
    }

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

    await _bookingDao.saveConfirmed(
      confirmation,
      localId: localId,
      syncStatus: 'pending',
      updatedAt: now,
    );

    await _appointmentsRepository.saveFromBooking(
      booking: confirmation,
      localId: localId,
      provider: provider,
    );

    final online = await isOnline();

    final bookingConsent = consent ?? const BookingConsentOptions();

    if (online) {
      try {
        developer.log('Submitting booking online', name: _logName);
        final serverAppointment = await _api.createAppointment(
          facilityId: resolvedFacilityId,
          providerId: provider.id,
          scheduledAt: scheduledAt,
          durationMinutes: _defaultDurationMinutes,
          serviceId: serviceId,
          familyMemberId:
              patient.id != PatientOption.selfId ? patient.id : null,
          notes: confirmation.notes,
          paymentMethod: bookingConsent.paymentMethod.apiValue,
          shareProfile: bookingConsent.toShareProfileFlags(),
          sharedProfileSnapshot: profileSnapshot,
          receiveEncounterSummary: bookingConsent.receiveEncounterSummary,
          enableOngoingCare: bookingConsent.enableOngoingCare,
        );
        await _appointmentsRepository.replaceLocalWithServer(
          localId: localId,
          serverAppointment: serverAppointment,
        );
        final serverReference =
            serverAppointment['referenceNumber'] as String? ?? reference;
        final serverId = serverAppointment['id'] as String? ?? localId;
        return BookingResult(
          confirmation: BookingConfirmation(
            referenceNumber: serverReference,
            providerId: confirmation.providerId,
            providerName: confirmation.providerName,
            facilityName: confirmation.facilityName,
            date: confirmation.date,
            time: confirmation.time,
            durationMinutes: confirmation.durationMinutes,
            patientName: confirmation.patientName,
            notes: confirmation.notes,
          ),
          isPendingSync: false,
          localId: serverId,
        );
      } on NetworkException catch (error) {
        developer.log(
          'Online submit failed',
          name: _logName,
          error: error,
        );
        throw StateError(
          'Could not confirm booking with the server. Please try again.',
        );
      } on DioException catch (error) {
        final message = _bookingErrorMessage(error);
        developer.log(
          'Booking API rejected: $message',
          name: _logName,
          error: error,
        );
        throw StateError(message);
      } catch (error, stackTrace) {
        developer.log(
          'Booking sync failed',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
        );
        throw StateError('Could not confirm booking with the server. Please try again.');
      }
    }

    final payload = <String, dynamic>{
      'facilityId': resolvedFacilityId,
      'providerId': provider.id,
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      'durationMinutes': _defaultDurationMinutes,
    };
    if (serviceId != null) payload['serviceId'] = serviceId;
    if (patient.id != PatientOption.selfId) {
      payload['familyMemberId'] = patient.id;
    }
    if (confirmation.notes != null) payload['notes'] = confirmation.notes;
    payload['paymentMethod'] = bookingConsent.paymentMethod.apiValue;
    payload['shareProfile'] = bookingConsent.toShareProfileFlags();
    if (profileSnapshot != null && profileSnapshot.isNotEmpty) {
      payload['sharedProfileSnapshot'] = profileSnapshot;
    }
    payload['receiveEncounterSummary'] = bookingConsent.receiveEncounterSummary;
    if (bookingConsent.enableOngoingCare) {
      payload['enableOngoingCare'] = true;
    }

    developer.log('Booking saved offline — queued for sync', name: _logName);
    await _syncService.enqueue(
      mutationType: SyncMutationType.create,
      entityType: SyncEntityType.appointment,
      entityId: localId,
      payload: payload,
      clientUpdatedAt: now,
    );

    return BookingResult(
      confirmation: confirmation,
      isPendingSync: true,
      localId: localId,
    );
  }

  /// Queues a walk-in queue status update (auto-syncs when online).
  Future<void> enqueueQueueUpdate({
    required String appointmentId,
    required String status,
    DateTime? clientUpdatedAt,
  }) async {
    final updatedAt = clientUpdatedAt ?? DateTime.now().toUtc();
    await _syncService.enqueue(
      mutationType: SyncMutationType.update,
      entityType: SyncEntityType.queueUpdate,
      entityId: appointmentId,
      payload: {
        'status': status,
        'updatedAt': updatedAt.toIso8601String(),
      },
      clientUpdatedAt: updatedAt,
    );
  }

  Future<void> saveDraft({
    required String providerId,
    required DateTime date,
    required String time,
    required String patientId,
    String? notes,
  }) async {
    await _bookingDao.saveDraft(
      providerId: providerId,
      date: date,
      time: time,
      patientId: patientId,
      notes: notes,
    );
  }

  DateTime _combineDateTime(DateTime date, String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Future<String?> _resolveFacilityId({
    required ProviderModel provider,
    String? facilityId,
  }) async {
    if (facilityId != null && facilityId.isNotEmpty) return facilityId;
    if (provider.facilityId != null && provider.facilityId!.isNotEmpty) {
      return provider.facilityId;
    }
    if (await isOnline()) {
      final remote = await _api.getProviderById(provider.id);
      final remoteFacilityId = remote?.facilityId;
      if (remoteFacilityId != null && remoteFacilityId.isNotEmpty) {
        return remoteFacilityId;
      }
    }
    return null;
  }

  String _bookingErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) return message;
    }
    final status = error.response?.statusCode;
    if (status == 409) {
      return 'That time slot is no longer available. Please choose another time.';
    }
    if (status == 401 || status == 403) {
      return 'Please sign in again to complete your booking.';
    }
    return 'Could not confirm booking with the server. Please try again.';
  }
}
