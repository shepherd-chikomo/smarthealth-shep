import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/shared/models/operational_status.dart';

enum AppointmentType { inPerson, telehealth, followUp }

enum AppointmentReminderState { none, scheduled, sent, dismissed }

/// Full appointment record with operational lifecycle fields.
class AppointmentModel extends Equatable {
  const AppointmentModel({
    required this.id,
    required this.referenceNumber,
    required this.providerId,
    required this.providerName,
    required this.facilityName,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.patientName,
    required this.status,
    this.specialty,
    this.providerImageUrl,
    this.facilityPhone,
    this.patientId,
    this.appointmentType = AppointmentType.inPerson,
    this.reminderState = AppointmentReminderState.scheduled,
    this.reminderAt,
    this.queuePosition,
    this.estimatedWaitMinutes,
    this.queueSessionId,
    this.notes,
    this.checkedInAt,
    this.syncStatus = 'synced',
    this.updatedAt,
  });

  final String id;
  final String referenceNumber;
  final String providerId;
  final String providerName;
  final String facilityName;
  final String? specialty;
  final String? providerImageUrl;
  final String? facilityPhone;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String patientName;
  final String? patientId;
  final AppointmentType appointmentType;
  final AppointmentOperationalStatus status;
  final AppointmentReminderState reminderState;
  final DateTime? reminderAt;
  final int? queuePosition;
  final int? estimatedWaitMinutes;
  final String? queueSessionId;
  final String? notes;
  final DateTime? checkedInAt;
  final String syncStatus;
  final DateTime? updatedAt;

  DateTime get endAt =>
      scheduledAt.add(Duration(minutes: durationMinutes));

  bool get isUpcoming =>
      status == AppointmentOperationalStatus.pending ||
      status == AppointmentOperationalStatus.confirmed ||
      status == AppointmentOperationalStatus.rescheduled;

  bool get isActive =>
      status == AppointmentOperationalStatus.checkedIn ||
      status == AppointmentOperationalStatus.inQueue;

  bool get isTerminal =>
      status == AppointmentOperationalStatus.completed ||
      status == AppointmentOperationalStatus.cancelled ||
      status == AppointmentOperationalStatus.noShow;

  bool get hasQueueInfo =>
      queuePosition != null || status == AppointmentOperationalStatus.inQueue;

  bool get canCheckIn =>
      status == AppointmentOperationalStatus.confirmed ||
      status == AppointmentOperationalStatus.rescheduled;

  bool get canJoinQueue =>
      status == AppointmentOperationalStatus.checkedIn ||
      status == AppointmentOperationalStatus.confirmed;

  bool get canReschedule => isUpcoming;

  bool get canCancel => isUpcoming || status == AppointmentOperationalStatus.confirmed;

  bool get canContactFacility =>
      facilityPhone != null && !isTerminal;

  String get appointmentTypeLabel => switch (appointmentType) {
        AppointmentType.inPerson => 'In-person visit',
        AppointmentType.telehealth => 'Telehealth',
        AppointmentType.followUp => 'Follow-up',
      };

  String get reminderStateLabel => switch (reminderState) {
        AppointmentReminderState.none => 'No reminder',
        AppointmentReminderState.scheduled => 'Reminder scheduled',
        AppointmentReminderState.sent => 'Reminder sent',
        AppointmentReminderState.dismissed => 'Reminder dismissed',
      };

