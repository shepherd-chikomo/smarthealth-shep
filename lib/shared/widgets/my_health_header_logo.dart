import 'package:flutter/material.dart';

/// Home header wordmark — My (red) + Health (white).
class MyHealthHeaderLogo extends StatelessWidget {
  const MyHealthHeaderLogo({
    super.key,
    required this.width,
  });

  final double width;

  static const _aspectRatio = 5.2;
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
              'My',
              style: TextStyle(
                color: _red,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Health',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
