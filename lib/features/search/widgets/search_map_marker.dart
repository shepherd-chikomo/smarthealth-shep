import 'package:flutter/material.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Map marker styled by operational state.
class SearchMapMarker extends StatelessWidget {
  const SearchMapMarker({
    super.key,
    required this.provider,
    required this.selected,
    required this.onTap,
  });

  final ProviderModel provider;
  final bool selected;
  final VoidCallback onTap;

  Color get _fillColor {
    if (provider.emergencyAvailable == true) {
      return HomeDashboardColors.emergency;
    }
    if (provider.isOpenNow == true) {
      return HomeDashboardColors.primary;
    }
    return HomeDashboardColors.textSecondary.withValues(alpha: 0.55);
  }

  bool get _hasQueueRing => provider.hasQueue == true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_hasQueueRing)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: HomeDashboardColors.secondary,
                    width: 3,
                  ),
                ),
              ),
            if (selected)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: HomeDashboardColors.textPrimary,
                    width: 2,
                  ),
                ),
              ),
            Icon(
              Icons.location_on,
              size: 36,
              color: _fillColor,
            ),
          ],
        ),
      ),
    );
  }
}
