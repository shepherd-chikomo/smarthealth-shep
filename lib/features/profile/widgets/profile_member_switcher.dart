import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/auth/patient_profile.dart';
import 'package:smarthealth_shep/features/family/bloc/family_bloc.dart';
import 'package:smarthealth_shep/features/family/screens/add_edit_family_member_screen.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/home/providers/home_medical_summary_provider.dart';
import 'package:smarthealth_shep/features/profile/utils/primary_profile_resolver.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';
/// Active profile member for view/edit flows. Null means primary account holder.
class SelectedProfileMemberId extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? memberId) {
    state = memberId;
  }
}

final selectedProfileMemberIdProvider =
    NotifierProvider<SelectedProfileMemberId, String?>(
  SelectedProfileMemberId.new,
);

FamilyMemberModel resolveSelectedProfileMember({
  required List<FamilyMemberModel> members,
  required PatientProfile? patient,
  required String? selectedMemberId,
}) {
  if (selectedMemberId != null) {
    for (final member in members) {
      if (member.id == selectedMemberId) return member;
    }
  }
  return findPrimaryMember(members) ?? buildPrimaryMemberFromProfile(patient);
}

class ProfileMemberSwitcher extends ConsumerWidget {
  const ProfileMemberSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = HomeDashboardColors.of(context);
    final membersAsync = ref.watch(familyMembersProvider);
    final patient = ref.watch(patientProfileProvider).value;
    final selectedId = ref.watch(selectedProfileMemberIdProvider);

    return membersAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (members) {
        if (members.length <= 1) return const SizedBox.shrink();

        final active = resolveSelectedProfileMember(
          members: members,
          patient: patient,
          selectedMemberId: selectedId,
        );

        return Card(
          margin: EdgeInsets.zero,
          color: colors.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Symbols.family_restroom, size: 20, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: active.id.isNotEmpty ? active.id : null,
                      hint: Text(active.name, overflow: TextOverflow.ellipsis),
                      items: members
                          .map(
                            (member) => DropdownMenuItem<String>(
                              value: member.id.isNotEmpty ? member.id : member.name,
                              child: Text(
                                member.isPrimaryAccountHolder
                                    ? '${member.name} (You)'
                                    : member.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        ref
                            .read(selectedProfileMemberIdProvider.notifier)
                            .select(value);
                        invalidateFamilyProfileProviders(ref);
                      },
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Add family member',
                  icon: const Icon(Symbols.person_add),
                  onPressed: () async {
                    final repository = ref.read(familyRepositoryProvider);
                    final added = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => FamilyBloc(repository: repository),
                          child: const AddEditFamilyMemberScreen(),
                        ),
                      ),
                    );
                    if (added == true) {
                      invalidateFamilyProfileProviders(ref, resyncRemote: true);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
