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
import 'package:smarthealth_core/smarthealth_core.dart';

class TeamManagementScreen extends ConsumerWidget {
  const TeamManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(teamListProvider);
    final canSyncRemote = !MyPracticeConfig.skipAuthForTesting;

    return Scaffold(
      appBar: practiceMoreAppBar(
        context,
        'Team Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Invite user',
            onPressed: () => _showInviteDialog(context, ref),
          ),
        ],
      ),
      body: teamAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _TeamError(
          error: e,
          onRetry: () => ref.invalidate(teamListProvider),
        ),
        data: (team) {
          // Only inject seed members in full dev-bypass mode (SKIP_AUTH=true).
          // When connected to a real server with real auth, show the actual
          // portal team (or the "No team members" empty state).
          final display = team.isNotEmpty
              ? team
              : (MyPracticeConfig.skipAuthForTesting
                  ? DevTeamSeed.fallbackRows(DevTeamSeed.seedFacilityId)
                  : team);

          if (display.isEmpty) {
            return PracticeEmptyState(
              title: 'No team members',
              message: canSyncRemote
                  ? 'Invite staff to give them portal access.'
                  : 'Staff linked to this facility will appear here.',
              icon: Icons.group_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(teamListProvider);
              await ref.read(teamListProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: display.length + 1,
              separatorBuilder: (_, i) =>
                  i == 0 ? const SizedBox(height: 12) : const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          if (i == 0) {
                            return Text(
                              '${display.length} member${display.length == 1 ? '' : 's'}',
                              style: PracticeDesignTokens.metadata(context),
                            );
                          }
                          final member = display[i - 1];
                          return _TeamMemberCard(
                            member: member,
                            onTap: () =>
                                _showManageMemberSheet(context, ref, member),
                          );
                        },
            ),
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
  const _TeamMemberCard({required this.member, required this.onTap});

  final Practitioner member;
  final VoidCallback onTap;

  bool get _suspended => member.syncStatus == 'suspended';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
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
                      _allRoles(member),
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
              const SizedBox(width: 8),
              _suspended
                  ? const PracticeStatusChip(
                      label: 'Suspended',
                      tone: PracticeStatusTone.warning,
                    )
                  : const PracticeStatusChip(
                      label: 'Active',
                      tone: PracticeStatusTone.success,
                    ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
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

  String _allRoles(Practitioner m) {
    final extras = (m.additionalRoles ?? '')
        .split(',')
        .where((r) => r.isNotEmpty && r != m.role)
        .toList();
    final parts = [m.role ?? 'staff', ...extras];
    if (m.specialty != null) parts.add(m.specialty!);
    return parts.join(' · ');
  }
}

// ---------------------------------------------------------------------------
// Manage-member bottom sheet
// ---------------------------------------------------------------------------

Future<void> _showManageMemberSheet(
  BuildContext context,
  WidgetRef ref,
  Practitioner member,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ManageMemberSheet(member: member, ref: ref),
  );
}

class _ManageMemberSheet extends StatefulWidget {
  const _ManageMemberSheet({required this.member, required this.ref});
  final Practitioner member;
  final WidgetRef ref;

  @override
  State<_ManageMemberSheet> createState() => _ManageMemberSheetState();
}

class _ManageMemberSheetState extends State<_ManageMemberSheet> {
  late String _role;
  late Set<String> _additionalRoles;
  bool _busy = false;
  String? _error;

  static const _roles = [
    ('doctor', 'Doctor'),
    ('receptionist', 'Receptionist'),
    ('facility_admin', 'Administrator'),
  ];

  bool get _suspended => widget.member.syncStatus == 'suspended';
  String get _membershipId => widget.member.serverId ?? widget.member.id;

  bool get _rolesChanged {
    if (_role != (widget.member.role ?? 'doctor')) return true;
    final original = (widget.member.additionalRoles ?? '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .toSet();
    return !_additionalRoles.containsAll(original) ||
        !original.containsAll(_additionalRoles);
  }

  @override
  void initState() {
    super.initState();
    _role = widget.member.role ?? 'doctor';
    _additionalRoles = (widget.member.additionalRoles ?? '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .toSet();
  }

  Future<void> _saveRole() async {
    if (!_rolesChanged) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    // Additional roles must not include the primary role (backend treats them separately).
    final extras = _additionalRoles.where((r) => r != _role).toList();
    try {
      await widget.ref
          .read(facilityRepositoryProvider)
          .updateStaffMember(_membershipId, role: _role, additionalRoles: extras);
      widget.ref.invalidate(teamListProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _busy = false;
        _error = _friendlyError(e);
      });
    }
  }

  Future<void> _toggleSuspend() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = widget.ref.read(facilityRepositoryProvider);
      if (_suspended) {
        await repo.unsuspendStaffMember(_membershipId);
      } else {
        await repo.suspendStaffMember(_membershipId);
      }
      widget.ref.invalidate(teamListProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _busy = false;
        _error = _friendlyError(e);
      });
    }
  }

  Future<void> _confirmRemove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove team member'),
        content: Text(
          'Remove ${widget.member.name} from the facility? '
          'They will lose portal access immediately. You can re-invite them later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.ref
          .read(facilityRepositoryProvider)
          .removeStaffMember(_membershipId);
      widget.ref.invalidate(teamListProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _busy = false;
        _error = _friendlyError(e);
      });
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('last facility administrator')) {
      return 'Cannot change the last administrator.';
    }
    if (msg.contains('yourself')) return 'You cannot modify your own membership.';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;
    final roleLabel =
        _roles.where((r) => r.$1 == _role).map((r) => r.$2).firstOrNull ?? _role;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                PracticeAvatar(
                  initials: _initials(widget.member.name),
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.member.name,
                        style: PracticeDesignTokens.inter(
                          size: 16,
                          weight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        roleLabel,
                        style: PracticeDesignTokens.metadata(context),
                      ),
                    ],
                  ),
                ),
                _suspended
                    ? const PracticeStatusChip(
                        label: 'Suspended',
                        tone: PracticeStatusTone.warning,
                      )
                    : const PracticeStatusChip(
                        label: 'Active',
                        tone: PracticeStatusTone.success,
                      ),
              ],
            ),
            const SizedBox(height: 24),

            // Primary role (single select)
            Text(
              'Primary role',
              style: PracticeDesignTokens.tableHeader(context),
            ),
            const SizedBox(height: 4),
            Text(
              'Governs access level and permissions.',
              style: PracticeDesignTokens.metadata(context),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: PracticeDesignTokens.previewCardDecoration(context),
              child: Column(
                children: [
                  for (var i = 0; i < _roles.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: colors.border),
                    InkWell(
                      borderRadius: i == 0
                          ? const BorderRadius.vertical(top: Radius.circular(12))
                          : i == _roles.length - 1
                              ? const BorderRadius.vertical(
                                  bottom: Radius.circular(12))
                              : BorderRadius.zero,
                      onTap: _busy ? null : () => setState(() => _role = _roles[i].$1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _roles[i].$2,
                                style: PracticeDesignTokens.inter(size: 14),
                              ),
                            ),
                            if (_role == _roles[i].$1)
                              Icon(Icons.check_circle, color: primary, size: 20)
                            else
                              Icon(Icons.radio_button_unchecked,
                                  color: colors.mutedForeground, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Additional roles (multi-select)
            Text(
              'Additional roles',
              style: PracticeDesignTokens.tableHeader(context),
            ),
            const SizedBox(height: 4),
            Text(
              'For members who hold more than one role (e.g. doctor & admin).',
              style: PracticeDesignTokens.metadata(context),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: PracticeDesignTokens.previewCardDecoration(context),
              child: Column(
                children: [
                  for (var i = 0; i < _roles.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: colors.border),
                    InkWell(
                      borderRadius: i == 0
                          ? const BorderRadius.vertical(top: Radius.circular(12))
                          : i == _roles.length - 1
                              ? const BorderRadius.vertical(
                                  bottom: Radius.circular(12))
                              : BorderRadius.zero,
                      onTap: _busy || _roles[i].$1 == _role
                          ? null
                          : () => setState(() {
                                if (_additionalRoles.contains(_roles[i].$1)) {
                                  _additionalRoles.remove(_roles[i].$1);
                                } else {
                                  _additionalRoles.add(_roles[i].$1);
                                }
                              }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _roles[i].$2,
                                style: PracticeDesignTokens.inter(
                                  size: 14,
                                  color: _roles[i].$1 == _role
                                      ? colors.mutedForeground
                                      : null,
                                ),
                              ),
                            ),
                            if (_roles[i].$1 == _role)
                              Text(
                                'primary',
                                style: PracticeDesignTokens.metadata(context),
                              )
                            else
                              Checkbox(
                                value: _additionalRoles.contains(_roles[i].$1),
                                onChanged: _busy
                                    ? null
                                    : (v) => setState(() {
                                          if (v == true) {
                                            _additionalRoles.add(_roles[i].$1);
                                          } else {
                                            _additionalRoles.remove(_roles[i].$1);
                                          }
                                        }),
                                activeColor: primary,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (_rolesChanged) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _saveRole,
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save roles'),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Suspend / Restore
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _toggleSuspend,
                icon: Icon(
                  _suspended
                      ? Icons.lock_open_outlined
                      : Icons.pause_circle_outline,
                  size: 18,
                ),
                label: Text(
                  _suspended ? 'Restore access' : 'Suspend access',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      _suspended ? primary : colors.mutedForeground,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Remove
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _confirmRemove,
                icon: const Icon(Icons.person_remove_outlined, size: 18),
                label: const Text('Remove from team'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: PracticeDesignTokens.metadata(context).copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
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
