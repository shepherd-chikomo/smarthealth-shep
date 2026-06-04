import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/home/bloc/home_bloc.dart';
import 'package:smarthealth_shep/features/home/bloc/home_event.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/service_category_model.dart';
import 'package:smarthealth_shep/shared/widgets/category_icon.dart';

/// Horizontal category filters loaded from the facility-type catalog API.
class ServiceCategoryGrid extends StatelessWidget {
  const ServiceCategoryGrid({
    super.key,
    required this.categories,
    required this.selectedId,
  });

  final List<ServiceCategoryModel> categories;
  final String? selectedId;

  static const _tileSize = 68.0;
  static const _iconSize = 48.0;
  static const _iconPadding = 10.0;
  static const _tileRadius = 16.0;
  static const _itemWidth = 76.0;
  static const _rowHeight = 102.0;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox(height: _rowHeight);
    }

    return SizedBox(
      height: _rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = categories[index];
          final selected = (selectedId ?? 'near_me') == item.id;

          return Semantics(
            button: true,
            selected: selected,
            label: item.name,
            child: _CategoryTile(
              label: item.name,
              assetPath: item.iconAsset,
              selected: selected,
              onTap: () {
                context.read<HomeBloc>().add(
                      SelectHomeCategory(
                        item.isNearMe ? null : item.id,
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
      width: ServiceCategoryGrid._itemWidth,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ServiceCategoryGrid._tileRadius),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: ServiceCategoryGrid._tileSize,
                height: ServiceCategoryGrid._tileSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(ServiceCategoryGrid._tileRadius),
                  border: Border.all(
                    color: selected
                        ? HomeDashboardColors.primary
                        : const Color(0xFFE8EAED),
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      ServiceCategoryGrid._iconPadding,
                    ),
                    child: CategoryIcon(
                      assetPath: assetPath,
                      size: ServiceCategoryGrid._iconSize,
                      fit: BoxFit.contain,
                      applyTint: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: HomeDashboardColors.textPrimary,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
