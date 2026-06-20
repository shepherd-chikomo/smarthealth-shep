import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

/// MyPractice themes — SmartHealth tokens + Inter typography.
abstract final class PracticeAppTheme {
  static ThemeData get light => _applyPractice(AppTheme.lightTheme);
  static ThemeData get dark => _applyPractice(AppTheme.darkTheme);

  static ThemeData _applyPractice(ThemeData base) {
    final inter = GoogleFonts.interTextTheme(base.textTheme);
    final tokens = base.extension<AppColorTokens>() ?? AppColorTokens.light;
    final primary = base.colorScheme.primary;

    return base.copyWith(
      textTheme: inter,
      primaryTextTheme: inter,
      navigationBarTheme: base.navigationBarTheme.copyWith(
        height: 72,
        indicatorColor: tokens.primarySoft,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? primary : tokens.mutedForeground,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: PracticeDesignTokens.iconLg,
            color: selected ? primary : tokens.mutedForeground,
          );
        }),
      ),
    );
  }
}
