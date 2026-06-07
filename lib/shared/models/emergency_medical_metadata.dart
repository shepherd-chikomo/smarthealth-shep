bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

bool _isUuid(String? value) =>
    value != null && _uuidPattern.hasMatch(value.trim());

class MedicationEntry {
  const MedicationEntry({
    required this.name,
    this.frequency,
    this.id,
    this.reminderEnabled = false,
    this.reminderTimes = const [],
    this.dosesPerDay,
    this.quantity,
  });

  final String name;
  final String? frequency;
  final String? id;
  final bool reminderEnabled;
  final List<String> reminderTimes;
  final int? dosesPerDay;
  final String? quantity;

  factory MedicationEntry.fromJson(Map<String, dynamic> json) {
    final timesRaw = json['reminderTimes'] as List<dynamic>? ?? const [];
    return MedicationEntry(
      name: json['name'] as String? ?? '',
      frequency: json['frequency'] as String?,
      id: json['id'] as String?,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderTimes: timesRaw.map((e) => e.toString()).toList(),
      dosesPerDay: json['dosesPerDay'] as int?,
      quantity: json['quantity'] as String?,
    );
  }

  /// Cloud-safe payload (name and frequency only).
  Map<String, dynamic> toApiJson() {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return const {};
    return {
      'name': trimmedName,
      if (frequency != null && frequency!.isNotEmpty) 'frequency': frequency,
    };
  }

  /// Device-local serialization including reminder fields.
  Map<String, dynamic> toLocalJson() {
    final api = toApiJson();
    if (api.isEmpty) return const {};
    return {
      ...api,
      if (id != null && id!.isNotEmpty) 'id': id,
      if (reminderEnabled) 'reminderEnabled': true,
      if (reminderTimes.isNotEmpty) 'reminderTimes': reminderTimes,
      if (dosesPerDay != null) 'dosesPerDay': dosesPerDay,
      if (quantity != null && quantity!.isNotEmpty) 'quantity': quantity,
    };
  }

  Map<String, dynamic> toJson() => toApiJson();

  MedicationEntry copyWith({
    String? name,
    String? frequency,
    String? id,
    bool? reminderEnabled,
    List<String>? reminderTimes,
    int? dosesPerDay,
    String? quantity,
  }) {
    return MedicationEntry(
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      id: id ?? this.id,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      dosesPerDay: dosesPerDay ?? this.dosesPerDay,
      quantity: quantity ?? this.quantity,
    );
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

  EmergencyContactInfo copyWith({
    String? name,
    String? relationship,
    String? phone,
  }) {
    return EmergencyContactInfo(
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
    );
  }
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
    this.emergencyContacts = const [],
    this.medicalAid = const MedicalAidInfo(),
    this.primaryProvider = const PrimaryProviderInfo(),
    this.customConditionLabels = const {},
  });

  static const int maxEmergencyContacts = 5;

  final String? bloodGroup;
  final List<MedicationEntry> medications;
  final EmergencyContactInfo emergencyContact;
  final List<EmergencyContactInfo> emergencyContacts;
  final MedicalAidInfo medicalAid;
  final PrimaryProviderInfo primaryProvider;
  final Map<String, String> customConditionLabels;

  /// Primary contact for backward compatibility — first list entry or legacy field.
  EmergencyContactInfo get primaryEmergencyContact {
    if (emergencyContacts.isNotEmpty) return emergencyContacts.first;
    return emergencyContact;
  }

  bool get hasAnyEmergencyContact =>
      emergencyContact.hasAny ||
      emergencyContacts.any((contact) => contact.hasAny);

  factory EmergencyMedicalMetadata.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const EmergencyMedicalMetadata();
    final medsRaw = json['medications'] as List<dynamic>? ?? const [];
    final contactsRaw = json['emergencyContacts'] as List<dynamic>? ?? const [];
    final parsedContacts = contactsRaw
        .whereType<Map<String, dynamic>>()
        .map(EmergencyContactInfo.fromJson)
        .where((c) => c.hasAny)
        .take(maxEmergencyContacts)
        .toList();
    final legacyContact = EmergencyContactInfo.fromJson(
      json['emergencyContact'] as Map<String, dynamic>?,
    );
    return EmergencyMedicalMetadata(
      bloodGroup: json['bloodGroup'] as String?,
      medications: medsRaw
          .whereType<Map<String, dynamic>>()
          .map(MedicationEntry.fromJson)
          .where((m) => m.name.isNotEmpty)
          .toList(),
      emergencyContact: legacyContact,
      emergencyContacts: parsedContacts.isNotEmpty
          ? parsedContacts
          : (legacyContact.hasAny ? [legacyContact] : const []),
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
          .map((m) => m.toApiJson())
          .where((json) => json.isNotEmpty)
          .toList(),
    };
    if (_hasText(bloodGroup)) {
      json['bloodGroup'] = bloodGroup!.trim();
    }
    final primary = primaryEmergencyContact;
    if (primary.hasAny) {
      json['emergencyContact'] = primary.toApiJson();
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

  /// Device-local serialization — includes multi-contacts and reminder fields.
  Map<String, dynamic> toLocalJson() {
    final json = toApiJson();
    if (emergencyContacts.isNotEmpty) {
      json['emergencyContacts'] = emergencyContacts
          .take(maxEmergencyContacts)
          .map((c) => c.toJson())
          .where((c) => c.isNotEmpty)
          .toList();
    }
    json['medications'] = medications
        .map((m) => m.toLocalJson())
        .where((json) => json.isNotEmpty)
        .toList();
    return json;
  }

  Map<String, dynamic> toJson() => toApiJson();

  EmergencyMedicalMetadata copyWith({
    String? bloodGroup,
    List<MedicationEntry>? medications,
    EmergencyContactInfo? emergencyContact,
    List<EmergencyContactInfo>? emergencyContacts,
    MedicalAidInfo? medicalAid,
    PrimaryProviderInfo? primaryProvider,
    Map<String, String>? customConditionLabels,
  }) {
    return EmergencyMedicalMetadata(
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medications: medications ?? this.medications,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      medicalAid: medicalAid ?? this.medicalAid,
      primaryProvider: primaryProvider ?? this.primaryProvider,
      customConditionLabels: customConditionLabels ?? this.customConditionLabels,
    );
  }
}
