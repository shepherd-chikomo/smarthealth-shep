import 'package:flutter/material.dart';

class ClaimStepChips extends StatelessWidget {
  const ClaimStepChips({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  final List<String> steps;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(steps.length, (index) {
        final done = index < currentIndex;
        final active = index == currentIndex;
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? colorScheme.primary
                : done
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (done)
                Icon(
                  Icons.check,
                  size: 14,
                  color: colorScheme.onPrimaryContainer,
                ),
              if (done) const SizedBox(width: 4),
              Text(
                steps[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? colorScheme.onPrimary
                      : done
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
