import 'package:flutter/material.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/search/models/search_sort_option.dart';

/// Horizontal sort selector for directory results.
class SearchSortBar extends StatelessWidget {
  const SearchSortBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final SearchSortOption selected;
  final ValueChanged<SearchSortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: SearchSortOption.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = SearchSortOption.values[index];
          final isSelected = option == selected;
          return Semantics(
            button: true,
            selected: isSelected,
            label: 'Sort by ${option.label}',
            child: Material(
              color: isSelected
                  ? HomeDashboardColors.primary.withValues(alpha: 0.12)
                  : HomeDashboardColors.surface,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: () => onChanged(option),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? HomeDashboardColors.primary
                          : const Color(0xFFE5E8EE),
                    ),
                  ),
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? HomeDashboardColors.primary
                          : HomeDashboardColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
