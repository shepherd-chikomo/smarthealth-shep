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
  categoryId: json['categoryId'] as String,
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
    };
