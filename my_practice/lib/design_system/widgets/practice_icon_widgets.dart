import 'package:flutter/material.dart';
import 'package:my_practice/core/assets/practice_assets.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

/// MyHealth cross mark — matches launcher / design spec branding.
class PracticeBrandMark extends StatelessWidget {
  const PracticeBrandMark({
    super.key,
    this.size = PracticeDesignTokens.brandMarkSize,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.04),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.appColors.border.withValues(alpha: 0.35),
        ),
      ),
      child: Image.asset(
        PracticeAssets.headerCrossLogo,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Tinted square icon badge used on KPI cards and quick actions.
class PracticeIconBadge extends StatelessWidget {
  const PracticeIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = PracticeDesignTokens.iconBadgeSize,
    this.iconSize = PracticeDesignTokens.iconSm,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: PracticeDesignTokens.softAccentBg(color),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}

/// Sidebar / nav list icon — 20px, muted or primary when selected.
class PracticeNavIcon extends StatelessWidget {
  const PracticeNavIcon({
    super.key,
    required this.icon,
    required this.selected,
  });

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;
    return Icon(
      icon,
      size: PracticeDesignTokens.iconMd,
      color: selected ? primary : colors.mutedForeground,
    );
  }
}

/// Top-bar action icon button — 22px icon, muted foreground.
class PracticeToolbarIconButton extends StatelessWidget {
  const PracticeToolbarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: PracticeDesignTokens.iconLg),
      style: IconButton.styleFrom(
        foregroundColor: color ?? colors.mutedForeground,
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// Quick-action row icon — primary-tinted badge at nav icon size.
class PracticeActionIcon extends StatelessWidget {
  const PracticeActionIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return PracticeIconBadge(
      icon: icon,
      color: primary,
      size: 32,
      iconSize: PracticeDesignTokens.iconMd,
    );
  }
}
