import 'package:flutter/material.dart';

/// Constrains content to a 480px column on tablets/desktop; full width on phones.
class ConstrainedShell extends StatelessWidget {
  const ConstrainedShell({super.key, required this.child});

  static const double maxContentWidth = 480;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }
}
