import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/search/search_filter_options.dart';

/// Toggleable filter chip for search sections (multi-select).
class SearchFilterChip extends StatelessWidget {
  const SearchFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? HomeDashboardColors.primary.withValues(alpha: 0.12)
            : HomeDashboardColors.surface,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            constraints: const BoxConstraints(minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? HomeDashboardColors.primary
                    : const Color(0xFFE5E8EE),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? HomeDashboardColors.primary
                    : HomeDashboardColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Section title + horizontal chip scroller.
class SearchFilterSection extends StatelessWidget {
  const SearchFilterSection({
    super.key,
    required this.title,
    required this.options,
    required this.selectedIds,
    required this.group,
    required this.onToggle,
  });

  final String title;
  final List<SearchFilterOption> options;
  final Set<String> selectedIds;
  final SearchFilterGroup group;
  final void Function(SearchFilterGroup group, String id) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: HomeDashboardColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: AppConstants.minTapTarget,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final option = options[index];
              return SearchFilterChip(
                label: option.label,
                selected: selectedIds.contains(option.id),
                onTap: () => onToggle(group, option.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
