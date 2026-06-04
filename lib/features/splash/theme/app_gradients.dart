import 'package:flutter/material.dart';
import 'package:smarthealth_shep/features/splash/constants/splash_animation_constants.dart';

/// Premium healthcare gradients for splash and brand surfaces.
abstract final class AppGradients {
  static const splashBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      SplashAnimationConstants.gradientTopLeft,
      SplashAnimationConstants.gradientCenter,
      SplashAnimationConstants.gradientBottomRight,
    ],
    stops: [0.0, 0.48, 1.0],
  );

  static RadialGradient splashLogoGlow({double intensity = 0.45}) {
    return RadialGradient(
      colors: [
        SplashAnimationConstants.logoGlowColor
            .withValues(alpha: intensity),
        SplashAnimationConstants.logoGlowColor
            .withValues(alpha: intensity * 0.35),
        Colors.transparent,
      ],
      stops: const [0.0, 0.42, 1.0],
    );
  }

  static const logoLeftTeal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      SplashAnimationConstants.logoTeal,
      SplashAnimationConstants.logoTealMid,
    ],
  );

  static const logoRightBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      SplashAnimationConstants.logoBlueMid,
      SplashAnimationConstants.logoBlue,
    ],
  );
}
