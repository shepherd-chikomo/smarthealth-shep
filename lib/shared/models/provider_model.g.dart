// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProviderModel _$ProviderModelFromJson(
  Map<String, dynamic> json,
) => _ProviderModel(
  id: json['id'] as String,
  name: json['name'] as String,
  categoryId: json['categoryId'] as String? ?? 'general-practice',
  specialty: json['specialty'] as String?,
  specialtyId: json['specialtyId'] as String?,
  facilityName: json['facilityName'] as String?,
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
  hours: json['hours'] as String?,
  imageUrl: json['imageUrl'] as String?,
  heroImageUrl: json['heroImageUrl'] as String?,
  isVerified: json['isVerified'] as bool? ?? false,
  mdpczNumber: json['mdpczNumber'] as String?,
  about: json['about'] as String?,
  services:
      (json['services'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  weeklyHours:
      (json['weeklyHours'] as List<dynamic>?)
          ?.map((e) => WorkingHoursEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  conditions:
      (json['conditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  ageGroups:
      (json['ageGroups'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isOpenNow: json['isOpenNow'] as bool?,
  isClosingSoon: json['isClosingSoon'] as bool?,
  emergencyAvailable: json['emergencyAvailable'] as bool?,
  acceptsWalkIns: json['acceptsWalkIns'] as bool?,
  hasQueue: json['hasQueue'] as bool?,
  queueLength: (json['queueLength'] as num?)?.toInt(),
  waitEstimateMinutes: (json['waitEstimateMinutes'] as num?)?.toInt(),
  nextAvailableSlot: json['nextAvailableSlot'] == null
      ? null
      : DateTime.parse(json['nextAvailableSlot'] as String),
  availableToday: json['availableToday'] as bool?,
  rating: (json['rating'] as num?)?.toDouble(),
  reviewCount: (json['reviewCount'] as num?)?.toInt(),
  verificationSource: json['verificationSource'] as String?,
  isClaimed: json['isClaimed'] as bool? ?? false,
);

Map<String, dynamic> _$ProviderModelToJson(_ProviderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'categoryId': instance.categoryId,
      'specialty': instance.specialty,
      'specialtyId': instance.specialtyId,
      'facilityName': instance.facilityName,
      'address': instance.address,
      'phone': instance.phone,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'distanceKm': instance.distanceKm,
      'hours': instance.hours,
      'imageUrl': instance.imageUrl,
      'heroImageUrl': instance.heroImageUrl,
      'isVerified': instance.isVerified,
      'mdpczNumber': instance.mdpczNumber,
      'about': instance.about,
      'services': instance.services,
      'weeklyHours': instance.weeklyHours,
      'conditions': instance.conditions,
      'ageGroups': instance.ageGroups,
      'isOpenNow': instance.isOpenNow,
      'isClosingSoon': instance.isClosingSoon,
      'emergencyAvailable': instance.emergencyAvailable,
      'acceptsWalkIns': instance.acceptsWalkIns,
      'hasQueue': instance.hasQueue,
      'queueLength': instance.queueLength,
      'waitEstimateMinutes': instance.waitEstimateMinutes,
      'nextAvailableSlot': instance.nextAvailableSlot?.toIso8601String(),
      'availableToday': instance.availableToday,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'verificationSource': instance.verificationSource,
      'isClaimed': instance.isClaimed,
    };
