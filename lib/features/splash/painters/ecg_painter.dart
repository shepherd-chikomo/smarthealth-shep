import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:smarthealth_shep/features/splash/constants/splash_animation_constants.dart';

/// Draws an animating ECG trace with a travelling spark pulse.
class ECGPainter extends CustomPainter {
  ECGPainter({
    required this.progress,
    required this.sparkT,
    required this.sparkBurst,
    this.lineColor = Colors.white,
    this.lineWidth = 3.2,
    this.showSpark = true,
  });

  /// 0–1 draw progress along the path.
  final double progress;

  /// 0–1 position of the travelling spark along the drawn segment.
  final double sparkT;

  /// 0–1 burst at the R-wave peak when the icon assembles.
  final double sparkBurst;

  final Color lineColor;
  final double lineWidth;
  final bool showSpark;

  static Path ecgPath(Size size) {
    final w = size.width;
    final h = size.height;
    final mid = h * 0.5;

    return Path()
      ..moveTo(0, mid)
      ..lineTo(w * 0.12, mid)
      ..lineTo(w * 0.20, mid - h * 0.38)
      ..lineTo(w * 0.28, mid + h * 0.28)
      ..lineTo(w * 0.36, mid - h * 0.14)
      ..lineTo(w * 0.48, mid)
      ..lineTo(w * 0.62, mid)
      ..lineTo(w, mid);
  }

  /// Normalized position of the main R-wave peak on the path.
  static double get peakT => 0.20 / 0.62;

  @override
  void paint(Canvas canvas, Size size) {
    final path = ecgPath(size);
    final metrics = path.computeMetrics().first;
    final drawLength = metrics.length * progress.clamp(0.0, 1.0);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final drawn = metrics.extractPath(0, drawLength);
    canvas.drawPath(drawn, linePaint);

    if (!showSpark || progress <= 0.02) return;

    final sparkPos = metrics.getTangentForOffset(
      metrics.length * (sparkT.clamp(0.0, 1.0) * progress.clamp(0.01, 1.0)),
    );
    if (sparkPos == null) return;

    final peakPos = metrics.getTangentForOffset(metrics.length * peakT);
    final center = sparkPos.position;
    final burstScale = 1.0 + sparkBurst * 2.2;
    final radius = 6.0 * burstScale;

    final glow = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius * 2.8,
        [
          SplashAnimationConstants.sparkColor.withValues(alpha: 0.85),
          SplashAnimationConstants.sparkColor.withValues(alpha: 0.2),
          Colors.transparent,
        ],
      );

    canvas.drawCircle(center, radius * 2.8, glow);
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );

    if (sparkBurst > 0.05 && peakPos != null) {
      final burstPaint = Paint()
        ..shader = ui.Gradient.radial(
          peakPos.position,
          28 * (1 + sparkBurst * SplashAnimationConstants.sparkPeakExpansion),
          [
            SplashAnimationConstants.logoGlowColor.withValues(alpha: 0.7 * sparkBurst),
            Colors.transparent,
          ],
        );
      canvas.drawCircle(peakPos.position, 32 * (1 + sparkBurst), burstPaint);
    }
  }

  @override
  bool shouldRepaint(ECGPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.sparkT != sparkT ||
        oldDelegate.sparkBurst != sparkBurst ||
        oldDelegate.showSpark != showSpark;
  }
}
