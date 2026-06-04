// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FacilityModel _$FacilityModelFromJson(Map<String, dynamic> json) =>
    _FacilityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      facilityType: json['facilityType'] as String,
      description: json['description'] as String?,
      addressLine1: json['addressLine1'] as String?,
      city: json['city'] as String,
      province: json['province'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      isVerified: json['isVerified'] as bool? ?? false,
      logoPath: json['logoPath'] as String?,
    );

Map<String, dynamic> _$FacilityModelToJson(_FacilityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'facilityType': instance.facilityType,
      'description': instance.description,
      'addressLine1': instance.addressLine1,
      'city': instance.city,
      'province': instance.province,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'distanceKm': instance.distanceKm,
      'isVerified': instance.isVerified,
      'logoPath': instance.logoPath,
    };
