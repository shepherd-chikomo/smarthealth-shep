class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.createdAt,
    this.subjectId,
    this.facilityId,
    this.providerId,
    this.details = const {},
    this.synced = false,
  });

  final String id;
  final String action;
  final DateTime createdAt;
  final String? subjectId;
  final String? facilityId;
  final String? providerId;
  final Map<String, Object?> details;
  final bool synced;

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'createdAt': createdAt.toUtc().toIso8601String(),
        if (subjectId != null) 'subjectId': subjectId,
        if (facilityId != null) 'facilityId': facilityId,
        if (providerId != null) 'providerId': providerId,
        'details': details,
      };
}
