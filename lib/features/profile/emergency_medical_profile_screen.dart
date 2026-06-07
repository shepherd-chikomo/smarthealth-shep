import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/auth/patient_profile.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/home/providers/home_medical_summary_provider.dart';
import 'package:smarthealth_shep/features/profile/widgets/emergency_profile_widgets.dart';
import 'package:smarthealth_shep/features/profile/widgets/profile_member_switcher.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';

class EmergencyMedicalProfileScreen extends ConsumerWidget {
  const EmergencyMedicalProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final patientAsync = ref.watch(patientProfileProvider);
    final membersAsync = ref.watch(familyMembersProvider);

    return Scaffold(
      backgroundColor: HomeDashboardColors.of(context).background,
      appBar: AppBar(
        backgroundColor: HomeDashboardColors.of(context).background,
        title: Text(l10n.navProfile),
        actions: [
          IconButton(
            icon: const Icon(Symbols.edit),
            tooltip: 'Edit profile',
            onPressed: () async {
              await context.push('/profile/edit');
              invalidateFamilyProfileProviders(ref);
            },
          ),
          IconButton(
            icon: const Icon(Symbols.settings),
            tooltip: 'Settings',
            onPressed: () => context.push('/profile/settings'),
          ),
        ],
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (members) {
          final patient = patientAsync.value;
          final selectedId = ref.watch(selectedProfileMemberIdProvider);
          final member = resolveSelectedProfileMember(
            members: members,
            patient: patient,
            selectedMemberId: selectedId,
          );
          final metadata = member.metadata ?? const EmergencyMedicalMetadata();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const ProfileMemberSwitcher(),
              const SizedBox(height: 12),
              EmergencyProfileHeaderBanner(updatedAt: member.updatedAt),
              const SizedBox(height: 16),
              EmergencyPatientIdentityCard(
                member: member,
                patientProfile: patient,
                patientId: patient?.smarthealthPatientId ?? patient?.id ?? member.id,
              ),
              const SizedBox(height: 12),
              SevereAllergyCard(allergy: member.allergies),
              const SizedBox(height: 12),
              HighRiskConditionsCard(
                conditionIds: member.medicalConditions,
                customLabels: metadata.customConditionLabels,
              ),
              const SizedBox(height: 12),
              CurrentMedicationsCard(medications: metadata.medications),
              const SizedBox(height: 12),
              EmergencyContactMedicalAidRow(
                contact: metadata.primaryEmergencyContact,
                contacts: metadata.emergencyContacts,
                medicalAid: metadata.medicalAid,
              ),
              const SizedBox(height: 12),
              MedicalHistoryCard(
                conditionIds: member.medicalConditions,
                customLabels: metadata.customConditionLabels,
              ),
              const SizedBox(height: 12),
              PrimaryProviderCard(provider: metadata.primaryProvider),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
