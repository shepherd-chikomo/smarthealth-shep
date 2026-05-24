import 'package:flutter/foundation.dart';

/// Patient-facing queue lifecycle states.
enum QueuePatientStatus {
  waiting,
  youreNext,
  inConsultation,
  completed,
  delayed,
  paused,
  cancelled,
}

extension QueuePatientStatusX on QueuePatientStatus {
  String get label => switch (this) {
        QueuePatientStatus.waiting => 'Waiting',
        QueuePatientStatus.youreNext => "You're Next",
        QueuePatientStatus.inConsultation => 'In Consultation',
        QueuePatientStatus.completed => 'Completed',
        QueuePatientStatus.delayed => 'Delayed',
        QueuePatientStatus.paused => 'Queue Paused',
        QueuePatientStatus.cancelled => 'Cancelled',
      };

  bool get isActive => switch (this) {
        QueuePatientStatus.waiting ||
        QueuePatientStatus.youreNext ||
        QueuePatientStatus.inConsultation ||
        QueuePatientStatus.delayed ||
        QueuePatientStatus.paused =>
          true,
        _ => false,
      };
}

@immutable
class QueueSession {
  const QueueSession({
    required this.id,
    required this.ticketNumber,
    required this.providerId,
    required this.providerName,
    required this.facilityName,
    required this.patientId,
    required this.patientName,
    required this.patientsAhead,
    required this.estimatedWaitMinutes,
    required this.status,
    required this.joinedAt,
    required this.lastUpdated,
    this.chiefComplaint,
    this.providerSpecialty,
  });

  final String id;
  final String ticketNumber;
  final String providerId;
  final String providerName;
  final String facilityName;
  final String? providerSpecialty;
  final String patientId;
  final String patientName;
  final int patientsAhead;
  final int estimatedWaitMinutes;
  final QueuePatientStatus status;
  final DateTime joinedAt;
  final DateTime lastUpdated;
  final String? chiefComplaint;

  factory QueueSession.fromJson(Map<String, dynamic> json) {
    return QueueSession(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      facilityName: json['facilityName'] as String,
      providerSpecialty: json['providerSpecialty'] as String?,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      patientsAhead: json['patientsAhead'] as int? ?? 0,
      estimatedWaitMinutes: json['estimatedWaitMinutes'] as int? ?? 0,
      status: QueuePatientStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => QueuePatientStatus.waiting,
      ),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      chiefComplaint: json['chiefComplaint'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticketNumber': ticketNumber,
        'providerId': providerId,
        'providerName': providerName,
        'facilityName': facilityName,
        'providerSpecialty': providerSpecialty,
        'patientId': patientId,
        'patientName': patientName,
        'patientsAhead': patientsAhead,
        'estimatedWaitMinutes': estimatedWaitMinutes,
        'status': status.name,
        'joinedAt': joinedAt.toIso8601String(),
        'lastUpdated': lastUpdated.toIso8601String(),
        'chiefComplaint': chiefComplaint,
      };

  QueueSession copyWith({
    String? id,
    String? ticketNumber,
    String? providerId,
    String? providerName,
    String? facilityName,
    String? providerSpecialty,
    String? patientId,
    String? patientName,
    int? patientsAhead,
    int? estimatedWaitMinutes,
    QueuePatientStatus? status,
    DateTime? joinedAt,
    DateTime? lastUpdated,
    String? chiefComplaint,
  }) {
    return QueueSession(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      facilityName: facilityName ?? this.facilityName,
      providerSpecialty: providerSpecialty ?? this.providerSpecialty,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientsAhead: patientsAhead ?? this.patientsAhead,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
    );
  }
}
