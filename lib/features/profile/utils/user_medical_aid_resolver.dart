import 'package:smarthealth_shep/core/auth/patient_profile.dart';
import 'package:smarthealth_shep/features/profile/utils/primary_profile_resolver.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

String? resolveUserMedicalAidSchemeKey({
  required List<FamilyMemberModel> members,
  PatientProfile? patient,
}) {
  final member = findPrimaryMember(members) ?? buildPrimaryMemberFromProfile(patient);
  final schemeKey = member.metadata?.medicalAid.schemeKey?.trim();
  if (schemeKey == null || schemeKey.isEmpty) return null;
  return schemeKey;
}
