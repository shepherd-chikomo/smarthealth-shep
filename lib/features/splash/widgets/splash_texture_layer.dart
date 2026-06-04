import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smarthealth_shep/features/splash/constants/splash_animation_constants.dart';
import 'package:smarthealth_shep/features/splash/painters/ecg_painter.dart';

/// Ultra-subtle healthcare texture for splash depth (3–8% opacity).
class SplashTextureLayer extends StatelessWidget {
  const SplashTextureLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(
        painter: _SplashTexturePainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _SplashTexturePainter extends CustomPainter {
  const _SplashTexturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final baseAlpha =
        (SplashAnimationConstants.textureOpacityMin +
                SplashAnimationConstants.textureOpacityMax) /
            2;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final fill = Paint()..style = PaintingStyle.fill;

    void withOpacity(double factor, VoidCallback draw) {
      stroke.color = Colors.white.withValues(alpha: baseAlpha * factor);
      fill.color = Colors.white.withValues(alpha: baseAlpha * factor * 0.6);
      draw();
    }

    final center = Offset(size.width / 2, size.height / 2);
    withOpacity(0.9, () {
      _drawRing(canvas, center, size.shortestSide * 0.38, stroke);
      _drawRing(canvas, center, size.shortestSide * 0.52, stroke);
    });

    withOpacity(0.75, () {
      for (var i = 0; i < 5; i++) {
        final offset = Offset(
          size.width * (0.12 + i * 0.18),
          size.height * (0.18 + (i % 3) * 0.22),
        );
        _drawCross(canvas, offset, 14, stroke, fill);
      }
    });

    withOpacity(0.65, () {
      for (var i = 0; i < 3; i++) {
        final y = size.height * (0.25 + i * 0.2);
        canvas.save();
        canvas.translate(0, y);
        canvas.drawPath(
          ECGPainter.ecgPath(Size(size.width, size.height * 0.08)),
          stroke,
        );
        canvas.restore();
      }
    });

    withOpacity(0.55, () {
      _drawNodeMesh(canvas, size, stroke);
    });

    withOpacity(0.5, () {
      final rng = math.Random(7);
      for (var i = 0; i < 40; i++) {
        canvas.drawCircle(
          Offset(
            rng.nextDouble() * size.width,
            rng.nextDouble() * size.height,
          ),
          1.2,
          fill,
        );
      }
    });
  }

  void _drawRing(Canvas canvas, Offset c, double r, Paint paint) {
    canvas.drawCircle(c, r, paint);
  }

  void _drawCross(
    Canvas canvas,
    Offset c,
    double arm,
    Paint stroke,
    Paint fill,
  ) {
    final half = arm * 0.5;
    final r = Rect.fromCenter(center: c, width: arm, height: half);
    final rect = RRect.fromRectAndRadius(r, Radius.circular(half * 0.35));
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: half, height: arm),
        Radius.circular(half * 0.35),
      ),
      fill,
    );
  }

  void _drawNodeMesh(Canvas canvas, Size size, Paint paint) {
    final nodes = <Offset>[
      Offset(size.width * 0.2, size.height * 0.72),
      Offset(size.width * 0.35, size.height * 0.78),
      Offset(size.width * 0.5, size.height * 0.74),
      Offset(size.width * 0.65, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.76),
    ];
    for (final n in nodes) {
      canvas.drawCircle(n, 2.2, paint..style = PaintingStyle.fill);
    }
    for (var i = 0; i < nodes.length - 1; i++) {
      canvas.drawLine(nodes[i], nodes[i + 1], paint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
