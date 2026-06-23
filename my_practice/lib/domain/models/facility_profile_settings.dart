import 'package:my_practice/domain/models/facility_service.dart';

class MedicalAidEntry {
  const MedicalAidEntry({
    required this.schemeKey,
    required this.name,
    this.logoPath,
  });

  final String schemeKey;
  final String name;
  final String? logoPath;

  factory MedicalAidEntry.fromJson(Map<String, dynamic> json) {
    return MedicalAidEntry(
      schemeKey: json['schemeKey'] as String? ?? '',
      name: json['name'] as String? ?? '',
      logoPath: json['logoPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'schemeKey': schemeKey,
        'name': name,
        if (logoPath != null) 'logoPath': logoPath,
      };
}

class FacilityProfileSettings {
  const FacilityProfileSettings({
    this.services = const [],
    this.medicalAids = const [],
    this.accessibility = const {},
    this.emergency = const {},
    this.ambulanceServiceTypes = const [],
    this.smarthealthFeatures = const {},
    this.booking = const {'enabled': true, 'showSlots': true},
  });

  final List<FacilityServiceEntry> services;
  final List<MedicalAidEntry> medicalAids;
  final Map<String, bool> accessibility;
  final Map<String, bool> emergency;
  final List<String> ambulanceServiceTypes;
  final Map<String, bool> smarthealthFeatures;
  final Map<String, dynamic> booking;

  factory FacilityProfileSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FacilityProfileSettings();
    return FacilityProfileSettings(
      services: FacilityServiceEntry.parseList(json['services'] as List<dynamic>?),
      medicalAids: (json['medicalAids'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((m) => MedicalAidEntry.fromJson(Map<String, dynamic>.from(m)))
          .where((m) => m.schemeKey.isNotEmpty)
          .toList(),
      accessibility: _boolMap(json['accessibility']),
      emergency: _boolMap(json['emergency']),
      ambulanceServiceTypes: (json['ambulanceServiceTypes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      smarthealthFeatures: _boolMap(json['smarthealthFeatures']),
      booking: json['booking'] is Map
          ? Map<String, dynamic>.from(json['booking'] as Map)
          : const {'enabled': true, 'showSlots': true},
    );
  }

  static Map<String, bool> _boolMap(dynamic raw) {
    if (raw is! Map) return {};
    return raw.map((k, v) => MapEntry(k.toString(), v == true));
  }

  FacilityProfileSettings copyWith({
    List<FacilityServiceEntry>? services,
    List<MedicalAidEntry>? medicalAids,
    Map<String, bool>? accessibility,
    Map<String, bool>? emergency,
    List<String>? ambulanceServiceTypes,
    Map<String, bool>? smarthealthFeatures,
    Map<String, dynamic>? booking,
  }) {
    return FacilityProfileSettings(
      services: services ?? this.services,
      medicalAids: medicalAids ?? this.medicalAids,
      accessibility: accessibility ?? this.accessibility,
      emergency: emergency ?? this.emergency,
      ambulanceServiceTypes: ambulanceServiceTypes ?? this.ambulanceServiceTypes,
      smarthealthFeatures: smarthealthFeatures ?? this.smarthealthFeatures,
      booking: booking ?? this.booking,
    );
  }

  Map<String, dynamic> toPatch({
    bool services = false,
    bool medicalAids = false,
    bool accessibility = false,
    bool emergency = false,
    bool ambulance = false,
    bool features = false,
    bool booking = false,
  }) {
    final patch = <String, dynamic>{};
    if (services) {
      patch['services'] = this.services.map((s) => s.toJson()).toList();
    }
    if (medicalAids) {
      patch['medicalAids'] = this.medicalAids.map((m) => m.toJson()).toList();
    }
    if (accessibility) {
      patch['accessibility'] = this.accessibility;
      patch['emergency'] = this.emergency;
      patch['ambulanceServiceTypes'] = ambulanceServiceTypes;
    }
    if (emergency && !accessibility) {
      patch['emergency'] = this.emergency;
    }
    if (ambulance && !accessibility) {
      patch['ambulanceServiceTypes'] = ambulanceServiceTypes;
    }
    if (features) {
      patch['smarthealthFeatures'] = smarthealthFeatures;
    }
    if (booking) {
      patch['booking'] = this.booking;
    }
    return patch;
  }
}

class MedicalAidCatalogItem {
  const MedicalAidCatalogItem({required this.schemeKey, required this.name});

  final String schemeKey;
  final String name;

  factory MedicalAidCatalogItem.fromJson(Map<String, dynamic> json) {
    return MedicalAidCatalogItem(
      schemeKey: (json['schemeKey'] ?? json['scheme_key'] ?? '') as String,
      name: (json['name'] ?? '') as String,
    );
  }
}
