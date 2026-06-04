import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:smarthealth_shep/features/splash/constants/splash_animation_constants.dart';
import 'package:smarthealth_shep/features/splash/painters/ecg_painter.dart';
import 'package:smarthealth_shep/features/splash/theme/app_gradients.dart';

/// Reference-style cross (outlined, gradient) with animated ECG overlay.
class MyHealthSplashLogo extends StatelessWidget {
  const MyHealthSplashLogo({
    super.key,
    required this.size,
    required this.ecgProgress,
    required this.logoOpacity,
    required this.sparkT,
  });

  final double size;
  final double ecgProgress;
  final double logoOpacity;
  final double sparkT;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: logoOpacity.clamp(0.0, 1.0),
              child: CustomPaint(
                size: Size(size, size),
                painter: _CrossLogoPainter(glowIntensity: logoOpacity),
              ),
            ),
            SizedBox(
              width: size * 0.72,
              height: size * 0.3,
              child: CustomPaint(
                painter: ECGPainter(
                  progress: ecgProgress,
                  sparkT: sparkT,
                  sparkBurst: 0,
                  lineWidth: 2.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrossLogoPainter extends CustomPainter {
  const _CrossLogoPainter({required this.glowIntensity});

  final double glowIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final arm = size.width * 0.34;
    final thick = size.width * 0.36;
    final radius = size.width * 0.13;

    if (glowIntensity > 0.05) {
      final glow = Paint()
        ..shader = ui.Gradient.radial(
          center,
          size.width * 0.55,
          [
            SplashAnimationConstants.logoGlowColor
                .withValues(alpha: 0.35 * glowIntensity),
            Colors.transparent,
          ],
        );
      canvas.drawCircle(center, size.width * 0.5, glow);
    }

    void drawArm(Rect rect, Gradient gradient) {
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
      canvas.drawRRect(
        rrect,
        Paint()..shader = gradient.createShader(rect),
      );
    }

    drawArm(
      Rect.fromCenter(center: center, width: arm, height: thick),
      AppGradients.logoLeftTeal,
    );
    drawArm(
      Rect.fromCenter(center: center, width: thick, height: arm),
      AppGradients.logoLeftTeal,
    );
    drawArm(
      Rect.fromCenter(
        center: center.translate(size.width * 0.01, 0),
        width: arm,
        height: thick,
      ),
      AppGradients.logoRightBlue,
    );
    drawArm(
      Rect.fromCenter(
        center: center.translate(0, size.height * 0.01),
        width: thick,
        height: arm,
      ),
      AppGradients.logoRightBlue,
    );

    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;

    void strokeArm(Rect rect) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        stroke,
      );
    }

    strokeArm(Rect.fromCenter(center: center, width: arm, height: thick));
    strokeArm(Rect.fromCenter(center: center, width: thick, height: arm));
  }

  @override
  bool shouldRepaint(_CrossLogoPainter oldDelegate) {
    return oldDelegate.glowIntensity != glowIntensity;
  }
}
