import 'dart:convert';
import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';
import 'package:smarthealth_shep/features/booking/data/booking_repository.dart';
import 'package:smarthealth_shep/features/booking/models/patient_option.dart';
import 'package:smarthealth_shep/features/queue/models/queue_session.dart';
import 'package:smarthealth_shep/shared/data/local/provider_dao.dart';
import 'package:smarthealth_shep/shared/data/mock_data.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Offline-first queue join, status, and leave for patient walk-ins.
class QueueRepository {
  QueueRepository({
    ProviderDao? providerDao,
    BookingRepository? bookingRepository,
  })  : _providerDao = providerDao ?? ProviderDao(),
        _booking = bookingRepository ?? BookingRepository();

  final ProviderDao _providerDao;
  final BookingRepository _booking;
  final _random = Random();

  static const _activeKey = 'active_queue_session';
  static const _historyKey = 'queue_session_history';

  Box get _box => Hive.box(HiveBoxes.homeDashboard);

  Future<ProviderModel?> getProvider(String providerId) async {
    final local = await _providerDao.getById(providerId);
    if (local != null) return local;
    if (AppConfig.allowMockFallbacks) {
      for (final provider in MockData.providers) {
        if (provider.id == providerId) return provider;
      }
    }
    return null;
  }

  Future<List<PatientOption>> getPatients() => _booking.getPatients();

  QueueSession? getActiveSession() {
    final raw = _box.get(_activeKey);
    if (raw == null) return null;
    try {
      final session = QueueSession.fromJson(
        jsonDecode(raw as String) as Map<String, dynamic>,
      );
      return session.status.isActive ? session : null;
    } catch (_) {
      return null;
    }
  }

  Future<QueueSession?> getSession(String id) async {
    final active = getActiveSession();
    if (active?.id == id) return active;
    return _readHistory().where((s) => s.id == id).firstOrNull;
  }

  Future<QueueSession> joinQueue({
    required ProviderModel provider,
    required PatientOption patient,
    String? chiefComplaint,
  }) async {
    final existing = getActiveSession();
    if (existing != null) {
      throw StateError('You already have an active queue ticket');
    }

    final ahead = provider.queueLength ?? 4 + _random.nextInt(8);
    final wait = ahead * 6 + _random.nextInt(10);
    final ticket = _nextTicket();
    final now = DateTime.now();

    final session = QueueSession(
      id: 'q_${now.millisecondsSinceEpoch}',
      ticketNumber: ticket,
      providerId: provider.id,
      providerName: provider.name,
      facilityName: provider.facilityName ?? provider.name,
      providerSpecialty: provider.specialty,
      patientId: patient.id,
      patientName: patient.name,
      patientsAhead: ahead,
      estimatedWaitMinutes: wait,
      status: QueuePatientStatus.waiting,
      joinedAt: now,
      lastUpdated: now,
      chiefComplaint: chiefComplaint?.trim().isEmpty == true
          ? null
          : chiefComplaint?.trim(),
    );

    await _persistActive(session);
    return session;
  }

  Future<void> leaveQueue(String sessionId) async {
    final active = getActiveSession();
    if (active == null || active.id != sessionId) return;

    final cancelled = active.copyWith(
      status: QueuePatientStatus.cancelled,
      lastUpdated: DateTime.now(),
    );
    await _archive(cancelled);
    await _box.delete(_activeKey);
  }

  /// Simulates live queue movement for demo / polling refresh.
  Future<QueueSession> refreshSession(String sessionId) async {
    var session = await getSession(sessionId);
    if (session == null) {
      throw StateError('Queue session not found');
    }
    if (!session.status.isActive) return session;

    final now = DateTime.now();
    final elapsed = now.difference(session.lastUpdated).inSeconds;

    if (session.status == QueuePatientStatus.paused ||
        session.status == QueuePatientStatus.delayed) {
      session = session.copyWith(lastUpdated: now);
      await _persistIfActive(session);
      return session;
    }

    if (elapsed >= 8 && session.patientsAhead > 0) {
      final nextAhead = session.patientsAhead - 1;
      session = session.copyWith(
        patientsAhead: nextAhead,
        estimatedWaitMinutes: max(5, session.estimatedWaitMinutes - 5),
        status: nextAhead == 0
            ? QueuePatientStatus.youreNext
            : QueuePatientStatus.waiting,
        lastUpdated: now,
      );
    } else if (session.status == QueuePatientStatus.youreNext &&
        elapsed >= 12) {
      session = session.copyWith(
        status: QueuePatientStatus.inConsultation,
        patientsAhead: 0,
        estimatedWaitMinutes: 0,
        lastUpdated: now,
      );
    } else {
      session = session.copyWith(lastUpdated: now);
    }

    await _persistIfActive(session);
    return session;
  }

  Future<void> _persistIfActive(QueueSession session) async {
    if (session.status.isActive) {
      await _persistActive(session);
    } else {
      await _archive(session);
      await _box.delete(_activeKey);
    }
  }

  Future<void> _persistActive(QueueSession session) async {
    await _box.put(_activeKey, jsonEncode(session.toJson()));
  }

  Future<void> _archive(QueueSession session) async {
    final history = _readHistory();
    history.removeWhere((s) => s.id == session.id);
    history.insert(0, session);
    final trimmed = history.take(10).toList();
    await _box.put(
      _historyKey,
      jsonEncode(trimmed.map((s) => s.toJson()).toList()),
    );
  }

  List<QueueSession> _readHistory() {
    final raw = _box.get(_historyKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw as String) as List<dynamic>)
          .map((e) => QueueSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  String _nextTicket() {
    final letter = String.fromCharCode(65 + _random.nextInt(3));
    final number = 10 + _random.nextInt(89);
    return '$letter$number';
  }
}
