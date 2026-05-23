import 'package:flutter/material.dart';

/// Typography scale — mirrors web preview (Inter / Roboto system stack).
abstract final class AppTextStyles {
  static const String fontFamilyFallback = 'Roboto';

  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static double _headingLetterSpacing(double fontSize) => fontSize * -0.01;

  static TextStyle xs({
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) =>
      TextStyle(
        fontSize: 11,
        height: 16 / 11,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle sm({
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) =>
      TextStyle(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle base({
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) =>
      TextStyle(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle lg({
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    bool isHeading = false,
  }) =>
      TextStyle(
        fontSize: 17,
        height: 24 / 17,
        fontWeight: fontWeight,
        color: color,
        letterSpacing:
            isHeading ? _headingLetterSpacing(17) : null,
      );

  static TextStyle xl({
    FontWeight fontWeight = semibold,
    Color? color,
    bool isHeading = true,
  }) =>
      TextStyle(
        fontSize: 20,
        height: 26 / 20,
        fontWeight: fontWeight,
        color: color,
        letterSpacing:
            isHeading ? _headingLetterSpacing(20) : null,
      );

  static TextStyle xxl({
    FontWeight fontWeight = bold,
    Color? color,
    bool isHeading = true,
  }) =>
      TextStyle(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: fontWeight,
        color: color,
        letterSpacing:
            isHeading ? _headingLetterSpacing(24) : null,
      );

  static TextTheme textTheme({required Color foreground}) {
    return TextTheme(
      displayLarge: xxl(fontWeight: bold, color: foreground),
      displayMedium: xl(fontWeight: bold, color: foreground),
      displaySmall: lg(fontWeight: semibold, color: foreground, isHeading: true),
      headlineLarge: xxl(fontWeight: bold, color: foreground),
      headlineMedium: xl(fontWeight: semibold, color: foreground),
      headlineSmall: lg(fontWeight: semibold, color: foreground, isHeading: true),
      titleLarge: lg(fontWeight: semibold, color: foreground, isHeading: true),
      titleMedium: base(fontWeight: semibold, color: foreground),
      titleSmall: sm(fontWeight: semibold, color: foreground),
      bodyLarge: base(color: foreground),
      bodyMedium: sm(color: foreground),
      bodySmall: xs(color: foreground),
      labelLarge: base(fontWeight: medium, color: foreground),
      labelMedium: sm(fontWeight: medium, color: foreground),
      labelSmall: xs(fontWeight: medium, color: foreground),
    );
  }
}
