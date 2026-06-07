import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/profile/utils/profile_completion_calculator.dart';

/// Shared completion ring — percentage sits below the arc to avoid label overlap.
class ProfileCompletionRing extends StatelessWidget {
  const ProfileCompletionRing({
    super.key,
    required this.percentage,
    required this.band,
    this.size = 112,
    this.strokeWidth = 8,
    this.percentageFontSize = 28,
    this.showCheckWhenComplete = true,
  });

  final int percentage;
  final ProfileCompletionBand band;
  final double size;
  final double strokeWidth;
  final double percentageFontSize;
  final bool showCheckWhenComplete;

  @override
  Widget build(BuildContext context) {
    final bandColor = completionBandColor(band, context);
    final isComplete = band == ProfileCompletionBand.complete;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: percentage / 100),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: value,
                      strokeWidth: strokeWidth,
                      backgroundColor: bandColor.withValues(alpha: 0.12),
                      color: bandColor,
                    ),
                    if (isComplete && showCheckWhenComplete)
                      Icon(
                        Symbols.check_circle,
                        color: bandColor,
                        size: size * 0.32,
                      ),
                  ],
                ),
              ),
              if (!isComplete || !showCheckWhenComplete) ...[
                const SizedBox(height: 8),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: percentageFontSize,
                    fontWeight: FontWeight.w800,
                    color: bandColor,
                    height: 1,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
