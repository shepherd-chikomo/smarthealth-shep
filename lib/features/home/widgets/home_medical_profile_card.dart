import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/home/providers/home_medical_summary_provider.dart';
import 'package:smarthealth_shep/features/profile/utils/condition_labels.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';

class HomeMedicalProfileCard extends StatefulWidget {
  const HomeMedicalProfileCard({
    super.key,
    required this.summary,
    this.compact = false,
  });

  final HomeMedicalSummary summary;
  final bool compact;

  @override
  State<HomeMedicalProfileCard> createState() => _HomeMedicalProfileCardState();
}

class _HomeMedicalProfileCardState extends State<HomeMedicalProfileCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = HomeDashboardColors.of(context);
    final summary = widget.summary;
    final bloodGroup = summary.bloodGroup ?? '—';
    final age = summary.ageYears?.toString() ?? '—';
    final gender = summary.genderLabel ?? '—';
    final hasAllergies = summary.hasAllergies;
    final conditions = summary.conditions;
    final compact = widget.compact;

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: colors.surface,
        elevation: _pressed ? 2 : 6,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => context.go('/profile'),
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 14,
              vertical: compact ? 10 : 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Symbols.shield,
                      size: compact ? 18 : 20,
                      color: colors.headerBlueDark,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.homeMedicalProfile,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: compact ? 13 : 14,
                          height: 1.15,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Symbols.chevron_right,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
                SizedBox(height: compact ? 8 : 12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryColumn(
                        label: l10n.homeBloodType,
                        value: bloodGroup,
                        valueColor: colors.emergency,
                        emphasize: !compact,
                        compact: compact,
                      ),
                    ),
                    Expanded(
                      child: _SummaryColumn(
                        label: l10n.homeAge,
                        value: age,
                        compact: compact,
                      ),
                    ),
                    Expanded(
                      child: _SummaryColumn(
                        label: l10n.homeGender,
                        value: gender,
                        compact: compact,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 8 : 12),
                Divider(height: 1, color: const Color(0xFFE5E8EE)),
                SizedBox(height: compact ? 6 : 10),
                if (hasAllergies)
                  _StatusRow(
                    icon: Symbols.warning,
                    iconColor: colors.emergency,
                    text: l10n.homeAllergyAlert(summary.allergies!.trim()),
                    trailing: null,
                    maxLines: compact ? 3 : 2,
                  )
                else
                  _StatusRow(
                    icon: Symbols.shield,
                    iconColor: colors.primary,
                    text: l10n.homeNoKnownAllergies,
                    trailing: compact
                        ? null
                        : Icon(
                            Symbols.check_circle,
                            size: 18,
                            color: const Color(0xFF2E7D32),
                          ),
                    maxLines: compact ? 2 : 2,
                  ),
                if (!compact && conditions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _StatusRow(
                    icon: Symbols.cardiology,
                    iconColor: colors.primary,
                    text: ConditionLabels.joinLabels(conditions),
                    trailing: Icon(
                      Symbols.chevron_right,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                if (!compact) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      l10n.homeViewMedicalProfile,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
    this.compact = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 9 : 10,
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 15 : (emphasize ? 18 : 15),
            fontWeight: FontWeight.w800,
            color: valueColor ?? colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.trailing,
    this.maxLines = 2,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final Widget? trailing;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: HomeDashboardColors.of(context).textPrimary,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
