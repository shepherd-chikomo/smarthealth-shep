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
      gender: $enumDecodeNullable(_$FamilyGenderEnumMap, json['gender']),
      medicalConditions:
          (json['medicalConditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      allergies: json['allergies'] as String?,
      isPrimaryAccountHolder: json['isPrimaryAccountHolder'] as bool? ?? false,
    );

Map<String, dynamic> _$FamilyMemberModelToJson(_FamilyMemberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'relationship': instance.relationship,
      'dateOfBirth': instance.dateOfBirth,
      'gender': _$FamilyGenderEnumMap[instance.gender],
      'medicalConditions': instance.medicalConditions,
      'allergies': instance.allergies,
      'isPrimaryAccountHolder': instance.isPrimaryAccountHolder,
    };

const _$FamilyGenderEnumMap = {
  FamilyGender.male: 'male',
  FamilyGender.female: 'female',
  FamilyGender.other: 'other',
};
