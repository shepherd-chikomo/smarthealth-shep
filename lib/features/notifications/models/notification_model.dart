import 'package:flutter/foundation.dart';

enum NotificationCategory {
  appointmentReminder('appointment_reminder'),
  appointmentCancellation('appointment_cancellation'),
  appointmentConfirmed('appointment_confirmed'),
  appointmentRescheduled('appointment_rescheduled'),
  emergencyAlert('emergency_alert'),
  providerMessage('provider_message'),
  facilityAnnouncement('facility_announcement'),
  queueUpdate('queue_update'),
  verificationUpdate('verification_update'),
  claimApproval('claim_approval'),
  general('general');

  const NotificationCategory(this.value);
  final String value;

  static NotificationCategory fromString(String? raw) {
    return NotificationCategory.values.firstWhere(
      (c) => c.value == raw,
      orElse: () => NotificationCategory.general,
    );
  }
}

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.channel,
    required this.status,
    required this.category,
    this.actionUrl,
    this.payload = const {},
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String channel;
  final String status;
  final NotificationCategory category;
  final String? actionUrl;
  final Map<String, dynamic> payload;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isUnread => readAt == null;

  String? get queueEvent =>
      payload['queueEvent'] as String? ?? payload['event'] as String?;

  String? get appointmentEvent => payload['appointmentEvent'] as String?;

  /// Human-readable section label for grouped inbox views.
  String get groupLabel => switch (category) {
        NotificationCategory.appointmentReminder ||
        NotificationCategory.appointmentConfirmed ||
        NotificationCategory.appointmentRescheduled ||
        NotificationCategory.appointmentCancellation =>
          'Appointments',
        NotificationCategory.queueUpdate => 'Queue',
        NotificationCategory.emergencyAlert => 'Emergency',
        NotificationCategory.verificationUpdate => 'Verification',
        NotificationCategory.claimApproval => 'Claims',
        NotificationCategory.providerMessage => 'Messages',
        NotificationCategory.facilityAnnouncement => 'Announcements',
        NotificationCategory.general => 'General',
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      channel: json['channel'] as String? ?? 'in_app',
      status: json['status'] as String? ?? 'pending',
      category: NotificationCategory.fromString(json['category'] as String?),
      actionUrl: json['actionUrl'] as String?,
      payload: (json['payload'] as Map<String, dynamic>?) ?? const {},
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

@immutable
class NotificationPreference {
  const NotificationPreference({
    required this.channel,
    required this.category,
    required this.isEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  final String channel;
  final String category;
  final bool isEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      channel: json['channel'] as String,
      category: json['category'] as String,
      isEnabled: json['is_enabled'] as bool? ?? true,
      quietHoursStart: json['quiet_hours_start'] as String?,
      quietHoursEnd: json['quiet_hours_end'] as String?,
    );
  }
}
