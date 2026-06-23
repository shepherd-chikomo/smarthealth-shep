class ConsentRecord {
  const ConsentRecord({
    required this.id,
    required this.consentType,
    required this.version,
    required this.grantedAt,
    this.withdrawnAt,
    this.metadata = const {},
  });

  final String id;
  final String consentType;
  final String version;
  final DateTime grantedAt;
  final DateTime? withdrawnAt;
  final Map<String, dynamic> metadata;

  bool get isActive => withdrawnAt == null;

  String? get facilityId => metadata['facilityId'] as String?;

  Map<String, bool> get shareProfile {
    final raw = metadata['shareProfile'];
    if (raw is! Map) return {};
    return raw.map((key, value) => MapEntry(key.toString(), value == true));
  }

  factory ConsentRecord.fromJson(Map<String, dynamic> json) {
    return ConsentRecord(
      id: json['id'] as String,
      consentType: json['consentType'] as String,
      version: json['version'] as String,
      grantedAt: DateTime.parse(json['grantedAt'] as String),
      withdrawnAt: json['withdrawnAt'] != null
          ? DateTime.parse(json['withdrawnAt'] as String)
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }
}
