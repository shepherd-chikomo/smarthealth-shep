import 'package:flutter/material.dart';

/// Header wordmark rendered with Flutter text — reliable on all platforms.
/// Red Smart + white Health with integrated stethoscope heart graphic.
class SmartHealthHeaderLogo extends StatelessWidget {
  const SmartHealthHeaderLogo({
    super.key,
    required this.width,
  });

  final double width;

  static const _aspectRatio = 4.6;
  static const _red = Color(0xFFE30613);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width / _aspectRatio,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Smart',
              style: TextStyle(
                color: _red,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: -0.5,
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 2),
                  child: Text(
                    'Health',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: -6,
                  child: CustomPaint(
                    size: const Size(72, 52),
                    painter: _StethoscopeHeartPainter(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StethoscopeHeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const silver = Color(0xFFD0D0D0);
    const dark = Color(0xFF424242);

    final earPaint = Paint()
      ..color = silver
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.28, 0, size.width * 0.44, size.height * 0.35),
      3.14,
      3.14,
      false,
      earPaint,
    );
    canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.08), 3, earPaint);
    canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.08), 3, earPaint);

    final tubePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final heart = Path();
    final cx = size.width * 0.42;
    final cy = size.height * 0.52;
    final s = size.width * 0.11;
    heart.moveTo(cx, cy + s * 1.1);
    heart.cubicTo(cx - s * 1.8, cy - s * 0.4, cx - s * 0.7, cy - s * 1.8, cx, cy - s * 0.8);
    heart.cubicTo(cx + s * 0.7, cy - s * 1.8, cx + s * 1.8, cy - s * 0.4, cx, cy + s * 1.1);
    canvas.drawPath(heart, tubePaint);

    final pulse = Paint()
      ..color = SmartHealthHeaderLogo._red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawLine(Offset(cx - s, cy), Offset(cx - s * 0.3, cy), pulse);
    canvas.drawLine(Offset(cx - s * 0.3, cy), Offset(cx - s * 0.1, cy - s * 0.5), pulse);
    canvas.drawLine(Offset(cx - s * 0.1, cy - s * 0.5), Offset(cx + s * 0.2, cy + s * 0.5), pulse);
    canvas.drawLine(Offset(cx + s * 0.2, cy + s * 0.5), Offset(cx + s * 0.9, cy - s * 0.3), pulse);

    canvas.drawLine(
      Offset(cx + s * 0.5, cy + s * 0.8),
      Offset(size.width * 0.82, cy + s * 0.4),
      tubePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.86, cy + s * 0.35),
      size.width * 0.09,
      Paint()
        ..color = silver
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.86, cy + s * 0.35),
      size.width * 0.09,
      Paint()
        ..color = const Color(0xFFBDBDBD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      Offset(size.width * 0.86, cy + s * 0.35),
      size.width * 0.045,
      Paint()..color = dark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
