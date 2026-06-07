// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_hub_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmergencyHubData _$EmergencyHubDataFromJson(Map<String, dynamic> json) =>
    _EmergencyHubData(
      services: (json['services'] as List<dynamic>)
          .map((e) => EmergencyService.fromJson(e as Map<String, dynamic>))
          .toList(),
      facilities: (json['facilities'] as List<dynamic>)
          .map((e) => EmergencyFacility.fromJson(e as Map<String, dynamic>))
          .toList(),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      locationRequired: json['locationRequired'] as bool? ?? false,
    );

Map<String, dynamic> _$EmergencyHubDataToJson(_EmergencyHubData instance) =>
    <String, dynamic>{
      'services': instance.services,
      'facilities': instance.facilities,
      'cachedAt': instance.cachedAt.toIso8601String(),
      'locationRequired': instance.locationRequired,
    };
