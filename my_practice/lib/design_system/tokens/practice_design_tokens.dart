import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

/// MyPractice design tokens — extends SmartHealth core palette for preview/production rollout.
abstract final class PracticeDesignTokens {
  static const teal = Color(0xFF00897B);
  static const tealSoft = Color(0xFFDCEFEC);
  static const danger = Color(0xFFD32F2F);
  static const dangerSoft = Color(0xFFFCE6E6);
  static const amber = Color(0xFFE0A030);
  static const amberSoft = Color(0xFFFFF3D6);
  static const green = Color(0xFF2E9D6E);
  static const greenSoft = Color(0xFFE6F5EE);

  static const sidebarWidth = 280.0;
  static const sidebarCollapsedWidth = 72.0;
  static const topBarHeight = 64.0;

  static TextStyle inter({
    double? size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle pageTitle(BuildContext context) => inter(
        size: 28,
        weight: FontWeight.w700,
        color: context.appColors.foreground,
        height: 1.2,
      );

  static TextStyle sectionTitle(BuildContext context) => inter(
        size: 17,
        weight: FontWeight.w600,
        color: context.appColors.foreground,
      );

  static TextStyle kpiValue(BuildContext context) => inter(
        size: 32,
        weight: FontWeight.w700,
        color: context.appColors.foreground,
        height: 1.1,
      );

  static TextStyle tableHeader(BuildContext context) => inter(
        size: 11,
        weight: FontWeight.w600,
        color: context.appColors.mutedForeground,
        letterSpacing: 0.6,
      );

  static TextStyle metadata(BuildContext context) => inter(
        size: 12,
        weight: FontWeight.w400,
        color: context.appColors.mutedForeground,
      );

  static TextStyle clinicalNote(BuildContext context) => GoogleFonts.sourceSans3(
        fontSize: 14,
        height: 1.55,
        color: context.appColors.foreground,
      );

  static LinearGradient headerGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF1E2A45), const Color(0xFF232A3D)]
          : [const Color(0xFFE3EEFB), const Color(0xFFF7F8FB)],
    );
  }

  static BoxDecoration previewCardDecoration(BuildContext context) {
    final colors = context.appColors;
    return BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      border: Border.all(color: colors.border),
      boxShadow: AppShadows.card,
    );
  }
}

enum PracticeStatusTone {
  success,
  warning,
  danger,
  info,
  neutral,
  queue,
}

extension PracticeStatusToneX on PracticeStatusTone {
  Color color(BuildContext context) {
    final c = context.appColors;
    return switch (this) {
      PracticeStatusTone.success => c.success,
      PracticeStatusTone.warning => c.warning,
      PracticeStatusTone.danger => c.emergency,
      PracticeStatusTone.info => Theme.of(context).colorScheme.primary,
      PracticeStatusTone.queue => PracticeDesignTokens.amber,
      PracticeStatusTone.neutral => c.mutedForeground,
    };
  }
}
