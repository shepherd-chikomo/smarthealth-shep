// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FamilyMemberModel _$FamilyMemberModelFromJson(Map<String, dynamic> json) =>
    _FamilyMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      dateOfBirth: json['dateOfBirth'] as String?,
    );

Map<String, dynamic> _$FamilyMemberModelToJson(_FamilyMemberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'relationship': instance.relationship,
      'dateOfBirth': instance.dateOfBirth,
    };
