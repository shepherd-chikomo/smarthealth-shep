import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/widgets/smart_image.dart';

/// Compact provider header shown at the top of the booking date screen.
class ProviderMiniCard extends StatelessWidget {  ProviderMiniCard({super.key, required this.provider});

  final ProviderModel provider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeDashboardColors.of(context).surface,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E8EE)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SmartImage(
                source: provider.imageUrl ??
                    AppAssets.providerPortraitFor(provider.id),
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                error: _PlaceholderAvatar(name: provider.name),
              ),
            ),            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: HomeDashboardColors.of(context).textPrimary,
                    ),
                  ),
                  if (provider.specialty != null) ...[
                    SizedBox(height: 2),
                    Text(
                      provider.specialty!,
                      style: TextStyle(
                        fontSize: 13,
                        color: HomeDashboardColors.of(context).textSecondary,
                      ),
                    ),
                  ],
                  if (provider.facilityName != null) ...[
                    SizedBox(height: 2),
                    Text(
                      provider.facilityName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: HomeDashboardColors.of(context).textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (provider.isVerified)
              Icon(
                Icons.verified,
                size: 20,
                color: HomeDashboardColors.of(context).primary,
              ),          ],
        ),
      ),
    );
  }
}

class _PlaceholderAvatar extends StatelessWidget {
  _PlaceholderAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return ColoredBox(
      color: HomeDashboardColors.of(context).primary.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: HomeDashboardColors.of(context).primary,
          ),
        ),
      ),
    );
  }
}
