// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmergencyServiceModel _$EmergencyServiceModelFromJson(
  Map<String, dynamic> json,
) => _EmergencyServiceModel(
  id: json['id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  whatsapp: json['whatsapp'] as String?,
  is24Hours: json['is24Hours'] as bool? ?? false,
);

Map<String, dynamic> _$EmergencyServiceModelToJson(
  _EmergencyServiceModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'whatsapp': instance.whatsapp,
  'is24Hours': instance.is24Hours,
};
