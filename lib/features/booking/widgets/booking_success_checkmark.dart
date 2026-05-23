import 'package:flutter/material.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';

/// Animated checkmark for the booking success screen.
class BookingSuccessCheckmark extends StatefulWidget {
  const BookingSuccessCheckmark({super.key});

  @override
  State<BookingSuccessCheckmark> createState() =>
      _BookingSuccessCheckmarkState();
}

class _BookingSuccessCheckmarkState extends State<BookingSuccessCheckmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _checkOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _checkOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: HomeDashboardColors.secondary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: FadeTransition(
          opacity: _checkOpacity,
          child: const Icon(
            Icons.check_rounded,
            size: 56,
            color: HomeDashboardColors.secondary,
          ),
        ),
      ),
    );
  }
}