  AppointmentModel copyWith({
    String? id,
    String? referenceNumber,
    String? providerId,
    String? providerName,
    String? facilityName,
    String? specialty,
    String? providerImageUrl,
    String? facilityPhone,
    DateTime? scheduledAt,
    int? durationMinutes,
    String? patientName,
    String? patientId,
    AppointmentType? appointmentType,
    AppointmentOperationalStatus? status,
    AppointmentReminderState? reminderState,
    DateTime? reminderAt,
    int? queuePosition,
    int? estimatedWaitMinutes,
    String? queueSessionId,
    String? notes,
    DateTime? checkedInAt,
    String? syncStatus,
    DateTime? updatedAt,
    bool clearQueuePosition = false,
    bool clearQueueSessionId = false,
    bool clearCheckedInAt = false,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      facilityName: facilityName ?? this.facilityName,
      specialty: specialty ?? this.specialty,
      providerImageUrl: providerImageUrl ?? this.providerImageUrl,
      facilityPhone: facilityPhone ?? this.facilityPhone,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      patientName: patientName ?? this.patientName,
      patientId: patientId ?? this.patientId,
      appointmentType: appointmentType ?? this.appointmentType,
      status: status ?? this.status,
      reminderState: reminderState ?? this.reminderState,
      reminderAt: reminderAt ?? this.reminderAt,
      queuePosition:
          clearQueuePosition ? null : (queuePosition ?? this.queuePosition),
      estimatedWaitMinutes:
          estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      queueSessionId: clearQueueSessionId
          ? null
          : (queueSessionId ?? this.queueSessionId),
      notes: notes ?? this.notes,
      checkedInAt:
          clearCheckedInAt ? null : (checkedInAt ?? this.checkedInAt),
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'referenceNumber': referenceNumber,
        'providerId': providerId,
        'providerName': providerName,
        'facilityName': facilityName,
        'specialty': specialty,
        'providerImageUrl': providerImageUrl,
        'facilityPhone': facilityPhone,
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        'durationMinutes': durationMinutes,
        'patientName': patientName,
        'patientId': patientId,
        'appointmentType': appointmentType.name,
        'status': status.name,
        'reminderState': reminderState.name,
        'reminderAt': reminderAt?.toUtc().toIso8601String(),
        'queuePosition': queuePosition,
        'estimatedWaitMinutes': estimatedWaitMinutes,
        'queueSessionId': queueSessionId,
        'notes': notes,
        'checkedInAt': checkedInAt?.toUtc().toIso8601String(),
        'syncStatus': syncStatus,
        'updatedAt': updatedAt?.toUtc().toIso8601String(),
      };

  factory AppointmentModel.fromApiJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      referenceNumber: json['referenceNumber'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String? ?? 'Provider',
      facilityName: json['facilityName'] as String? ?? 'Facility',
      scheduledAt: _parseDate(json['scheduledAt']),
      durationMinutes: json['durationMinutes'] as int? ?? 30,
      patientName: json['patientName'] as String? ?? 'Patient',
      patientId: json['patientId'] as String?,
      status: _parseApiStatus(json['status'] as String?),
      notes: json['notes'] as String?,
      syncStatus: 'synced',
      updatedAt: _parseOptionalDate(json['updatedAt']),
    );
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String? ?? json['referenceNumber'] as String,
      referenceNumber: json['referenceNumber'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      facilityName: json['facilityName'] as String,
      specialty: json['specialty'] as String?,
      providerImageUrl: json['providerImageUrl'] as String?,
      facilityPhone: json['facilityPhone'] as String?,
      scheduledAt: _parseDate(json['scheduledAt'] ?? json['date']),
      durationMinutes: json['durationMinutes'] as int? ?? 30,
      patientName: json['patientName'] as String? ?? 'Patient',
      patientId: json['patientId'] as String?,
      appointmentType: _parseType(json['appointmentType'] as String?),
      status: _parseStatus(json['status'] as String?),
      reminderState:
          _parseReminder(json['reminderState'] as String?),
      reminderAt: _parseOptionalDate(json['reminderAt']),
      queuePosition: json['queuePosition'] as int?,
      estimatedWaitMinutes: json['estimatedWaitMinutes'] as int?,
      queueSessionId: json['queueSessionId'] as String?,
      notes: json['notes'] as String?,
      checkedInAt: _parseOptionalDate(json['checkedInAt']),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
      updatedAt: _parseOptionalDate(json['updatedAt']),
    );
  }

  static AppointmentType _parseType(String? raw) {
    return AppointmentType.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => AppointmentType.inPerson,
    );
  }

  static AppointmentOperationalStatus _parseStatus(String? raw) {
    if (raw == null) return AppointmentOperationalStatus.pending;
    return AppointmentOperationalStatus.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => AppointmentOperationalStatus.pending,
    );
  }

  static AppointmentOperationalStatus _parseApiStatus(String? raw) {
    return switch (raw) {
      'checked_in' => AppointmentOperationalStatus.checkedIn,
      'in_progress' => AppointmentOperationalStatus.inQueue,
      'no_show' => AppointmentOperationalStatus.noShow,
      'confirmed' => AppointmentOperationalStatus.confirmed,
      'completed' => AppointmentOperationalStatus.completed,
      'cancelled' => AppointmentOperationalStatus.cancelled,
      'rescheduled' => AppointmentOperationalStatus.rescheduled,
      _ => AppointmentOperationalStatus.pending,
    };
  }

  static AppointmentReminderState _parseReminder(String? raw) {
    return AppointmentReminderState.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => AppointmentReminderState.scheduled,
    );
  }

  static DateTime _parseDate(Object? raw) {
    if (raw is DateTime) return raw.toLocal();
    if (raw is String && raw.contains('T')) {
      return DateTime.parse(raw).toLocal();
    }
    if (raw is String) {
      final parts = raw.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    }
    return DateTime.now();
  }

  static DateTime? _parseOptionalDate(Object? raw) {
    if (raw == null) return null;
    return _parseDate(raw);
  }

  @override
  List<Object?> get props => [
        id,
        referenceNumber,
        providerId,
        providerName,
        facilityName,
        specialty,
        providerImageUrl,
        facilityPhone,
        scheduledAt,
        durationMinutes,
        patientName,
        patientId,
        appointmentType,
        status,
        reminderState,
        reminderAt,
        queuePosition,
        estimatedWaitMinutes,
        queueSessionId,
        notes,
        checkedInAt,
        syncStatus,
        updatedAt,
      ];
}
