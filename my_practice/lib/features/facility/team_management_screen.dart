import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/data/seed/dev_team_seed.dart';
import 'package:my_practice/features/facility/team_provider.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/shared/widgets/practice_more_app_bar.dart';

class TeamManagementScreen extends ConsumerWidget {
  const TeamManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(teamListProvider);
    final canSyncRemote = !MyPracticeConfig.skipAuthForTesting;

    return Scaffold(
      appBar: practiceMoreAppBar(context, 'Team Management'),
      body: teamAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _TeamError(
          error: e,
          onRetry: () => ref.invalidate(teamListProvider),
        ),
        data: (team) {
          final display = team.isNotEmpty
              ? team
              : (MyPracticeConfig.useLocalDevSeed
                  ? DevTeamSeed.fallbackRows(DevTeamSeed.seedFacilityId)
                  : team);

          if (display.isEmpty) {
            return Column(
              children: [
                Expanded(
                  child: PracticeEmptyState(
                    title: 'No team members',
                    message: canSyncRemote
                        ? 'Invite staff to give them portal access.'
                        : 'Staff linked to this facility will appear here.',
                    icon: Icons.group_outlined,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: () => _showInviteDialog(context, ref),
                    icon: const Icon(Icons.person_add_outlined, size: 18),
                    label: const Text('Invite user'),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text('${display.length} members',
                        style: PracticeDesignTokens.metadata(context)),
                    if (MyPracticeConfig.useLocalDevSeed && team.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: PracticeStatusChip(
                          label: 'Dev seed',
                          tone: PracticeStatusTone.info,
                        ),
                      ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _showInviteDialog(context, ref),
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: const Text('Invite user'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(teamListProvider);
                    await ref.read(teamListProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: display.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _TeamMemberCard(member: display[i]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showInviteDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_InviteForm>(
      context: context,
      builder: (_) => const _InviteStaffDialog(),
    );
    if (result == null || !context.mounted) return;

    try {
      await ref.read(facilityRepositoryProvider).inviteStaffMember(
            fullName: result.fullName,
            email: result.email,
            role: result.role,
            phone: result.phone,
          );
      ref.invalidate(teamListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invitation sent to ${result.email}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              MyPracticeConfig.skipAuthForTesting
                  ? 'Invite requires pilot login (real auth). Saved locally in dev.'
                  : 'Could not invite: $e',
            ),
          ),
        );
      }
    }
  }
}

class _TeamError extends StatelessWidget {
  const _TeamError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load team', style: PracticeDesignTokens.sectionTitle(context)),
            const SizedBox(height: 8),
            Text('$error', style: PracticeDesignTokens.metadata(context)),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _InviteForm {
  const _InviteForm({
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
  });

  final String fullName;
  final String email;
  final String role;
  final String? phone;
}

class _InviteStaffDialog extends StatefulWidget {
  const _InviteStaffDialog();

  @override
  State<_InviteStaffDialog> createState() => _InviteStaffDialogState();
}

class _InviteStaffDialogState extends State<_InviteStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _role = 'doctor';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invite staff member'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Valid email required' : null,
              ),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                  DropdownMenuItem(
                    value: 'receptionist',
                    child: Text('Receptionist'),
                  ),
                  DropdownMenuItem(
                    value: 'facility_admin',
                    child: Text('Administrator'),
                  ),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'doctor'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _InviteForm(
                fullName: _nameCtrl.text.trim(),
                email: _emailCtrl.text.trim(),
                role: _role,
                phone: _phoneCtrl.text.trim().isEmpty
                    ? null
                    : _phoneCtrl.text.trim(),
              ),
            );
          },
          child: const Text('Send invite'),
        ),
      ],
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({required this.member});

  final Practitioner member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Row(
        children: [
          PracticeAvatar(initials: _initials(member.name)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: PracticeDesignTokens.inter(weight: FontWeight.w600),
                ),
                Text(
                  [
                    member.role ?? 'staff',
                    if (member.specialty != null) member.specialty,
                  ].join(' · '),
                  style: PracticeDesignTokens.metadata(context),
                ),
                if (member.registrationNumber != null)
                  Text(
                    member.registrationNumber!,
                    style: PracticeDesignTokens.metadata(context),
                  ),
              ],
            ),
          ),
          const PracticeStatusChip(
            label: 'Active',
            tone: PracticeStatusTone.success,
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
