import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/design_system_tokens.dart';

/// Search field with icon, clear action, and focus styling.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.placeholder = 'Search…',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller,
        ?focusNode,
      ]),
      builder: (context, _) {
        final focused = focusNode?.hasFocus ?? false;
        final hasText = controller.text.isNotEmpty;

        return Semantics(
          textField: true,
          label: placeholder,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: DesignSystemColors.surface,
              borderRadius: BorderRadius.circular(DesignSystemMetrics.radiusMd),
              border: Border.all(
                color: focused
                    ? DesignSystemColors.primary
                    : DesignSystemColors.border,
                width: focused ? 1.5 : 1,
              ),
              boxShadow: focused
                  ? [
                      BoxShadow(
                        color: DesignSystemColors.primary.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: const TextStyle(
                color: DesignSystemColors.textPrimary,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(color: DesignSystemColors.textSecondary),
                prefixIcon: const Icon(
                  Symbols.search,
                  color: DesignSystemColors.textSecondary,
                ),
                suffixIcon: hasText
                    ? IconButton(
                        icon: const Icon(
                          Symbols.close,
                          size: 20,
                          color: DesignSystemColors.textSecondary,
                        ),
                        onPressed: () {
                          controller.clear();
                          onChanged?.call('');
                          onClear?.call();
                        },
                        tooltip: 'Clear search',
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        );
      },
    );
  }
}
