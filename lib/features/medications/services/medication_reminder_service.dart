import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smarthealth_shep/features/medications/utils/medication_schedule_utils.dart';
import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Device-local medication reminders — PHI never leaves the device.
class MedicationReminderService {
  MedicationReminderService._();

  static final MedicationReminderService instance = MedicationReminderService._();

  final _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'medication_reminders';
  static const _channelName = 'Medication Reminders';
  static const _takenActionId = 'med_taken';
  static const _snoozeActionId = 'med_snooze';
  static const _snoozeMinutes = 15;
  static const _scheduleDays = 7;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.local);
    } catch (_) {
      // Falls back to UTC when device timezone is unavailable.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: 'Daily medication dose reminders',
              importance: Importance.high,
            ),
          );
    }

    _initialized = true;
  }

  Future<bool> ensurePermission() async {
    if (kIsWeb) return false;
    if (!Platform.isAndroid && !Platform.isIOS) return true;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> syncMedications({
    required String subjectId,
    required List<MedicationEntry> medications,
  }) async {
    if (!_initialized) await initialize();
    if (kIsWeb) return;

    await cancelAllForSubject(subjectId);

    for (final entry in medications) {
      if (!entry.reminderEnabled) continue;
      await scheduleMedication(subjectId: subjectId, entry: entry);
    }
  }

  Future<void> scheduleMedication({
    required String subjectId,
    required MedicationEntry entry,
  }) async {
    if (!_initialized) await initialize();
    if (kIsWeb || !entry.reminderEnabled) return;

    final medicationId = entry.id ?? _fallbackMedicationId(entry);
    final times = MedicationScheduleUtils.resolveReminderTimes(entry);
    final now = tz.TZDateTime.now(tz.local);

    for (var dayOffset = 0; dayOffset < _scheduleDays; dayOffset++) {
      final day = now.add(Duration(days: dayOffset));
      for (var timeIndex = 0; timeIndex < times.length; timeIndex++) {
        final time = times[timeIndex];
        final scheduled = tz.TZDateTime(
          tz.local,
          day.year,
          day.month,
          day.day,
          time.hour,
          time.minute,
        );
        if (scheduled.isBefore(now)) continue;

        final notificationId = _notificationId(
          subjectId: subjectId,
          medicationId: medicationId,
          dayOffset: dayOffset,
          timeIndex: timeIndex,
        );

        await _notifications.zonedSchedule(
          notificationId,
          'Medication reminder',
          'Time to take ${entry.name.trim()}',
          scheduled,
          _notificationDetails(medicationId, subjectId),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: _encodePayload(
            subjectId: subjectId,
            medicationId: medicationId,
            medicationName: entry.name,
            dayOffset: dayOffset,
            timeIndex: timeIndex,
          ),
        );
      }
    }
  }

  Future<void> cancelMedication({
    required String subjectId,
    required String medicationId,
  }) async {
    if (!_initialized) await initialize();
    for (var dayOffset = 0; dayOffset < _scheduleDays; dayOffset++) {
      for (var timeIndex = 0; timeIndex < 8; timeIndex++) {
        await _notifications.cancel(
          _notificationId(
            subjectId: subjectId,
            medicationId: medicationId,
            dayOffset: dayOffset,
            timeIndex: timeIndex,
          ),
        );
      }
    }
  }

  Future<void> cancelAllForSubject(String subjectId) async {
    if (!_initialized) await initialize();
    final pending = await _notifications.pendingNotificationRequests();
    for (final request in pending) {
      final payload = request.payload;
      if (payload != null && payload.startsWith('$subjectId|')) {
        await _notifications.cancel(request.id);
      }
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final parts = payload.split('|');
    if (parts.length < 3) return;

    final subjectId = parts[0];
    final medicationId = parts[1];
    final medicationName = parts[2];
    final dayOffset = parts.length > 3 ? int.tryParse(parts[3]) ?? 0 : 0;
    final timeIndex = parts.length > 4 ? int.tryParse(parts[4]) ?? 0 : 0;

    if (response.actionId == _takenActionId) {
      _notifications.cancel(
        _notificationId(
          subjectId: subjectId,
          medicationId: medicationId,
          dayOffset: dayOffset,
          timeIndex: timeIndex,
        ),
      );
      return;
    }

    if (response.actionId == _snoozeActionId) {
      _snooze(
        subjectId: subjectId,
        medicationId: medicationId,
        medicationName: medicationName,
        dayOffset: dayOffset,
        timeIndex: timeIndex,
      );
    }
  }

  Future<void> _snooze({
    required String subjectId,
    required String medicationId,
    required String medicationName,
    required int dayOffset,
    required int timeIndex,
  }) async {
    final scheduled = tz.TZDateTime.now(tz.local).add(
      const Duration(minutes: _snoozeMinutes),
    );
    final notificationId = _notificationId(
      subjectId: subjectId,
      medicationId: medicationId,
      dayOffset: dayOffset,
      timeIndex: timeIndex,
      snoozed: true,
    );

    await _notifications.zonedSchedule(
      notificationId,
      'Medication reminder',
      'Time to take ${medicationName.trim()}',
      scheduled,
      _notificationDetails(medicationId, subjectId),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: _encodePayload(
        subjectId: subjectId,
        medicationId: medicationId,
        medicationName: medicationName,
        dayOffset: dayOffset,
        timeIndex: timeIndex,
      ),
    );
  }

  NotificationDetails _notificationDetails(
    String medicationId,
    String subjectId,
  ) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Daily medication dose reminders',
        importance: Importance.high,
        priority: Priority.high,
        actions: const [
          AndroidNotificationAction(
            _takenActionId,
            'Taken',
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            _snoozeActionId,
            'Snooze',
            showsUserInterface: false,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: 'medication_reminder',
      ),
    );
  }

  int _notificationId({
    required String subjectId,
    required String medicationId,
    required int dayOffset,
    required int timeIndex,
    bool snoozed = false,
  }) {
    final key =
        '$subjectId|$medicationId|$dayOffset|$timeIndex|${snoozed ? 1 : 0}';
    return key.hashCode & 0x7fffffff;
  }

  String _encodePayload({
    required String subjectId,
    required String medicationId,
    required String medicationName,
    required int dayOffset,
    required int timeIndex,
  }) {
    return '$subjectId|$medicationId|$medicationName|$dayOffset|$timeIndex';
  }

  String _fallbackMedicationId(MedicationEntry entry) =>
      'med_${entry.name.trim().toLowerCase().hashCode}';
}
