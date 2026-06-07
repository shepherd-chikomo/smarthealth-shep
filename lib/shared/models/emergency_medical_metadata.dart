bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

bool _isUuid(String? value) =>
    value != null && _uuidPattern.hasMatch(value.trim());

class MedicationEntry {
  const MedicationEntry({required this.name, this.frequency});

  final String name;
  final String? frequency;

  factory MedicationEntry.fromJson(Map<String, dynamic> json) {
    return MedicationEntry(
      name: json['name'] as String? ?? '',
      frequency: json['frequency'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return const {};
    return {
      'name': trimmedName,
      if (frequency != null && frequency!.isNotEmpty) 'frequency': frequency,
    };
  }
}

class EmergencyContactInfo {
  const EmergencyContactInfo({
    this.name,
    this.relationship,
    this.phone,
  });

  final String? name;
  final String? relationship;
  final String? phone;

  factory EmergencyContactInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EmergencyContactInfo();
    return EmergencyContactInfo(
      name: json['name'] as String?,
      relationship: json['relationship'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toApiJson() => {
        if (_hasText(name)) 'name': name!.trim(),
        if (_hasText(relationship)) 'relationship': relationship!.trim(),
        if (_hasText(phone)) 'phone': phone!.trim(),
      };

  Map<String, dynamic> toJson() => toApiJson();

  bool get hasAny =>
      (name?.isNotEmpty ?? false) ||
      (relationship?.isNotEmpty ?? false) ||
      (phone?.isNotEmpty ?? false);
}

class MedicalAidInfo {
  const MedicalAidInfo({
    this.schemeKey,
    this.provider,
    this.memberNumber,
  });

  final String? schemeKey;
  final String? provider;
  final String? memberNumber;

  factory MedicalAidInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MedicalAidInfo();
    return MedicalAidInfo(
      schemeKey: json['schemeKey'] as String?,
      provider: json['provider'] as String?,
      memberNumber: json['memberNumber'] as String?,
    );
  }

  Map<String, dynamic> toApiJson() => {
        if (_hasText(schemeKey)) 'schemeKey': schemeKey!.trim(),
        if (_hasText(provider)) 'provider': provider!.trim(),
        if (_hasText(memberNumber)) 'memberNumber': memberNumber!.trim(),
      };

  Map<String, dynamic> toJson() => toApiJson();

  bool get hasAny =>
      _hasText(schemeKey) ||
      _hasText(provider) ||
      _hasText(memberNumber);
}

class PrimaryProviderInfo {
  const PrimaryProviderInfo({
    this.facilityId,
    this.providerId,
    this.facilityName,
    this.doctorName,
    this.phone,
  });

  final String? facilityId;
  final String? providerId;
  final String? facilityName;
  final String? doctorName;
  final String? phone;

  factory PrimaryProviderInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PrimaryProviderInfo();
    return PrimaryProviderInfo(
      facilityId: json['facilityId'] as String?,
      providerId: json['providerId'] as String?,
      facilityName: json['facilityName'] as String?,
      doctorName: json['doctorName'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toApiJson() => {
        if (_isUuid(facilityId)) 'facilityId': facilityId!.trim(),
        if (_isUuid(providerId)) 'providerId': providerId!.trim(),
        if (_hasText(facilityName)) 'facilityName': facilityName!.trim(),
        if (_hasText(doctorName)) 'doctorName': doctorName!.trim(),
        if (_hasText(phone)) 'phone': phone!.trim(),
      };

  Map<String, dynamic> toJson() => toApiJson();

  bool get hasAny =>
      (facilityName?.isNotEmpty ?? false) ||
      (doctorName?.isNotEmpty ?? false) ||
      (phone?.isNotEmpty ?? false);
}

class EmergencyMedicalMetadata {
  const EmergencyMedicalMetadata({
    this.bloodGroup,
    this.medications = const [],
    this.emergencyContact = const EmergencyContactInfo(),
    this.medicalAid = const MedicalAidInfo(),
    this.primaryProvider = const PrimaryProviderInfo(),
    this.customConditionLabels = const {},
  });

  final String? bloodGroup;
  final List<MedicationEntry> medications;
  final EmergencyContactInfo emergencyContact;
  final MedicalAidInfo medicalAid;
  final PrimaryProviderInfo primaryProvider;
  final Map<String, String> customConditionLabels;

  factory EmergencyMedicalMetadata.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const EmergencyMedicalMetadata();
    final medsRaw = json['medications'] as List<dynamic>? ?? const [];
    return EmergencyMedicalMetadata(
      bloodGroup: json['bloodGroup'] as String?,
      medications: medsRaw
          .whereType<Map<String, dynamic>>()
          .map(MedicationEntry.fromJson)
          .where((m) => m.name.isNotEmpty)
          .toList(),
      emergencyContact: EmergencyContactInfo.fromJson(
        json['emergencyContact'] as Map<String, dynamic>?,
      ),
      medicalAid: MedicalAidInfo.fromJson(
        json['medicalAid'] as Map<String, dynamic>?,
      ),
      primaryProvider: PrimaryProviderInfo.fromJson(
        json['primaryProvider'] as Map<String, dynamic>?,
      ),
      customConditionLabels: _parseCustomConditionLabels(
        json['customConditionLabels'],
      ),
    );
  }

  static Map<String, String> _parseCustomConditionLabels(Object? raw) {
    if (raw is! Map) return const {};
    final result = <String, String>{};
    for (final entry in raw.entries) {
      final key = entry.key?.toString().trim();
      final value = entry.value?.toString().trim();
      if (key != null && key.isNotEmpty && value != null && value.isNotEmpty) {
        result[key] = value;
      }
    }
    return result;
  }

  /// Full metadata payload for family member API writes.
  Map<String, dynamic> toApiJson() {
    final json = <String, dynamic>{
      'medications': medications
          .map((m) => m.toJson())
          .where((json) => json.isNotEmpty)
          .toList(),
    };
    if (_hasText(bloodGroup)) {
      json['bloodGroup'] = bloodGroup!.trim();
    }
    if (emergencyContact.hasAny) {
      json['emergencyContact'] = emergencyContact.toApiJson();
    }
    if (medicalAid.hasAny) {
      json['medicalAid'] = medicalAid.toApiJson();
    }
    if (primaryProvider.hasAny) {
      json['primaryProvider'] = primaryProvider.toApiJson();
    }
    if (customConditionLabels.isNotEmpty) {
      json['customConditionLabels'] = customConditionLabels;
    }
    return json;
  }

  Map<String, dynamic> toJson() => toApiJson();

  EmergencyMedicalMetadata copyWith({
    String? bloodGroup,
    List<MedicationEntry>? medications,
    EmergencyContactInfo? emergencyContact,
    MedicalAidInfo? medicalAid,
    PrimaryProviderInfo? primaryProvider,
    Map<String, String>? customConditionLabels,
  }) {
    return EmergencyMedicalMetadata(
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medications: medications ?? this.medications,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalAid: medicalAid ?? this.medicalAid,
      primaryProvider: primaryProvider ?? this.primaryProvider,
      customConditionLabels: customConditionLabels ?? this.customConditionLabels,
    );
  }
}
