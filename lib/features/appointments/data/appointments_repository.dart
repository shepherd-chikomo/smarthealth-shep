import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/features/appointments/data/local/appointment_dao.dart';
import 'package:smarthealth_shep/features/appointments/models/appointment_model.dart';
import 'package:smarthealth_shep/features/booking/models/booking_confirmation.dart';
import 'package:smarthealth_shep/shared/data/local/provider_dao.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_service.dart';
import 'package:smarthealth_shep/shared/models/operational_status.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

const _logName = 'AppointmentsRepository';

/// Offline-first appointment lifecycle repository.
class AppointmentsRepository {
  AppointmentsRepository({
    AppointmentDao? appointmentDao,
    ProviderDao? providerDao,
    SyncService? syncService,
    Dio? dio,
  })  : _dao = appointmentDao ?? AppointmentDao(),
        _providerDao = providerDao ?? ProviderDao(),
        _syncService =
            syncService ?? SyncService.instance ?? SyncService.forBackground(),
        _dio = dio ?? createApiDio();

  final AppointmentDao _dao;
  final ProviderDao _providerDao;
  final SyncService _syncService;
  final Dio _dio;

  Future<void> syncFromRemote() async {
    try {
      final now = DateTime.now().toUtc();
      final response = await _dio.get<Map<String, dynamic>>(
        '/appointments',
        queryParameters: {
          'from': now.toIso8601String(),
          'page': 1,
          'limit': 100,
        },
      );
      final raw = response.data?['appointments'] as List<dynamic>? ?? const [];
      for (final item in raw) {
        if (item is! Map<String, dynamic>) continue;
        final appointment = AppointmentModel.fromApiJson(item);
        if (!appointment.isTerminal) {
          await _dao.upsertFromApi(appointment);
        }
      }
      await _dao.purgeSeedRows();
      await _dao.deleteTerminal();
      developer.log(
        'Synced ${raw.length} appointments from API',
        name: _logName,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Appointment sync failed — using local cache',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<AppointmentModel>> loadAppointments({bool syncRemote = false}) async {
    if (syncRemote) {
      await syncFromRemote();
    }
    await _dao.purgeSeedRows();
    final appointments = await _dao.getAll();
    appointments.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return appointments;
  }

  Future<AppointmentModel?> getById(String id) => _dao.getById(id);

  Future<AppointmentModel?> getNextUpcoming() async {
    final appointments = await loadAppointments();
    final now = DateTime.now();
    final upcoming = appointments
        .where(
          (a) =>
              !a.isTerminal &&
              (a.isActive ||
                  a.scheduledAt.isAfter(now) ||
                  a.status == AppointmentOperationalStatus.rescheduled),
        )
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  Future<AppointmentModel> saveFromBooking({
    required BookingConfirmation booking,
    required String localId,
    ProviderModel? provider,
  }) async {
    final resolved = provider ?? await _resolveProvider(booking.providerId);
    final scheduledAt = _combineDateTime(booking.date, booking.time);
    final appointment = AppointmentModel(
      id: localId,
      referenceNumber: booking.referenceNumber,
      providerId: booking.providerId,
      providerName: booking.providerName,
      facilityName: booking.facilityName,
      specialty: resolved?.specialty,
      providerImageUrl:
          resolved?.imageUrl ?? AppAssets.providerPortraitFor(booking.providerId),
      facilityPhone: resolved?.phone,
      scheduledAt: scheduledAt,
      durationMinutes: booking.durationMinutes,
      patientName: booking.patientName,
      notes: booking.notes,
      status: AppointmentOperationalStatus.pending,
      reminderState: AppointmentReminderState.scheduled,
      reminderAt: scheduledAt.subtract(const Duration(hours: 24)),
      syncStatus: 'pending',
    );
    await _dao.save(appointment);
    return appointment;
  }

  Future<AppointmentModel> updateStatus(
    String id,
    AppointmentOperationalStatus status, {
    int? queuePosition,
    int? estimatedWaitMinutes,
    String? queueSessionId,
    DateTime? scheduledAt,
  }) async {
    final current = await _require(id);
    final now = DateTime.now().toUtc();
    var updated = current.copyWith(
      status: status,
      updatedAt: now,
      queuePosition: queuePosition,
      estimatedWaitMinutes: estimatedWaitMinutes,
      queueSessionId: queueSessionId,
      scheduledAt: scheduledAt,
      checkedInAt: status == AppointmentOperationalStatus.checkedIn
          ? now
          : current.checkedInAt,
      reminderState: status == AppointmentOperationalStatus.rescheduled
          ? AppointmentReminderState.scheduled
          : current.reminderState,
    );

    if (status == AppointmentOperationalStatus.inQueue &&
        queuePosition == null) {
      updated = updated.copyWith(
        queuePosition: 4,
        estimatedWaitMinutes: 20,
        queueSessionId: 'queue_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    await _dao.update(updated);
    await _enqueueStatusUpdate(updated);
    return updated;
  }

  Future<AppointmentModel> checkIn(String id) =>
      updateStatus(id, AppointmentOperationalStatus.checkedIn);

  Future<AppointmentModel> joinQueue(String id) =>
      updateStatus(id, AppointmentOperationalStatus.inQueue);

  Future<AppointmentModel> cancel(String id) =>
      updateStatus(id, AppointmentOperationalStatus.cancelled);

  Future<AppointmentModel> reschedule(
    String id, {
    required DateTime scheduledAt,
  }) async {
    return updateStatus(
      id,
      AppointmentOperationalStatus.rescheduled,
      scheduledAt: scheduledAt,
    );
  }

  Future<AppointmentModel> confirmBooking(String id) =>
      updateStatus(id, AppointmentOperationalStatus.confirmed);

  Future<AppointmentModel> markArrived(String id) => checkIn(id);

  Future<AppointmentModel> moveToQueue(String id) => joinQueue(id);

  Future<AppointmentModel> completeConsultation(String id) =>
      updateStatus(id, AppointmentOperationalStatus.completed);

  Future<AppointmentModel> cancelBooking(String id) => cancel(id);

  Future<AppointmentModel> markNoShow(String id) =>
      updateStatus(id, AppointmentOperationalStatus.noShow);

  Future<void> _enqueueStatusUpdate(AppointmentModel appointment) async {
    try {
      await _syncService.enqueue(
        mutationType: SyncMutationType.update,
        entityType: SyncEntityType.appointment,
        entityId: appointment.id,
        payload: {
          'status': appointment.status.name,
          'scheduledAt': appointment.scheduledAt.toUtc().toIso8601String(),
          'queueSessionId': appointment.queueSessionId,
          'updatedAt':
              (appointment.updatedAt ?? DateTime.now()).toUtc().toIso8601String(),
        },
        clientUpdatedAt: appointment.updatedAt ?? DateTime.now().toUtc(),
      );
    } catch (error) {
      developer.log('Status sync enqueue failed: $error', name: _logName);
    }
  }

  Future<AppointmentModel> _require(String id) async {
    final appointment = await _dao.getById(id);
    if (appointment == null) {
      throw StateError('Appointment not found: $id');
    }
    return appointment;
  }

  Future<ProviderModel?> _resolveProvider(String providerId) async {
    return _providerDao.getById(providerId);
  }

  DateTime _combineDateTime(DateTime date, String time) {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
