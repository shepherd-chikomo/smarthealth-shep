import 'package:flutter/material.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/design_system_tokens.dart';

/// Compact queue-length badge in primary blue.
class QueueIndicator extends StatelessWidget {
  const QueueIndicator({
    super.key,
    required this.length,
    this.compact = true,
  });

  final int length;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = DesignSystemColors.primary;
    final label = 'Queue: $length';

    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(
            compact ? 6 : DesignSystemMetrics.radiusPill,
          ),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: compact ? 12 : 14,
              color: color,
            ),
            SizedBox(width: compact ? 2 : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
