import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/auth/patient_profile.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/features/family/data/family_repository.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_provider.dart';
import 'package:smarthealth_shep/features/profile/widgets/profile_member_switcher.dart';
import 'package:smarthealth_shep/features/profile/utils/profile_completion_calculator.dart';
import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

class HomeMedicalSummary {
  const HomeMedicalSummary({
    required this.member,
    required this.completion,
    this.patient,
  });

  final FamilyMemberModel member;
  final ProfileCompletionResult completion;
  final PatientProfile? patient;

  String get displayName {
    final name = member.name.trim();
    if (name.isNotEmpty) return name;
    return patient?.greetingName ?? patient?.displayName ?? 'Patient';
  }

  String? get bloodGroup => member.metadata?.bloodGroup;

  int? get ageYears => member.ageYears;

  String? get genderLabel => member.gender?.label;

  String? get allergies => member.allergies;

  List<String> get conditions => member.medicalConditions;

  bool get hasAllergies =>
      allergies != null && allergies!.trim().isNotEmpty;

  EmergencyMedicalMetadata get metadata =>
      member.metadata ?? const EmergencyMedicalMetadata();
}

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository(dio: ref.watch(dioProvider));
});

/// One-time remote pull when the app loads family data.
final familyMembersBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.watch(familyRepositoryProvider).syncFromRemote();
});

final familyMembersProvider =
    FutureProvider<List<FamilyMemberModel>>((ref) async {
  await ref.watch(familyMembersBootstrapProvider.future);
  final repository = ref.watch(familyRepositoryProvider);
  return repository.loadMembers(syncRemote: false);
});

void invalidateFamilyProfileProviders(
  WidgetRef ref, {
  bool resyncRemote = false,
}) {
  if (resyncRemote) {
    ref.invalidate(familyMembersBootstrapProvider);
  }
  ref.invalidate(familyMembersProvider);
  ref.invalidate(homeMedicalSummaryProvider);
}

void resyncFamilyProfileFromRemote(WidgetRef ref) {
  invalidateFamilyProfileProviders(ref, resyncRemote: true);
}

final homeMedicalSummaryProvider =
    FutureProvider<HomeMedicalSummary>((ref) async {
  await ref.watch(healthVaultBootstrapProvider.future);
  final patient = await ref.watch(patientProfileProvider.future);
  final members = await ref.watch(familyMembersProvider.future);
  final selectedId = ref.watch(selectedProfileMemberIdProvider);
  final member = resolveSelectedProfileMember(
    members: members,
    patient: patient,
    selectedMemberId: selectedId,
  );
  final completion = calculateProfileCompletion(
    member: member,
    patient: patient,
  );
  return HomeMedicalSummary(
    member: member,
    completion: completion,
    patient: patient,
  );
});
