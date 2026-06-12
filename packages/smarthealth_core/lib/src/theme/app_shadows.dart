import 'package:flutter/material.dart';

/// Box shadows — mirrors web preview shadow tokens.
abstract final class AppShadows {
  /// card: offset(0,1) blur 2 #1A21380A + offset(0,4) blur 16 #1A21380F
  static const List<BoxShadow> card = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      color: Color(0x0A1A2138),
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 16,
      color: Color(0x0F1A2138),
    ),
  ];

  /// elevated: offset(0,8) blur 32 #1A213819
  static const List<BoxShadow> elevated = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 32,
      color: Color(0x191A2138),
    ),
  ];

  /// emergency: offset(0,8) blur 24 #D32F2F4D
  static const List<BoxShadow> emergency = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 24,
      color: Color(0x4DD32F2F),
    ),
  ];

  /// `.app-shell` ambient shadow on wide viewports (60px blur).
  static List<BoxShadow> appShellAmbient(Color borderColor) => [
        BoxShadow(
          offset: Offset.zero,
          blurRadius: 60,
          spreadRadius: 0,
          color: borderColor.withValues(alpha: 0.25),
        ),
      ];
}
