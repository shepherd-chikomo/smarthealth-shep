import 'dart:developer' as developer;

import 'dart:io';



import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:smarthealth_shep/features/medications/utils/medication_schedule_utils.dart';

import 'package:smarthealth_shep/features/profile/utils/primary_profile_resolver.dart';

import 'package:smarthealth_shep/features/profile/utils/profile_none_sentinel.dart';

import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';

import 'package:smarthealth_shep/shared/models/family_member_model.dart';

import 'package:timezone/data/latest.dart' as tz_data;

import 'package:timezone/timezone.dart' as tz;



/// Device-local medication reminders — PHI never leaves the device.

class MedicationReminderService {

  MedicationReminderService._();



  static final MedicationReminderService instance = MedicationReminderService._();



  final _notifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;



  static const _payloadPrefix = 'med|';

  static const _channelId = 'medication_reminders_v2';

  static const _channelName = 'Medication Reminders';

  static const _takenActionId = 'med_taken';

  static const _snoozeActionId = 'med_snooze';

  static const _snoozeMinutes = 15;



  static const _alarmSound = UriAndroidNotificationSound(

    'content://settings/system/alarm_alert',

  );



  Future<void> initialize() async {

    if (_initialized || kIsWeb) return;



    tz_data.initializeTimeZones();

    try {

      final timeZoneName = await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(tz.getLocation(timeZoneName));

    } catch (_) {

      // Falls back to UTC when device timezone is unavailable.

    }



    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings();

    await _notifications.initialize(

      const InitializationSettings(android: android, iOS: ios),

      onDidReceiveNotificationResponse: _onNotificationResponse,

    );



    await _ensureAndroidChannel();



    _initialized = true;

  }



  Future<void> ensureAndroidChannel() => _ensureAndroidChannel();

