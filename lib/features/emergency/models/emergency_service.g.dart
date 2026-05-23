// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmergencyService _$EmergencyServiceFromJson(Map<String, dynamic> json) =>
    _EmergencyService(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: $enumDecode(_$EmergencyServiceKindEnumMap, json['kind']),
      phone: json['phone'] as String,
      nearestDistanceKm: (json['nearestDistanceKm'] as num).toDouble(),
      nearestProviderName: json['nearestProviderName'] as String?,
      nearestLatitude: (json['nearestLatitude'] as num?)?.toDouble(),
      nearestLongitude: (json['nearestLongitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$EmergencyServiceToJson(_EmergencyService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'kind': _$EmergencyServiceKindEnumMap[instance.kind]!,
      'phone': instance.phone,
      'nearestDistanceKm': instance.nearestDistanceKm,
      'nearestProviderName': instance.nearestProviderName,
      'nearestLatitude': instance.nearestLatitude,
      'nearestLongitude': instance.nearestLongitude,
    };

const _$EmergencyServiceKindEnumMap = {
  EmergencyServiceKind.ambulance: 'ambulance',
  EmergencyServiceKind.police: 'police',
  EmergencyServiceKind.fireRescue: 'fireRescue',
  EmergencyServiceKind.rescueTeam: 'rescueTeam',
};
