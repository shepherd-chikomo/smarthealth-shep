import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/home/providers/home_medical_summary_provider.dart';
import 'package:smarthealth_shep/features/profile/profile_edit_focus.dart';
import 'package:smarthealth_shep/features/profile/utils/profile_completion_calculator.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';

class ProfileCompletionScreen extends ConsumerWidget {
  const ProfileCompletionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = HomeDashboardColors.of(context);
    final summaryAsync = ref.watch(homeMedicalSummaryProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text(l10n.profileCompletionTitle),
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (summary) {
          final completion = summary.completion;
          final bandColor = completionBandColor(completion.band, context);
          final isComplete =
              completion.band == ProfileCompletionBand.complete;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 112,
                      height: 112,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: completion.percentage / 100),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: value,
                                strokeWidth: 8,
                                backgroundColor:
                                    colors.primary.withValues(alpha: 0.1),
                                color: bandColor,
                              ),
                              if (isComplete)
                                Icon(
                                  Symbols.check_circle,
                                  color: bandColor,
                                  size: 32,
                                )
                              else
                                Text(
                                  '${completion.percentage}%',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: bandColor,
                                    height: 1,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.homeProfileComplete,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.profileCompletionSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ...completion.items.map(
                (item) => _ChecklistTile(
                  item: item,
                  colors: colors,
                  onTap: !item.isComplete && ProfileEditFocus.isEditable(item.id)
                      ? () => context.push('/profile/edit?section=${item.id}')
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.profileCompletionCta,
                onPressed: () => context.push('/profile/edit'),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/profile'),
                  child: Text(l10n.profileCompletionViewProfile),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.item,
    required this.colors,
    this.onTap,
  });

  final ProfileCompletionItem item;
  final HomeDashboardColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        item.isComplete ? Symbols.check_circle : Symbols.radio_button_unchecked,
        color: item.isComplete ? const Color(0xFF2E7D32) : colors.textSecondary,
      ),
      title: Text(
        item.label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
      trailing: item.isComplete
          ? null
          : Text(
              'Missing',
              style: TextStyle(
                fontSize: 12,
                color: colors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
      onTap: onTap,
    );

    if (onTap == null) return tile;

    return Semantics(
      button: true,
      label: 'Add ${item.label}',
      child: tile,
    );
  }
}
