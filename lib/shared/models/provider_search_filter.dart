import 'package:equatable/equatable.dart';

/// Local and remote provider search criteria.
class ProviderSearchFilter extends Equatable {
  const ProviderSearchFilter({
    this.query = '',
    this.categoryId,
    this.specialtyId,
    this.specialties = const {},
    this.conditions = const {},
    this.ageGroups = const {},
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.isVerified,
    this.openNow,
    this.hasQueue,
    this.availableToday,
    this.acceptsWalkIns,
    this.emergencyAvailable,
    this.queueUnder30,
    this.city,
    this.province,
    this.facilityId,
    this.facilityType,
    this.medicalAidSchemeKeys = const {},
    this.userMedicalAidSchemeKey,
  });

  final String query;
  final String? categoryId;
  final String? specialtyId;
  final Set<String> specialties;
  final Set<String> conditions;
  final Set<String> ageGroups;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final bool? isVerified;
  final bool? openNow;
  final bool? hasQueue;
  final bool? availableToday;
  final bool? acceptsWalkIns;
  final bool? emergencyAvailable;
  final bool? queueUnder30;
  final String? city;
  final String? province;
  final String? facilityId;
  final String? facilityType;
  final Set<String> medicalAidSchemeKeys;
  final String? userMedicalAidSchemeKey;

  bool get isEmpty =>
      query.trim().isEmpty &&
      categoryId == null &&
      specialtyId == null &&
      specialties.isEmpty &&
      conditions.isEmpty &&
      ageGroups.isEmpty &&
      latitude == null &&
      longitude == null &&
      radiusKm == null &&
      isVerified == null &&
      openNow == null &&
      hasQueue == null &&
      availableToday == null &&
      acceptsWalkIns == null &&
      emergencyAvailable == null &&
      queueUnder30 == null &&
      city == null &&
      province == null &&
      facilityId == null &&
      facilityType == null &&
      medicalAidSchemeKeys.isEmpty &&
      userMedicalAidSchemeKey == null;

  ProviderSearchFilter copyWith({
    String? query,
    String? categoryId,
    String? specialtyId,
    Set<String>? specialties,
    Set<String>? conditions,
    Set<String>? ageGroups,
    double? latitude,
    double? longitude,
    double? radiusKm,
    bool? isVerified,
    bool? openNow,
    bool? hasQueue,
    bool? availableToday,
    bool? acceptsWalkIns,
    bool? emergencyAvailable,
    bool? queueUnder30,
    String? city,
    String? province,
    String? facilityId,
    String? facilityType,
    Set<String>? medicalAidSchemeKeys,
    String? userMedicalAidSchemeKey,
  }) {
    return ProviderSearchFilter(
      query: query ?? this.query,
      categoryId: categoryId ?? this.categoryId,
      specialtyId: specialtyId ?? this.specialtyId,
      specialties: specialties ?? this.specialties,
      conditions: conditions ?? this.conditions,
      ageGroups: ageGroups ?? this.ageGroups,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      isVerified: isVerified ?? this.isVerified,
      openNow: openNow ?? this.openNow,
      hasQueue: hasQueue ?? this.hasQueue,
      availableToday: availableToday ?? this.availableToday,
      acceptsWalkIns: acceptsWalkIns ?? this.acceptsWalkIns,
      emergencyAvailable: emergencyAvailable ?? this.emergencyAvailable,
      queueUnder30: queueUnder30 ?? this.queueUnder30,
      city: city ?? this.city,
      province: province ?? this.province,
      facilityId: facilityId ?? this.facilityId,
      facilityType: facilityType ?? this.facilityType,
      medicalAidSchemeKeys: medicalAidSchemeKeys ?? this.medicalAidSchemeKeys,
      userMedicalAidSchemeKey:
          userMedicalAidSchemeKey ?? this.userMedicalAidSchemeKey,
    );
  }

  @override
  List<Object?> get props => [
        query,
        categoryId,
        specialtyId,
        specialties,
        conditions,
        ageGroups,
        latitude,
        longitude,
        radiusKm,
        isVerified,
        openNow,
        hasQueue,
        availableToday,
        acceptsWalkIns,
        emergencyAvailable,
        queueUnder30,
        city,
        province,
        facilityId,
        facilityType,
        medicalAidSchemeKeys,
        userMedicalAidSchemeKey,
      ];
}
