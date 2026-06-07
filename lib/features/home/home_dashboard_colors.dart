import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/theme/app_colors.dart';

/// Dashboard palette resolved from the active [Theme] (light or dark).
@immutable
class HomeDashboardColors {
  const HomeDashboardColors._({
    required this.primary,
    required this.primaryDark,
    required this.headerBlue,
    required this.headerBlueDark,
    required this.secondary,
    required this.emergency,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.emergencySoft,
    required this.skeleton,
    required this.warning,
  });

  final Color primary;
  final Color primaryDark;
  final Color headerBlue;
  final Color headerBlueDark;
  final Color secondary;
  final Color emergency;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color emergencySoft;
  final Color skeleton;
  final Color warning;

  static const double textureOpacityBody = 0.1;

  static HomeDashboardColors of(BuildContext context) {
    final tokens = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HomeDashboardColors._(
      primary: scheme.primary,
      primaryDark: isDark ? const Color(0xFF4A8FD9) : const Color(0xFF005A96),
      headerBlue: isDark ? const Color(0xFF0D8FD4) : const Color(0xFF0078C1),
      headerBlueDark: isDark ? const Color(0xFF0069A8) : const Color(0xFF00548E),
      secondary: scheme.secondary,
      emergency: tokens.emergency,
      background: tokens.background,
      surface: tokens.card,
      textPrimary: tokens.foreground,
      textSecondary: tokens.mutedForeground,
      emergencySoft: tokens.emergencySoft,
      skeleton: tokens.muted,
      warning: tokens.warning,
    );
  }
}
