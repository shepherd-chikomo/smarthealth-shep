import 'package:smarthealth_shep/core/auth/patient_profile.dart';
import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

FamilyMemberModel? findPrimaryMember(List<FamilyMemberModel> members) {
  for (final member in members) {
    if (member.isPrimaryAccountHolder) return member;
  }
  for (final member in members) {
    if (member.relationshipEnum == FamilyRelationship.self) return member;
  }
  return members.isNotEmpty ? members.first : null;
}

FamilyMemberModel buildPrimaryMemberFromProfile(PatientProfile? profile) {
  final display = profile?.displayName?.trim();
  final first = profile?.firstName?.trim();
  final last = profile?.lastName?.trim();
  final name = (display != null && display.isNotEmpty)
      ? display
      : [
          if (first != null && first.isNotEmpty) first,
          if (last != null && last.isNotEmpty) last,
        ].join(' ').trim();

  return FamilyMemberModel(
    id: '',
    name: name.isEmpty ? 'Patient' : name,
    relationship: FamilyRelationship.self.label,
    dateOfBirth: profile?.dateOfBirth,
    gender: _mapGender(profile?.gender),
    isPrimaryAccountHolder: true,
    metadata: const EmergencyMedicalMetadata(),
  );
}

FamilyGender? _mapGender(String? raw) {
  if (raw == null) return null;
  switch (raw.toLowerCase()) {
    case 'male':
      return FamilyGender.male;
    case 'female':
      return FamilyGender.female;
    default:
      return FamilyGender.other;
  }
}
