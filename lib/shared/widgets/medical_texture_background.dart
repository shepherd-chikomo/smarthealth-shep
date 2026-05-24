import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Sparse medical doodle pattern for header and body backgrounds.
class MedicalTextureBackground extends StatelessWidget {
  const MedicalTextureBackground({
    super.key,
    required this.child,
    this.baseColor,
    this.patternColor,
    this.patternOpacity = 0.1,
  });

  final Widget child;
  final Color? baseColor;
  final Color? patternColor;
  final double patternOpacity;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: baseColor ?? const Color(0xFFD8D9DB),
      child: CustomPaint(
        painter: _MedicalTexturePainter(
          color: (patternColor ?? const Color(0xFF9AA0A8))
              .withValues(alpha: patternOpacity),
        ),
        child: child,
      ),
    );
  }
}

class _MedicalTexturePainter extends CustomPainter {
  const _MedicalTexturePainter({required this.color});

  final Color color;

  static const _tileSize = 256.0;
  static const _iconSize = 104.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var row = -1; row < size.height / _tileSize + 1; row++) {
      for (var col = -1; col < size.width / _tileSize + 1; col++) {
        final origin = Offset(col * _tileSize, row * _tileSize);
        final index = (row * 3 + col * 2).abs() % 6;
        final center = origin + Offset(_tileSize * 0.5, _tileSize * 0.5);

        switch (index) {
          case 0:
            _drawHeart(canvas, center, paint, fillPaint);
          case 1:
            _drawPill(canvas, center, paint, fillPaint);
          case 2:
            _drawStethoscope(canvas, center, paint);
          case 3:
            _drawDna(canvas, center, paint);
          case 4:
            _drawSyringe(canvas, center, paint, fillPaint);
          case 5:
            _drawMedicalCross(canvas, center, paint, fillPaint);
        }
      }
    }
  }

  void _drawHeart(Canvas canvas, Offset c, Paint paint, Paint fill) {
    final path = Path();
    final s = _iconSize * 0.22;
    path.moveTo(c.dx, c.dy + s * 1.2);
    path.cubicTo(
      c.dx - s * 2,
      c.dy - s,
      c.dx - s * 0.8,
      c.dy - s * 2.2,
      c.dx,
      c.dy - s,
    );
    path.cubicTo(
      c.dx + s * 0.8,
      c.dy - s * 2.2,
      c.dx + s * 2,
      c.dy - s,
      c.dx,
      c.dy + s * 1.2,
    );
    canvas.drawPath(path, paint);
    canvas.drawCircle(c + Offset(-s * 0.4, -s * 1.2), s * 0.35, fill);
    canvas.drawCircle(c + Offset(s * 0.4, -s * 1.2), s * 0.35, fill);
  }

  void _drawPill(Canvas canvas, Offset c, Paint paint, Paint fill) {
    final w = _iconSize * 0.42;
    final h = _iconSize * 0.18;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: w, height: h),
      Radius.circular(h),
    );
    canvas.drawRRect(rect, paint);
    canvas.drawLine(
      Offset(c.dx, c.dy - h * 0.55),
      Offset(c.dx, c.dy + h * 0.55),
      paint,
    );
    canvas.drawCircle(c + Offset(-w * 0.18, 0), h * 0.12, fill);
  }

  void _drawStethoscope(Canvas canvas, Offset c, Paint paint) {
    final r = _iconSize * 0.16;
    canvas.drawArc(
      Rect.fromCircle(center: c + Offset(0, r * 0.4), radius: r * 1.4),
      math.pi * 0.15,
      math.pi * 0.7,
      false,
      paint,
    );
    canvas.drawCircle(c + Offset(-r * 1.1, -r * 1.2), r * 0.45, paint);
    canvas.drawCircle(c + Offset(r * 1.1, -r * 1.2), r * 0.45, paint);
    canvas.drawCircle(c + Offset(0, r * 1.6), r * 0.55, paint);
  }

  void _drawDna(Canvas canvas, Offset c, Paint paint) {
    final h = _iconSize * 0.35;
    final path = Path();
    for (var i = 0; i <= 8; i++) {
      final t = i / 8;
      final y = c.dy - h + t * h * 2;
      final x = c.dx + math.sin(t * math.pi * 2) * h * 0.45;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
    for (var i = 0; i <= 8; i++) {
      final t = i / 8;
      final y = c.dy - h + t * h * 2;
      final x1 = c.dx + math.sin(t * math.pi * 2) * h * 0.45;
      final x2 = c.dx - math.sin(t * math.pi * 2) * h * 0.45;
      canvas.drawLine(Offset(x1, y), Offset(x2, y), paint);
    }
  }

  void _drawSyringe(Canvas canvas, Offset c, Paint paint, Paint fill) {
    final len = _iconSize * 0.34;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c + Offset(-len * 0.15, 0),
          width: len * 0.55,
          height: len * 0.16,
        ),
        const Radius.circular(3),
      ),
      paint,
    );
    canvas.drawLine(
      c + Offset(len * 0.12, 0),
      c + Offset(len * 0.42, 0),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c + Offset(-len * 0.42, 0),
          width: len * 0.22,
          height: len * 0.28,
        ),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawCircle(c + Offset(-len * 0.42, 0), len * 0.06, fill);
  }

  void _drawMedicalCross(Canvas canvas, Offset c, Paint paint, Paint fill) {
    final s = _iconSize * 0.14;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: s * 2.2, height: s * 0.7),
        Radius.circular(s * 0.15),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: s * 0.7, height: s * 2.2),
        Radius.circular(s * 0.15),
      ),
      paint,
    );
    canvas.drawCircle(c, s * 0.18, fill);
  }

  @override
  bool shouldRepaint(covariant _MedicalTexturePainter oldDelegate) =>
      oldDelegate.color != color;
}
