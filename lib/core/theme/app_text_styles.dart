import 'package:flutter/material.dart';

/// Typography tuned for readability and OS text scaling up to 1.3x.
abstract final class AppTextStyles {
  static TextTheme textTheme(TextTheme base) {
    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.4),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}