  Future<void> _ensureAndroidChannel() async {
    if (!Platform.isAndroid) return;
    await _android?.createNotificationChannel(
      AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Daily medication dose reminders with alarm sound',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        sound: _alarmSound,
      ),
    );
  }



  static bool isMedicationPayload(String? payload) =>

      payload != null && payload.startsWith(_payloadPrefix);



  void handleNotificationResponse(NotificationResponse response) =>

      _onNotificationResponse(response);



  AndroidFlutterLocalNotificationsPlugin? get _android =>

      _notifications.resolvePlatformSpecificImplementation<

          AndroidFlutterLocalNotificationsPlugin>();



  Future<bool> ensurePermission() async {

    if (kIsWeb) return false;

    if (!Platform.isAndroid && !Platform.isIOS) return true;



    if (Platform.isAndroid) {

      await _ensureAndroidChannel();

      final notificationsGranted =

          await _android?.requestNotificationsPermission() ?? true;



      var exactGranted =

          await _android?.canScheduleExactNotifications() ?? true;

      if (!exactGranted) {

        await _android?.requestExactAlarmsPermission();

        exactGranted =

            await _android?.canScheduleExactNotifications() ?? false;

      }



      return notificationsGranted && exactGranted;

    }



    final status = await Permission.notification.status;

    if (status.isGranted) return true;

    final requested = await Permission.notification.request();

    return requested.isGranted;

  }



  Future<void> resyncAllFromMembers(List<FamilyMemberModel> members) async {

    if (!_initialized) await initialize();

    if (kIsWeb) return;



    for (final member in members) {

      final metadata = member.metadata;

      if (metadata == null || isMedicationsNone(metadata.medications)) continue;



      final hasReminders = metadata.medications.any((m) => m.reminderEnabled);

      if (!hasReminders) continue;



      final subjectId = member.id.isNotEmpty ? member.id : profilePrimaryLocalId;

      await syncMedications(

        subjectId: subjectId,

        medications: metadata.medications,

      );

    }

  }



  int countScheduledReminders(List<MedicationEntry> medications) {

    var count = 0;

    for (final entry in medications) {

      if (!entry.reminderEnabled) continue;

      count += MedicationScheduleUtils.resolveReminderTimes(entry).length;

    }

    return count;

  }



  Future<void> syncMedications({

    required String subjectId,

    required List<MedicationEntry> medications,

  }) async {

    if (!_initialized) await initialize();

    if (kIsWeb) return;



    if (!await ensurePermission()) {

      developer.log(

        'Medication reminders skipped — notification or exact-alarm permission missing',

        name: 'MedicationReminderService',

      );

      return;

    }



    await cancelAllForSubject(subjectId);



    for (final entry in medications) {

      if (!entry.reminderEnabled) continue;

      await scheduleMedication(subjectId: subjectId, entry: entry);

    }



    final pending = await _notifications.pendingNotificationRequests();

    developer.log(

      'Scheduled ${pending.where((r) => isMedicationPayload(r.payload)).length} medication notifications for $subjectId',

      name: 'MedicationReminderService',

    );

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



    for (var timeIndex = 0; timeIndex < times.length; timeIndex++) {

      final time = times[timeIndex];

      var scheduled = tz.TZDateTime(

        tz.local,

        now.year,

        now.month,

        now.day,

        time.hour,

        time.minute,

      );

      if (scheduled.isBefore(now)) {

        scheduled = scheduled.add(const Duration(days: 1));

      }



      final notificationId = _notificationId(

        subjectId: subjectId,

        medicationId: medicationId,

        timeIndex: timeIndex,

      );



      try {

        await _notifications.zonedSchedule(

          notificationId,

          'Medication reminder',

          'Time to take ${entry.name.trim()}',

          scheduled,

          _notificationDetails(medicationId, subjectId),

          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

          matchDateTimeComponents: DateTimeComponents.time,

          payload: _encodePayload(

            subjectId: subjectId,

            medicationId: medicationId,

            medicationName: entry.name,

            timeIndex: timeIndex,

          ),

        );

      } on PlatformException catch (error, stackTrace) {

        developer.log(

          'Exact alarm failed for ${time.hour}:${time.minute} — trying inexact',

          name: 'MedicationReminderService',

          error: error,

          stackTrace: stackTrace,

        );

        try {

          await _notifications.zonedSchedule(

            notificationId,

            'Medication reminder',

            'Time to take ${entry.name.trim()}',

            scheduled,

            _notificationDetails(medicationId, subjectId),

            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

            matchDateTimeComponents: DateTimeComponents.time,

            payload: _encodePayload(

              subjectId: subjectId,

              medicationId: medicationId,

              medicationName: entry.name,

              timeIndex: timeIndex,

            ),

          );

        } catch (fallbackError, fallbackStack) {

          developer.log(

            'Failed to schedule medication reminder at ${time.hour}:${time.minute}',

            name: 'MedicationReminderService',

            error: fallbackError,

            stackTrace: fallbackStack,

          );

        }

      } catch (error, stackTrace) {

        developer.log(

          'Failed to schedule medication reminder at ${time.hour}:${time.minute}',

          name: 'MedicationReminderService',

          error: error,

          stackTrace: stackTrace,

        );

      }

    }

  }



  Future<void> cancelMedication({

    required String subjectId,

    required String medicationId,

  }) async {

    if (!_initialized) await initialize();

    for (var timeIndex = 0; timeIndex < 8; timeIndex++) {

      await _notifications.cancel(

        _notificationId(

          subjectId: subjectId,

          medicationId: medicationId,

          timeIndex: timeIndex,

        ),

      );

      await _notifications.cancel(

        _notificationId(

          subjectId: subjectId,

          medicationId: medicationId,

          timeIndex: timeIndex,

          snoozed: true,

        ),

      );

    }

  }



  Future<void> cancelAllForSubject(String subjectId) async {

    if (!_initialized) await initialize();

    final pending = await _notifications.pendingNotificationRequests();

    for (final request in pending) {

      final payload = request.payload;

      if (payload != null && payload.startsWith('$_payloadPrefix$subjectId|')) {

        await _notifications.cancel(request.id);

      }

    }

  }



  void _onNotificationResponse(NotificationResponse response) {

    final payload = response.payload;

    if (payload == null || payload.isEmpty) return;



    if (!payload.startsWith(_payloadPrefix)) return;



    final parts = payload.substring(_payloadPrefix.length).split('|');

    if (parts.length < 3) return;



    final subjectId = parts[0];

    final medicationId = parts[1];

    final medicationName = parts[2];

    final timeIndex = parts.length > 3 ? int.tryParse(parts[3]) ?? 0 : 0;



    if (response.actionId == _takenActionId) {

      _notifications.cancel(

        _notificationId(

          subjectId: subjectId,

          medicationId: medicationId,

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

        timeIndex: timeIndex,

      );

    }

  }



  Future<void> _snooze({

    required String subjectId,

    required String medicationId,

    required String medicationName,

    required int timeIndex,

  }) async {

    final scheduled = tz.TZDateTime.now(tz.local).add(

      const Duration(minutes: _snoozeMinutes),

    );

    final notificationId = _notificationId(

      subjectId: subjectId,

      medicationId: medicationId,

      timeIndex: timeIndex,

      snoozed: true,

    );



    await _notifications.zonedSchedule(

      notificationId,

      'Medication reminder',

      'Time to take ${medicationName.trim()}',

      scheduled,

      _notificationDetails(medicationId, subjectId),

      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      payload: _encodePayload(

        subjectId: subjectId,

        medicationId: medicationId,

        medicationName: medicationName,

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

        channelDescription: 'Daily medication dose reminders with alarm sound',

        importance: Importance.max,

        priority: Priority.max,

        category: AndroidNotificationCategory.alarm,

        visibility: NotificationVisibility.public,

        enableVibration: true,

        playSound: true,

        sound: _alarmSound,

        audioAttributesUsage: AudioAttributesUsage.alarm,

        fullScreenIntent: true,

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

    required int timeIndex,

    bool snoozed = false,

  }) {

    final key =

        '$subjectId|$medicationId|$timeIndex|${snoozed ? 1 : 0}';

    return key.hashCode & 0x7fffffff;

  }



  String _encodePayload({

    required String subjectId,

    required String medicationId,

    required String medicationName,

    required int timeIndex,

  }) {

    return '$_payloadPrefix$subjectId|$medicationId|$medicationName|$timeIndex';

  }



  String _fallbackMedicationId(MedicationEntry entry) =>

      'med_${entry.name.trim().toLowerCase().hashCode}';

}

