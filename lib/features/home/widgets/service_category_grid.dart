import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/data/categories.dart';
import 'package:smarthealth_shep/features/home/bloc/home_bloc.dart';
import 'package:smarthealth_shep/features/home/bloc/home_event.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/widgets/category_icon.dart';

class ServiceCategoryGrid extends StatelessWidget {
  const ServiceCategoryGrid({
    super.key,
    required this.selectedId,
    required this.labels,
  });

  final String? selectedId;
  final Map<String, String> labels;

  String _labelFor(AppCategory item) => labels[item.labelKey] ?? item.labelKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: homeServiceCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = homeServiceCategories[index];
          final label = _labelFor(item);
          final selected = (selectedId ?? 'near_me') == item.id;

          return Semantics(
            button: true,
            selected: selected,
            label: label,
            child: _CategoryTile(
              label: label,
              assetPath: item.iconAsset,
              selected: selected,
              onTap: () {
                context.read<HomeBloc>().add(
                      SelectHomeCategory(
                        item.id == 'near_me' ? null : item.id,
                      ),
                    );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.assetPath,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String assetPath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? HomeDashboardColors.primary
                        : const Color(0xFFE8EAED),
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CategoryIcon(
                    assetPath: assetPath,
                    size: 64,
                    fit: BoxFit.cover,
                    applyTint: false,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? HomeDashboardColors.primary
                      : HomeDashboardColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
