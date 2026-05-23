import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/theme/app_colors.dart';

/// Outward red glow pulse every 2s — mirrors web `pulse-emergency` keyframes.
class PulseEmergency extends StatefulWidget {
  const PulseEmergency({
    super.key,
    required this.child,
    this.glowColor,
    this.maxSpread = 12,
    this.duration = const Duration(seconds: 2),
  });

  final Widget child;
  final Color? glowColor;
  final double maxSpread;
  final Duration duration;

  @override
  State<PulseEmergency> createState() => _PulseEmergencyState();
}

class _PulseEmergencyState extends State<PulseEmergency>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = widget.glowColor ?? context.appColors.emergency;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 0 → 12px outward spread, opacity 0.45 → 0 (mirrors keyframes).
        final t = _controller.value;
        final spread = widget.maxSpread * t;
        final opacity = 0.45 * (1 - t);

        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: glow.withValues(alpha: opacity),
                blurRadius: 0,
                spreadRadius: spread,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
