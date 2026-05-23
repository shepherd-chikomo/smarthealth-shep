import 'package:flutter/material.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/design_system_tokens.dart';

/// Toggleable filter/tag chip for wrap layouts.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? DesignSystemColors.primaryLight
        : DesignSystemColors.surface;
    final borderColor =
        selected ? DesignSystemColors.primary : DesignSystemColors.border;
    final textColor = selected
        ? DesignSystemColors.primary
        : DesignSystemColors.textPrimary;

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: label,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(DesignSystemMetrics.radiusPill),
        child: InkWell(
          onTap: enabled ? () => onSelected(!selected) : null,
          borderRadius: BorderRadius.circular(DesignSystemMetrics.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignSystemMetrics.radiusPill),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: textColor),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: enabled
                        ? textColor
                        : DesignSystemColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal wrap of [AppChip] widgets with consistent spacing.
class AppChipWrap extends StatelessWidget {
  const AppChipWrap({
    super.key,
    required this.labels,
    required this.selected,
    required this.onToggle,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  final List<String> labels;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: labels.map((label) {
        final isSelected = selected.contains(label);
        return AppChip(
          label: label,
          selected: isSelected,
          onSelected: (_) => onToggle(label),
        );
      }).toList(),
    );
  }
}
