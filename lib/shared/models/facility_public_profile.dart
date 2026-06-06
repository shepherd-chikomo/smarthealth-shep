import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/models/working_hours_entry.dart';

class FacilityServiceItem {
  const FacilityServiceItem({
    required this.id,
    required this.name,
    required this.iconKey,
    this.key,
    this.isCustom = false,
  });

  final String id;
  final String? key;
  final String name;
  final String iconKey;
  final bool isCustom;

  factory FacilityServiceItem.fromJson(Map<String, dynamic> json) {
    return FacilityServiceItem(
      id: json['id'] as String,
      key: json['key'] as String?,
      name: json['name'] as String,
      iconKey: json['iconKey'] as String? ?? 'custom',
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
}

class FacilityMedicalAidItem {
  const FacilityMedicalAidItem({
    required this.schemeKey,
    required this.name,
    this.logoUrl,
  });

  final String schemeKey;
  final String name;
  final String? logoUrl;

  factory FacilityMedicalAidItem.fromJson(Map<String, dynamic> json) {
    return FacilityMedicalAidItem(
      schemeKey: json['schemeKey'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
    );
  }
}

class FacilityAccessibilityInfo {
  const FacilityAccessibilityInfo({
    this.wheelchair,
    this.parking,
    this.elevator,
    this.babyFacilities,
  });

  final bool? wheelchair;
  final bool? parking;
  final bool? elevator;
  final bool? babyFacilities;

  factory FacilityAccessibilityInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FacilityAccessibilityInfo();
    return FacilityAccessibilityInfo(
      wheelchair: json['wheelchair'] as bool?,
      parking: json['parking'] as bool?,
      elevator: json['elevator'] as bool?,
      babyFacilities: json['babyFacilities'] as bool?,
    );
  }

  bool get hasAny =>
      wheelchair == true ||
      parking == true ||
      elevator == true ||
      babyFacilities == true;
}

class FacilityEmergencyInfo {
  const FacilityEmergencyInfo({
    this.department,
    this.ambulance,
    this.trauma,
    this.icu,
    this.is24Hour,
  });

  final bool? department;
  final bool? ambulance;
  final bool? trauma;
  final bool? icu;
  final bool? is24Hour;

  factory FacilityEmergencyInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FacilityEmergencyInfo();
    return FacilityEmergencyInfo(
      department: json['department'] as bool?,
      ambulance: json['ambulance'] as bool?,
      trauma: json['trauma'] as bool?,
      icu: json['icu'] as bool?,
      is24Hour: json['is24Hour'] as bool?,
    );
  }
}

class FacilityInfoRow {
  const FacilityInfoRow({
    this.waitTimeMinutes,
    this.emergencyAvailable,
    this.wheelchairAccessible,
    this.parkingAvailable,
  });

  final int? waitTimeMinutes;
  final bool? emergencyAvailable;
  final bool? wheelchairAccessible;
  final bool? parkingAvailable;

  factory FacilityInfoRow.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FacilityInfoRow();
    return FacilityInfoRow(
      waitTimeMinutes: (json['waitTimeMinutes'] as num?)?.toInt(),
      emergencyAvailable: json['emergencyAvailable'] as bool?,
      wheelchairAccessible: json['wheelchairAccessible'] as bool?,
      parkingAvailable: json['parkingAvailable'] as bool?,
    );
  }

  bool get hasAny =>
      waitTimeMinutes != null ||
      emergencyAvailable == true ||
      wheelchairAccessible == true ||
      parkingAvailable == true;
}

class FacilityBookingInfo {
  const FacilityBookingInfo({
    this.enabled = false,
    this.showSlots = false,
    this.slotDurationMinutes = 30,
    this.maxAdvanceDays = 30,
    this.cancellationPolicy,
  });

  final bool enabled;
  final bool showSlots;
  final int slotDurationMinutes;
  final int maxAdvanceDays;
  final String? cancellationPolicy;

  factory FacilityBookingInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FacilityBookingInfo();
    return FacilityBookingInfo(
      enabled: json['enabled'] as bool? ?? false,
      showSlots: json['showSlots'] as bool? ?? false,
      slotDurationMinutes: (json['slotDurationMinutes'] as num?)?.toInt() ?? 30,
      maxAdvanceDays: (json['maxAdvanceDays'] as num?)?.toInt() ?? 30,
      cancellationPolicy: json['cancellationPolicy'] as String?,
    );
  }
}

