import 'package:flutter/material.dart';
import 'package:smarthealth_core/src/theme/app_colors.dart';
import 'package:smarthealth_core/src/theme/app_radii.dart';
import 'package:smarthealth_core/src/theme/app_shadows.dart';
import 'package:smarthealth_core/src/theme/app_text_styles.dart';
import 'package:smarthealth_core/src/utils/app_constants.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  /// Back-compat aliases.
  static ThemeData light() => lightTheme;
  static ThemeData dark() => darkTheme;

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final tokens = isLight ? AppColorTokens.light : AppColorTokens.dark;
    final primary =
        isLight ? AppColorsLight.primary : AppColorsDark.primary;
    final primaryFg =
        isLight ? AppColorsLight.primaryForeground : AppColorsDark.primaryForeground;
    final secondary =
        isLight ? AppColorsLight.secondary : AppColorsDark.secondary;
    final secondaryFg = isLight
        ? AppColorsLight.secondaryForeground
        : AppColorsDark.secondaryForeground;

    final seeded = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    );

    final colorScheme = seeded.copyWith(
      primary: primary,
      onPrimary: primaryFg,
      secondary: secondary,
      onSecondary: secondaryFg,
      surface: tokens.background,
      onSurface: tokens.foreground,
      error: tokens.emergency,
      onError: tokens.emergencyForeground,
      outline: tokens.border,
      surfaceContainerHighest: tokens.muted,
      onSurfaceVariant: tokens.mutedForeground,
    );

    final textTheme = AppTextStyles.textTheme(foreground: tokens.foreground);

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.xl),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTextStyles.fontFamilyFallback,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.background,
      textTheme: textTheme,
      extensions: [tokens],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: tokens.background,
        foregroundColor: tokens.foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.lg(
          fontWeight: AppTextStyles.semibold,
          color: tokens.foreground,
          isHeading: true,
        ),
      ),
      cardTheme: CardThemeData(
        color: tokens.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          side: BorderSide(color: tokens.border.withValues(alpha: 0.4)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppConstants.minTapTarget),
          shape: buttonShape,
          textStyle: AppTextStyles.base(
            fontWeight: AppTextStyles.semibold,
            color: primaryFg,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppConstants.minTapTarget),
          shape: buttonShape,
          side: BorderSide(color: tokens.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: tokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: tokens.ring, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      dividerTheme: DividerThemeData(color: tokens.border, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.card,
        selectedColor: primary,
        disabledColor: tokens.muted,
        labelStyle: AppTextStyles.sm(color: tokens.foreground),
        secondaryLabelStyle: AppTextStyles.sm(color: primaryFg),
        side: BorderSide(color: tokens.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.foreground,
        contentTextStyle: AppTextStyles.sm(color: tokens.background),
        actionTextColor: colorScheme.primary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.card,
        indicatorColor: tokens.primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return AppTextStyles.xs(
            fontWeight: states.contains(WidgetState.selected)
                ? AppTextStyles.semibold
                : AppTextStyles.medium,
            color: tokens.foreground,
          );
        }),
      ),
      visualDensity: VisualDensity.standard,
    );
  }

  /// Applies the card shadow stack to a [Card] child (M3 Card supports one shadow).
  static Widget themedCard({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    final tokens = context.appColors;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: tokens.border.withValues(alpha: 0.4)),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: DefaultTextStyle(
            style: AppTextStyles.base(color: tokens.cardForeground),
            child: child,
          ),
        ),
      ),
    );
  }
}
