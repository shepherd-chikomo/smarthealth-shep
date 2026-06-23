import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/domain/models/portal_profile.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

Future<void> showFacilitySwitcherSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const FacilitySwitcherSheet(),
  );
}

class FacilitySwitcherSheet extends ConsumerWidget {
  const FacilitySwitcherSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final profile = auth.profile;
    final activeId = ref.watch(facilityIdProvider);
    final memberships = profile?.facilities ?? [];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (_, controller) => Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.appColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Switch facility',
              style: PracticeDesignTokens.sectionTitle(context),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose which site you are working in',
              style: PracticeDesignTokens.metadata(context),
            ),
            const SizedBox(height: 16),
            if (memberships.isEmpty)
              Text(
                'No active facilities. Claim a site to get started.',
                style: PracticeDesignTokens.metadata(context),
              )
            else
              for (final f in memberships)
                _FacilityTile(
                  membership: f,
                  selected: f.id == activeId,
                  onTap: () async {
                    Navigator.pop(context);
                    if (f.id == activeId) return;
                    await ref.read(authStateProvider.notifier).selectFacility(f.id);
                  },
                ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.add_business_outlined),
              title: const Text('Claim facilities'),
              subtitle: const Text('Registry-linked sites you can own'),
              onTap: () {
                Navigator.pop(context);
                context.push('/claim');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_outlined),
              title: const Text('All your facilities'),
              onTap: () {
                Navigator.pop(context);
                context.push('/facility-picker');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FacilityTile extends StatelessWidget {
  const _FacilityTile({
    required this.membership,
    required this.selected,
    required this.onTap,
  });

  final FacilityMembership membership;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? primary.withValues(alpha: 0.08)
            : context.appColors.card,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: selected
                ? BorderSide(color: primary.withValues(alpha: 0.4))
                : BorderSide(color: context.appColors.border),
          ),
          title: Text(membership.name),
          subtitle: Text(membership.role),
          trailing: selected
              ? Icon(Icons.check_circle, color: primary)
              : const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
