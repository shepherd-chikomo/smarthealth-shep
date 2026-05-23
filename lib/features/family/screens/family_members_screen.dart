import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/family/bloc/family_bloc.dart';
import 'package:smarthealth_shep/features/family/bloc/family_event.dart';
import 'package:smarthealth_shep/features/family/bloc/family_state.dart';
import 'package:smarthealth_shep/features/family/data/family_repository.dart';
import 'package:smarthealth_shep/features/family/screens/add_edit_family_member_screen.dart';
import 'package:smarthealth_shep/features/family/widgets/family_member_card.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';

/// Family members list with add, edit, and swipe-to-delete.
class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({super.key, this.repository});

  final FamilyRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FamilyBloc(repository: repository),
      child: const _FamilyMembersView(),
    );
  }
}

class _FamilyMembersView extends StatelessWidget {
  const _FamilyMembersView();

  Future<void> _openAdd(BuildContext context) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<FamilyBloc>(),
          child: const AddEditFamilyMemberScreen(),
        ),
      ),
    );
  }

  Future<void> _openEdit(
    BuildContext context,
    FamilyMemberModel member,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<FamilyBloc>(),
          child: AddEditFamilyMemberScreen(member: member),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    FamilyMemberModel member,
  ) async {
    if (member.isPrimaryAccountHolder) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cannot delete'),
          content: const Text(
            'The primary account holder cannot be removed. '
            'Transfer primary status to another member first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove family member?'),
        content: Text(
          'Remove ${member.name} from your family list? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: HomeDashboardColors.emergency,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeDashboardColors.background,
      appBar: AppBar(
        backgroundColor: HomeDashboardColors.surface,
        foregroundColor: HomeDashboardColors.textPrimary,
        title: const Text('Family Members'),
      ),
      body: BlocConsumer<FamilyBloc, FamilyState>(
        listenWhen: (prev, curr) =>
            prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == FamilyStatus.loading &&
              state.members.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (state.isOffline)
                Container(
                  width: double.infinity,
                  color: HomeDashboardColors.warning.withValues(alpha: 0.15),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Text(
                    'Offline — changes saved locally and will sync when online',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: HomeDashboardColors.textSecondary,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: PrimaryButton(
                  label: 'Add Family Member',
                  onPressed: state.status == FamilyStatus.saving
                      ? null
                      : () => _openAdd(context),
                ),
              ),
              Expanded(
                child: state.members.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: state.members.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final member = state.members[index];
                          return _DismissibleMemberCard(
                            member: member,
                            onEdit: () => _openEdit(context, member),
                            onDelete: () async {
                              final ok =
                                  await _confirmDelete(context, member);
                              if (ok && context.mounted) {
                                context
                                    .read<FamilyBloc>()
                                    .add(DeleteMember(member.id));
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DismissibleMemberCard extends StatelessWidget {
  const _DismissibleMemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  final FamilyMemberModel member;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(member.id),
      direction: member.isPrimaryAccountHolder
          ? DismissDirection.none
          : DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: HomeDashboardColors.emergency,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: FamilyMemberCard(member: member, onEdit: onEdit),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.group,
              size: 56,
              color: HomeDashboardColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No family members yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add dependents to book appointments on their behalf.',
              textAlign: TextAlign.center,
              style: TextStyle(color: HomeDashboardColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
