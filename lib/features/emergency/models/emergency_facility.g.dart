// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_facility.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmergencyFacility _$EmergencyFacilityFromJson(Map<String, dynamic> json) =>
    _EmergencyFacility(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      phone: json['phone'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      is24Hours: json['is24Hours'] as bool? ?? true,
      source: $enumDecodeNullable(
        _$EmergencyFacilitySourceEnumMap,
        json['source'],
      ),
      referralLabel: json['referralLabel'] as String?,
      pendingVerification: json['pendingVerification'] as bool? ?? false,
    );

Map<String, dynamic> _$EmergencyFacilityToJson(_EmergencyFacility instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'distanceKm': instance.distanceKm,
      'phone': instance.phone,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'is24Hours': instance.is24Hours,
      'source': _$EmergencyFacilitySourceEnumMap[instance.source],
      'referralLabel': instance.referralLabel,
      'pendingVerification': instance.pendingVerification,
    };

const _$EmergencyFacilitySourceEnumMap = {
  EmergencyFacilitySource.emergencyDirectory: 'emergency_directory',
  EmergencyFacilitySource.governmentHospital: 'government_hospital',
  EmergencyFacilitySource.profileEmergency: 'profile_emergency',
};
