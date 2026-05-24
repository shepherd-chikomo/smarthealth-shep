import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/design_system_tokens.dart';

enum VerificationBadgeSize { small, large }

enum VerificationBadgeStyle { standard, source }

/// Teal pill badge indicating verified provider or facility source.
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({
    super.key,
    this.size = VerificationBadgeSize.small,
    this.style = VerificationBadgeStyle.standard,
    this.label,
    this.source = 'MDPCZ',
    this.verified = true,
  });

  final VerificationBadgeSize size;
  final VerificationBadgeStyle style;
  final String? label;
  final String source;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    if (!verified) {
      return const UnverifiedListingBadge();
    }
    if (style == VerificationBadgeStyle.source) {
      return _SourceBadge(source: source, label: label);
    }

    final isLarge = size == VerificationBadgeSize.large;
    final fontSize = isLarge ? 13.0 : 11.0;
    final iconSize = isLarge ? 16.0 : 14.0;
    final padding = isLarge
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    final displayLabel = label ?? '$source Verified';
    final color = DesignSystemColors.secondary;

    return Semantics(
      label: displayLabel,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(DesignSystemMetrics.radiusPill),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.verified,
              size: iconSize,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              displayLabel,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact source label matching provider card header styling.
class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source, this.label});

  final String source;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? source;

    return Semantics(
      label: displayLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: HomeDashboardColors.secondary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppAssets.verifiedBadge,
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(
                HomeDashboardColors.secondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              displayLabel,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: HomeDashboardColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Amber badge for registry listings not yet verified by the owner.
class UnverifiedListingBadge extends StatelessWidget {
  const UnverifiedListingBadge({super.key, this.label = 'Not verified'});

  final String label;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFB45309);
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(DesignSystemMetrics.radiusPill),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.info, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
