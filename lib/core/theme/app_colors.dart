import 'package:flutter/material.dart';

/// Design tokens — light theme (mirrors web preview).
abstract final class AppColorsLight {
  static const Color background = Color(0xFFF7F8FB);
  static const Color foreground = Color(0xFF1A2138);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF1A2138);
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color primarySoft = Color(0xFFE3EEFB);
  static const Color secondary = Color(0xFF00897B);
  static const Color secondaryForeground = Color(0xFFFFFFFF);
  static const Color secondarySoft = Color(0xFFDCEFEC);
  static const Color muted = Color(0xFFF1F3F7);
  static const Color mutedForeground = Color(0xFF6B7180);
  static const Color emergency = Color(0xFFD32F2F);
  static const Color emergencyForeground = Color(0xFFFFFFFF);
  static const Color emergencySoft = Color(0xFFFCE6E6);
  static const Color success = Color(0xFF2E9D6E);
  static const Color successForeground = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFE0A030);
  static const Color border = Color(0xFFE5E8EE);
  static const Color ring = Color(0xFF1976D2);
}

/// Design tokens — dark theme (mirrors web preview).
abstract final class AppColorsDark {
  static const Color background = Color(0xFF1A1F2E);
  static const Color foreground = Color(0xFFF4F5F8);
  static const Color card = Color(0xFF232A3D);
  static const Color cardForeground = Color(0xFFF4F5F8);
  static const Color primary = Color(0xFF5BA3F5);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color primarySoft = Color(0xFF2A3C5A);
  static const Color secondary = Color(0xFF4DBDB1);
  static const Color secondaryForeground = Color(0xFFFFFFFF);
  static const Color secondarySoft = Color(0xFF233F3D);
  static const Color muted = Color(0xFF2A3142);
  static const Color mutedForeground = Color(0xFFB0B5C2);
  static const Color emergency = Color(0xFFF26565);
  static const Color emergencyForeground = Color(0xFFFFFFFF);
  static const Color emergencySoft = Color(0xFF4A2424);
  static const Color success = Color(0xFF2E9D6E);
  static const Color successForeground = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFE0A030);
  static const Color border = Color(0xFF353B4D);
  static const Color ring = Color(0xFF5BA3F5);
}

/// Semantic color tokens exposed via [ThemeExtension].
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.primarySoft,
    required this.secondarySoft,
    required this.muted,
    required this.mutedForeground,
    required this.emergency,
    required this.emergencyForeground,
    required this.emergencySoft,
    required this.success,
    required this.successForeground,
    required this.warning,
    required this.border,
    required this.ring,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color primarySoft;
  final Color secondarySoft;
  final Color muted;
  final Color mutedForeground;
  final Color emergency;
  final Color emergencyForeground;
  final Color emergencySoft;
  final Color success;
  final Color successForeground;
  final Color warning;
  final Color border;
  final Color ring;

  static const light = AppColorTokens(
    background: AppColorsLight.background,
    foreground: AppColorsLight.foreground,
    card: AppColorsLight.card,
    cardForeground: AppColorsLight.cardForeground,
    primarySoft: AppColorsLight.primarySoft,
    secondarySoft: AppColorsLight.secondarySoft,
    muted: AppColorsLight.muted,
    mutedForeground: AppColorsLight.mutedForeground,
    emergency: AppColorsLight.emergency,
    emergencyForeground: AppColorsLight.emergencyForeground,
    emergencySoft: AppColorsLight.emergencySoft,
    success: AppColorsLight.success,
    successForeground: AppColorsLight.successForeground,
    warning: AppColorsLight.warning,
    border: AppColorsLight.border,
    ring: AppColorsLight.ring,
  );

  static const dark = AppColorTokens(
    background: AppColorsDark.background,
    foreground: AppColorsDark.foreground,
    card: AppColorsDark.card,
    cardForeground: AppColorsDark.cardForeground,
    primarySoft: AppColorsDark.primarySoft,
    secondarySoft: AppColorsDark.secondarySoft,
    muted: AppColorsDark.muted,
    mutedForeground: AppColorsDark.mutedForeground,
    emergency: AppColorsDark.emergency,
    emergencyForeground: AppColorsDark.emergencyForeground,
    emergencySoft: AppColorsDark.emergencySoft,
    success: AppColorsDark.success,
    successForeground: AppColorsDark.successForeground,
    warning: AppColorsDark.warning,
    border: AppColorsDark.border,
    ring: AppColorsDark.ring,
  );

  @override
  AppColorTokens copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? cardForeground,
    Color? primarySoft,
    Color? secondarySoft,
    Color? muted,
    Color? mutedForeground,
    Color? emergency,
    Color? emergencyForeground,
    Color? emergencySoft,
    Color? success,
    Color? successForeground,
    Color? warning,
    Color? border,
    Color? ring,
  }) {
    return AppColorTokens(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      primarySoft: primarySoft ?? this.primarySoft,
      secondarySoft: secondarySoft ?? this.secondarySoft,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      emergency: emergency ?? this.emergency,
      emergencyForeground: emergencyForeground ?? this.emergencyForeground,
      emergencySoft: emergencySoft ?? this.emergencySoft,
      success: success ?? this.success,
      successForeground: successForeground ?? this.successForeground,
      warning: warning ?? this.warning,
      border: border ?? this.border,
      ring: ring ?? this.ring,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardForeground: Color.lerp(cardForeground, other.cardForeground, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      secondarySoft: Color.lerp(secondarySoft, other.secondarySoft, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      emergency: Color.lerp(emergency, other.emergency, t)!,
      emergencyForeground:
          Color.lerp(emergencyForeground, other.emergencyForeground, t)!,
      emergencySoft: Color.lerp(emergencySoft, other.emergencySoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      successForeground:
          Color.lerp(successForeground, other.successForeground, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      border: Color.lerp(border, other.border, t)!,
      ring: Color.lerp(ring, other.ring, t)!,
    );
  }
}

extension AppColorTokensX on BuildContext {
  AppColorTokens get appColors =>
      Theme.of(this).extension<AppColorTokens>() ?? AppColorTokens.light;
}
