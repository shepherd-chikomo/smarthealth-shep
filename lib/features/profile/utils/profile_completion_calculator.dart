import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/auth/patient_profile.dart';
import 'package:smarthealth_shep/features/profile/utils/profile_none_sentinel.dart';
import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

enum ProfileCompletionBand { low, medium, high, complete }

class ProfileCompletionItem {
  const ProfileCompletionItem({
    required this.id,
    required this.label,
    required this.isComplete,
  });

  final String id;
  final String label;
  final bool isComplete;
}

class ProfileCompletionResult {
  const ProfileCompletionResult({
    required this.percentage,
    required this.items,
    required this.band,
  });

  final int percentage;
  final List<ProfileCompletionItem> items;
  final ProfileCompletionBand band;

  List<ProfileCompletionItem> get missingItems =>
      items.where((i) => !i.isComplete).toList();
}

ProfileCompletionResult calculateProfileCompletion({
  required FamilyMemberModel member,
  PatientProfile? patient,
}) {
  final metadata = member.metadata ?? const EmergencyMedicalMetadata();
  final hasName = member.name.trim().isNotEmpty ||
      (patient?.displayName?.trim().isNotEmpty ?? false) ||
      (patient?.firstName?.trim().isNotEmpty ?? false);
  final hasDob = (member.dateOfBirth?.isNotEmpty ?? false) ||
      (patient?.dateOfBirth?.isNotEmpty ?? false);
  final hasGender = member.gender != null || patient?.gender != null;
  final hasBloodGroup =
      metadata.bloodGroup != null && metadata.bloodGroup!.trim().isNotEmpty;
  final hasAllergies = allergiesSectionComplete(member.allergies);
  final hasConditions = conditionsSectionComplete(member.medicalConditions);
  final hasEmergencyContact = metadata.emergencyContact.hasAny;
  final hasMedicalAid = medicalAidSectionComplete(metadata.medicalAid);
  final hasMedications = metadata.medications.isNotEmpty;
  final hasPrimaryProvider =
      primaryProviderSectionComplete(metadata.primaryProvider);

  final items = <ProfileCompletionItem>[
    ProfileCompletionItem(id: 'name', label: 'Full name', isComplete: hasName),
    ProfileCompletionItem(
      id: 'dob',
      label: 'Date of birth',
      isComplete: hasDob,
    ),
    ProfileCompletionItem(
      id: 'gender',
      label: 'Gender',
      isComplete: hasGender,
    ),
    ProfileCompletionItem(
      id: 'blood_group',
      label: 'Blood group',
      isComplete: hasBloodGroup,
    ),
    ProfileCompletionItem(
      id: 'allergies',
      label: 'Allergies',
      isComplete: hasAllergies,
    ),
    ProfileCompletionItem(
      id: 'conditions',
      label: 'Medical conditions',
      isComplete: hasConditions,
    ),
    ProfileCompletionItem(
      id: 'emergency_contact',
      label: 'Emergency contact',
      isComplete: hasEmergencyContact,
    ),
    ProfileCompletionItem(
      id: 'medical_aid',
      label: 'Medical aid',
      isComplete: hasMedicalAid,
    ),
    ProfileCompletionItem(
      id: 'medications',
      label: 'Medications',
      isComplete: hasMedications,
    ),
    ProfileCompletionItem(
      id: 'primary_provider',
      label: 'Primary provider',
      isComplete: hasPrimaryProvider,
    ),
  ];

  final completed = items.where((i) => i.isComplete).length;
  final percentage =
      items.isEmpty ? 0 : ((completed / items.length) * 100).round();

  return ProfileCompletionResult(
    percentage: percentage,
    items: items,
    band: bandForPercentage(percentage),
  );
}

ProfileCompletionBand bandForPercentage(int percentage) {
  if (percentage >= 100) return ProfileCompletionBand.complete;
  if (percentage >= 81) return ProfileCompletionBand.high;
  if (percentage >= 41) return ProfileCompletionBand.medium;
  return ProfileCompletionBand.low;
}

Color completionBandColor(ProfileCompletionBand band, BuildContext context) {
  return switch (band) {
    ProfileCompletionBand.low => const Color(0xFFE65100),
    ProfileCompletionBand.medium => const Color(0xFF1565C0),
    ProfileCompletionBand.high => const Color(0xFF2E7D32),
    ProfileCompletionBand.complete => const Color(0xFF2E7D32),
  };
}