class FacilitySmarthealthFeatures {
  const FacilitySmarthealthFeatures({
    this.verified = false,
    this.onlineBooking,
    this.digitalPrescriptions,
    this.labResults,
    this.patientPortal,
    this.telehealth,
  });

  final bool verified;
  final bool? onlineBooking;
  final bool? digitalPrescriptions;
  final bool? labResults;
  final bool? patientPortal;
  final bool? telehealth;

  factory FacilitySmarthealthFeatures.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FacilitySmarthealthFeatures();
    return FacilitySmarthealthFeatures(
      verified: json['verified'] as bool? ?? false,
      onlineBooking: json['onlineBooking'] as bool?,
      digitalPrescriptions: json['digitalPrescriptions'] as bool?,
      labResults: json['labResults'] as bool?,
      patientPortal: json['patientPortal'] as bool?,
      telehealth: json['telehealth'] as bool?,
    );
  }

  bool get hasFeatureChips =>
      onlineBooking == true ||
      digitalPrescriptions == true ||
      labResults == true ||
      patientPortal == true ||
      telehealth == true;
}

class FacilityOperatingHour {
  const FacilityOperatingHour({
    required this.dayOfWeek,
    required this.label,
    this.opensAt,
    this.closesAt,
    this.isClosed = false,
    this.is24Hours = false,
  });

  final int dayOfWeek;
  final String label;
  final String? opensAt;
  final String? closesAt;
  final bool isClosed;
  final bool is24Hours;

  factory FacilityOperatingHour.fromJson(Map<String, dynamic> json) {
    return FacilityOperatingHour(
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      label: json['label'] as String,
      opensAt: json['opensAt'] as String?,
      closesAt: json['closesAt'] as String?,
      isClosed: json['isClosed'] as bool? ?? false,
      is24Hours: json['is24Hours'] as bool? ?? false,
    );
  }

  WorkingHoursEntry toWorkingHoursEntry() {
    if (is24Hours) {
      return WorkingHoursEntry(day: label, hours: '24 Hours');
    }
    if (isClosed) {
      return WorkingHoursEntry(day: label, isClosed: true);
    }
    final range = [
      if (opensAt != null) opensAt,
      if (closesAt != null) closesAt,
    ].join(' – ');
    return WorkingHoursEntry(day: label, hours: range.isEmpty ? null : range);
  }
}

class FacilityPublicProfile {
  const FacilityPublicProfile({
    required this.facility,
    this.logoUrl,
    this.openStatus = 'closed',
    this.isOpenNow = false,
    this.operatingHours = const [],
    this.services = const [],
    this.medicalAids = const [],
    this.accessibility = const FacilityAccessibilityInfo(),
    this.emergency = const FacilityEmergencyInfo(),
    this.facilityInfo = const FacilityInfoRow(),
    this.smarthealthFeatures = const FacilitySmarthealthFeatures(),
    this.booking = const FacilityBookingInfo(),
  });

  final FacilityModel facility;
  final String? logoUrl;
  final String openStatus;
  final bool isOpenNow;
  final List<FacilityOperatingHour> operatingHours;
  final List<FacilityServiceItem> services;
  final List<FacilityMedicalAidItem> medicalAids;
  final FacilityAccessibilityInfo accessibility;
  final FacilityEmergencyInfo emergency;
  final FacilityInfoRow facilityInfo;
  final FacilitySmarthealthFeatures smarthealthFeatures;
  final FacilityBookingInfo booking;

