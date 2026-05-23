import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/app_button.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/design_system_tokens.dart';

/// Placeholder empty view with optional call-to-action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.useBundledIllustration = true,
    this.actionLabel,
    this.onAction,
    this.actionType = AppButtonType.primary,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final bool useBundledIllustration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AppButtonType actionType;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (useBundledIllustration)
              SvgPicture.asset(
                AppAssets.emptyState,
                width: 120,
                height: 120,
              )
            else
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: DesignSystemColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.inbox_outlined,
                  size: 40,
                  color: DesignSystemColors.primary.withValues(alpha: 0.7),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: DesignSystemColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: DesignSystemColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                type: actionType,
                fullWidth: false,
                compact: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
