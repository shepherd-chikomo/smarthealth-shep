import 'package:flutter/material.dart';

/// Timing, colors, and copy for the MyHealth animated splash.
abstract final class SplashAnimationConstants {
  static const totalDuration = Duration(milliseconds: 2600);
  static const handoffDuration = Duration(milliseconds: 150);

  static const ecgDrawDuration = Duration(milliseconds: 700);
  static const logoRevealDuration = Duration(milliseconds: 350);
  static const titleTypeDuration = Duration(milliseconds: 480);
  static const taglineTypeDuration = Duration(milliseconds: 900);
  static const footerTypeDuration = Duration(milliseconds: 350);

  static const titleMsPerChar = 60;
  static const taglineMsPerChar = 32;
  static const footerMsPerChar = 28;

  static const logoSize = 128.0;
  static const logoGlowColor = Color(0xFFB8FFF6);
  static const sparkColor = Color(0xFF9FF5EA);
  static const sparkPeakExpansion = 1.35;

  static const appName = 'MyHealth';
  static const tagline = 'Your Healthcare Companion';

  static const gradientTopLeft = Color(0xFF22C7B8);
  static const gradientCenter = Color(0xFF1BA9D5);
  static const gradientBottomRight = Color(0xFF2563EB);

  static const logoTeal = Color(0xFF22C7B8);
  static const logoBlue = Color(0xFF2563EB);
  static const logoTealMid = Color(0xFF1EBBA3);
  static const logoBlueMid = Color(0xFF3B71DB);
  static const taglineColor = Color(0xFFB8E8F5);

  static const textureOpacityMin = 0.03;
  static const textureOpacityMax = 0.08;
  static const particleOpacity = 0.05;

  static int get titleCharCount => appName.length;
  static int get taglineCharCount => tagline.length;
}
