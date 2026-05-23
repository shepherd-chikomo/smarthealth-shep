import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/design_system_tokens.dart';

enum VerificationBadgeSize { small, large }

/// Green pill badge indicating MDPCZ provider verification.
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({
    super.key,
    this.size = VerificationBadgeSize.small,
    this.label = 'MDPCZ Verified',
  });

  final VerificationBadgeSize size;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isLarge = size == VerificationBadgeSize.large;
    final fontSize = isLarge ? 13.0 : 11.0;
    final iconSize = isLarge ? 16.0 : 14.0;
    final padding = isLarge
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    return Semantics(
      label: label,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: DesignSystemColors.success.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(DesignSystemMetrics.radiusPill),
          border: Border.all(
            color: DesignSystemColors.success.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.verified,
              size: iconSize,
              color: DesignSystemColors.success,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: DesignSystemColors.success,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
