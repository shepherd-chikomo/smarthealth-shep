import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/design_system_tokens.dart';

enum AppButtonType { primary, secondary, accent, danger, ghost }

/// Themed action button with loading and disabled states.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.fullWidth = true,
    this.compact = false,
    this.isLoading = false,
    this.icon,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool fullWidth;
  final bool compact;
  final bool isLoading;
  final IconData? icon;
  final String? semanticLabel;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(type, enabled: _enabled);
    final height =
        compact ? DesignSystemMetrics.buttonHeightCompact : AppConstants.minTapTarget;

    final child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: style.foregroundColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: style.foregroundColor),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 14 : 15,
                  color: style.foregroundColor,
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: semanticLabel ?? label,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        height: height,
        child: Material(
          color: style.backgroundColor,
          elevation: 0,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(DesignSystemMetrics.radiusMd),
          child: InkWell(
            onTap: _enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(DesignSystemMetrics.radiusMd),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignSystemMetrics.radiusMd),
                border: style.border,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  _ButtonStyle _styleFor(AppButtonType type, {required bool enabled}) {
    if (!enabled) {
      return _ButtonStyle(
        backgroundColor: DesignSystemColors.border.withValues(alpha: 0.5),
        foregroundColor: DesignSystemColors.textSecondary,
      );
    }

    return switch (type) {
      AppButtonType.primary => _ButtonStyle(
          backgroundColor: DesignSystemColors.primary,
          foregroundColor: Colors.white,
        ),
      AppButtonType.secondary => _ButtonStyle(
          backgroundColor: DesignSystemColors.secondary,
          foregroundColor: Colors.white,
        ),
      AppButtonType.accent => _ButtonStyle(
          backgroundColor: DesignSystemColors.accent,
          foregroundColor: Colors.white,
        ),
      AppButtonType.danger => _ButtonStyle(
          backgroundColor: DesignSystemColors.emergency,
          foregroundColor: Colors.white,
        ),
      AppButtonType.ghost => _ButtonStyle(
          backgroundColor: Colors.transparent,
          foregroundColor: DesignSystemColors.primary,
          border: Border.all(color: DesignSystemColors.primary),
        ),
    };
  }
}

class _ButtonStyle {
  const _ButtonStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    this.border,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final BoxBorder? border;
}
