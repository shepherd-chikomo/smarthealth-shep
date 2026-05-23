import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_member_model.freezed.dart';
part 'family_member_model.g.dart';

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
  }) = _FamilyMemberModel;

  /// Age band derived from [dateOfBirth].
  FamilyAgeGroup? get ageGroup => ageGroupFromDateOfBirth(dateOfBirth);

  String? get ageGroupLabel => ageGroup?.label;

  FamilyRelationship? get relationshipEnum =>
      FamilyRelationshipX.fromLabel(relationship);

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberModelFromJson(json);
}
