import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';

part 'family_member_model.freezed.dart';
part 'family_member_model.g.dart';

EmergencyMedicalMetadata? _metadataFromApiJson(Object? json) {
  if (json == null) return null;
  if (json is Map<String, dynamic>) {
    return EmergencyMedicalMetadata.fromJson(json);
  }
  if (json is Map) {
    return EmergencyMedicalMetadata.fromJson(json.cast<String, dynamic>());
  }
  return null;
}

EmergencyMedicalMetadata? _metadataFromJson(Object? json) {
  if (json == null) return null;
  if (json is Map<String, dynamic>) {
    return EmergencyMedicalMetadata.fromJson(json);
  }
  return null;
}

Object? _metadataToJson(EmergencyMedicalMetadata? metadata) =>
    metadata?.toJson();

enum FamilyGender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other,
}

enum FamilyRelationship {
  @JsonValue('self')
  self,
  @JsonValue('spouse')
  spouse,
  @JsonValue('child')
  child,
  @JsonValue('parent')
  parent,
  @JsonValue('sibling')
  sibling,
  @JsonValue('other')
  other,
}

/// Computed age band from date of birth.
enum FamilyAgeGroup {
  infant,
  child,
  teen,
  adult,
  senior,
}

extension FamilyGenderX on FamilyGender {
  String get label => switch (this) {
        FamilyGender.male => 'Male',
        FamilyGender.female => 'Female',
        FamilyGender.other => 'Other',
      };
}

extension FamilyRelationshipX on FamilyRelationship {
  String get label => switch (this) {
        FamilyRelationship.self => 'Self',
        FamilyRelationship.spouse => 'Spouse',
        FamilyRelationship.child => 'Child',
        FamilyRelationship.parent => 'Parent',
        FamilyRelationship.sibling => 'Sibling',
        FamilyRelationship.other => 'Other',
      };

  static FamilyRelationship? fromLabel(String value) {
    for (final item in FamilyRelationship.values) {
      if (item.label == value || item.name == value.toLowerCase()) {
        return item;
      }
    }
    return null;
  }
}

extension FamilyAgeGroupX on FamilyAgeGroup {
  String get label => switch (this) {
        FamilyAgeGroup.infant => 'Infant',
        FamilyAgeGroup.child => 'Child',
        FamilyAgeGroup.teen => 'Teen',
        FamilyAgeGroup.adult => 'Adult',
        FamilyAgeGroup.senior => 'Senior',
      };
}

/// Derives age group from an ISO date-of-birth string.
FamilyAgeGroup? ageGroupFromDateOfBirth(String? dateOfBirth) {
  if (dateOfBirth == null || dateOfBirth.isEmpty) return null;

  final parsed = DateTime.tryParse(dateOfBirth);
  if (parsed == null) return null;

  final now = DateTime.now();
  var age = now.year - parsed.year;
  if (now.month < parsed.month ||
      (now.month == parsed.month && now.day < parsed.day)) {
    age--;
  }

  final months =
      (now.year - parsed.year) * 12 + now.month - parsed.month;
  if (months < 12) return FamilyAgeGroup.infant;
  if (age < 13) return FamilyAgeGroup.child;
  if (age < 18) return FamilyAgeGroup.teen;
  if (age < 65) return FamilyAgeGroup.adult;
  return FamilyAgeGroup.senior;
}

@freezed
abstract class FamilyMemberModel with _$FamilyMemberModel {
  const FamilyMemberModel._();

  const factory FamilyMemberModel({
    required String id,
    required String name,
    required String relationship,
    String? dateOfBirth,
    FamilyGender? gender,
    @Default([]) List<String> medicalConditions,
    String? allergies,
    @Default(false) bool isPrimaryAccountHolder,
    @JsonKey(fromJson: _metadataFromJson, toJson: _metadataToJson)
    EmergencyMedicalMetadata? metadata,
    DateTime? updatedAt,
  }) = _FamilyMemberModel;

  /// Age band derived from [dateOfBirth].
  FamilyAgeGroup? get ageGroup => ageGroupFromDateOfBirth(dateOfBirth);

  String? get ageGroupLabel => ageGroup?.label;

  FamilyRelationship? get relationshipEnum =>
      FamilyRelationshipX.fromLabel(relationship);

  /// Splits [name] into API first/last name fields.
  (String firstName, String? lastName) get nameParts {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return ('Member', null);
    if (parts.length == 1) return (parts.first, null);
    return (parts.first, parts.sublist(1).join(' '));
  }

  int? get ageYears {
    if (dateOfBirth == null || dateOfBirth!.isEmpty) return null;
    final parsed = DateTime.tryParse(dateOfBirth!);
    if (parsed == null) return null;
    final now = DateTime.now();
    var age = now.year - parsed.year;
    if (now.month < parsed.month ||
        (now.month == parsed.month && now.day < parsed.day)) {
      age--;
    }
    return age;
  }

  /// Cloud-safe payload — identity only; PHI stays in encrypted Health Vault.
  Map<String, dynamic> toApiPayload() {
    final (firstName, lastName) = nameParts;
    return {
      'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      'relationship': (relationshipEnum ?? FamilyRelationship.other).name,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (gender != null) 'gender': gender!.name,
      if (isPrimaryAccountHolder) 'isPrimaryAccountHolder': true,
    };
  }

  factory FamilyMemberModel.fromApiJson(Map<String, dynamic> json) {
    final first = json['firstName'] as String? ?? '';
    final last = json['lastName'] as String?;
    final name = last == null || last.isEmpty ? first : '$first $last';
    final relationshipRaw = json['relationship'] as String? ?? 'other';
    final relationship = FamilyRelationship.values
        .where((r) => r.name == relationshipRaw.toLowerCase())
        .map((r) => r.label)
        .firstOrNull ??
        relationshipRaw;
    final genderRaw = json['gender'] as String?;
    FamilyGender? gender;
    if (genderRaw != null) {
      for (final value in FamilyGender.values) {
        if (value.name == genderRaw) {
          gender = value;
          break;
        }
      }
    }
    final updatedRaw = json['updatedAt'] as String?;
    return FamilyMemberModel(
      id: json['id'] as String,
      name: name,
      relationship: relationship,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: gender,
      medicalConditions: (json['medicalConditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      allergies: json['allergies'] as String?,
      isPrimaryAccountHolder: json['isPrimaryAccountHolder'] as bool? ?? false,
      metadata: _metadataFromApiJson(json['metadata']),
      updatedAt: updatedRaw != null ? DateTime.tryParse(updatedRaw) : null,
    );
  }

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberModelFromJson(json);
}
