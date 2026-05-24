import 'package:flutter/material.dart';

/// Healthcare app design system color tokens.
abstract final class DesignSystemColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFE3F2FD);
  static const Color secondary = Color(0xFF00897B);
  static const Color accent = Color(0xFFFF9800);
  static const Color emergency = Color(0xFFD32F2F);
  static const Color emergencyLight = Color(0xFFFFEBEE);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color pending = Color(0xFFE0A030);
  static const Color border = Color(0xFFE0E0E0);
  static const Color skeletonBase = Color(0xFFE0E0E0);
}

/// Shared radii and elevations for design-system widgets.
abstract final class DesignSystemMetrics {
  static const double radiusMd = 12;
  static const double radiusPill = 999;
  static const double buttonHeight = 48;
  static const double buttonHeightCompact = 40;
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
}