  factory FacilityPublicProfile.fromJson(Map<String, dynamic> json) {
    final facilityJson = Map<String, dynamic>.from(json['facility'] as Map);
    return FacilityPublicProfile(
      facility: FacilityModel.fromJson(facilityJson),
      logoUrl: json['logoUrl'] as String?,
      openStatus: json['openStatus'] as String? ?? 'closed',
      isOpenNow: json['isOpenNow'] as bool? ?? false,
      operatingHours: (json['operatingHours'] as List<dynamic>? ?? [])
          .map((e) => FacilityOperatingHour.fromJson(e as Map<String, dynamic>))
          .toList(),
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => FacilityServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      medicalAids: (json['medicalAids'] as List<dynamic>? ?? [])
          .map((e) => FacilityMedicalAidItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      accessibility: FacilityAccessibilityInfo.fromJson(
        json['accessibility'] as Map<String, dynamic>?,
      ),
      emergency: FacilityEmergencyInfo.fromJson(
        json['emergency'] as Map<String, dynamic>?,
      ),
      facilityInfo: FacilityInfoRow.fromJson(
        json['facilityInfo'] as Map<String, dynamic>?,
      ),
      smarthealthFeatures: FacilitySmarthealthFeatures.fromJson(
        json['smarthealthFeatures'] as Map<String, dynamic>?,
      ),
      booking: FacilityBookingInfo.fromJson(
        json['booking'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'facility': facility.toJson(),
        'logoUrl': logoUrl,
        'openStatus': openStatus,
        'isOpenNow': isOpenNow,
        'operatingHours': operatingHours
            .map((h) => {
                  'dayOfWeek': h.dayOfWeek,
                  'label': h.label,
                  'opensAt': h.opensAt,
                  'closesAt': h.closesAt,
                  'isClosed': h.isClosed,
                  'is24Hours': h.is24Hours,
                })
            .toList(),
        'services': services
            .map((s) => {
                  'id': s.id,
                  'key': s.key,
                  'name': s.name,
                  'iconKey': s.iconKey,
                  'isCustom': s.isCustom,
                })
            .toList(),
        'medicalAids': medicalAids
            .map((m) => {
                  'schemeKey': m.schemeKey,
                  'name': m.name,
                  'logoUrl': m.logoUrl,
                })
            .toList(),
        'accessibility': {
          'wheelchair': accessibility.wheelchair,
          'parking': accessibility.parking,
          'elevator': accessibility.elevator,
          'babyFacilities': accessibility.babyFacilities,
        },
        'emergency': {
          'department': emergency.department,
          'ambulance': emergency.ambulance,
          'trauma': emergency.trauma,
          'icu': emergency.icu,
          'is24Hour': emergency.is24Hour,
        },
        'facilityInfo': {
          'waitTimeMinutes': facilityInfo.waitTimeMinutes,
          'emergencyAvailable': facilityInfo.emergencyAvailable,
          'wheelchairAccessible': facilityInfo.wheelchairAccessible,
          'parkingAvailable': facilityInfo.parkingAvailable,
        },
        'smarthealthFeatures': {
          'verified': smarthealthFeatures.verified,
          'onlineBooking': smarthealthFeatures.onlineBooking,
          'digitalPrescriptions': smarthealthFeatures.digitalPrescriptions,
          'labResults': smarthealthFeatures.labResults,
          'patientPortal': smarthealthFeatures.patientPortal,
          'telehealth': smarthealthFeatures.telehealth,
        },
        'booking': {
          'enabled': booking.enabled,
          'showSlots': booking.showSlots,
          'slotDurationMinutes': booking.slotDurationMinutes,
          'maxAdvanceDays': booking.maxAdvanceDays,
          'cancellationPolicy': booking.cancellationPolicy,
        },
      };
}

class FacilitySpecialistSummary {
  const FacilitySpecialistSummary({
    required this.id,
    required this.name,
    this.specialty,
    this.photoUrl,
    this.nextAvailableAt,
  });

  final String id;
  final String name;
  final String? specialty;
  final String? photoUrl;
  final String? nextAvailableAt;

  factory FacilitySpecialistSummary.fromJson(Map<String, dynamic> json) {
    return FacilitySpecialistSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String?,
      photoUrl: json['photoUrl'] as String?,
      nextAvailableAt: json['nextAvailableAt'] as String?,
    );
  }
}

class FacilityAvailabilitySlot {
  const FacilityAvailabilitySlot({
    required this.time,
    required this.scheduledAt,
    required this.serviceId,
    required this.serviceName,
    required this.providerId,
    required this.providerName,
  });

  final String time;
  final String scheduledAt;
  final String? serviceId;
  final String serviceName;
  final String providerId;
  final String providerName;

  factory FacilityAvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return FacilityAvailabilitySlot(
      time: json['time'] as String,
      scheduledAt: json['scheduledAt'] as String,
      serviceId: json['serviceId'] as String?,
      serviceName: json['serviceName'] as String? ?? 'Appointment',
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String? ?? '',
    );
  }
}

class FacilityAvailabilityDay {
  const FacilityAvailabilityDay({
    required this.label,
    required this.date,
    required this.slots,
  });

  final String label;
  final String date;
  final List<FacilityAvailabilitySlot> slots;

  factory FacilityAvailabilityDay.fromJson(Map<String, dynamic> json) {
    return FacilityAvailabilityDay(
      label: json['label'] as String,
      date: json['date'] as String,
      slots: (json['slots'] as List<dynamic>? ?? [])
          .map((e) => FacilityAvailabilitySlot.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
