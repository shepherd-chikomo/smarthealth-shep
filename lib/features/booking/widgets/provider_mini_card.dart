import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/widgets/smart_image.dart';

/// Compact provider header shown at the top of the booking date screen.
class ProviderMiniCard extends StatelessWidget {  const ProviderMiniCard({super.key, required this.provider});

  final ProviderModel provider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeDashboardColors.surface,
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
            ),            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: HomeDashboardColors.textPrimary,
                    ),
                  ),
                  if (provider.specialty != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      provider.specialty!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: HomeDashboardColors.textSecondary,
                      ),
                    ),
                  ],
                  if (provider.facilityName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      provider.facilityName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: HomeDashboardColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (provider.isVerified)
              const Icon(
                Icons.verified,
                size: 20,
                color: HomeDashboardColors.primary,
              ),          ],
        ),
      ),
    );
  }
}

class _PlaceholderAvatar extends StatelessWidget {
  const _PlaceholderAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return ColoredBox(
      color: HomeDashboardColors.primary.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: HomeDashboardColors.primary,
          ),
        ),
      ),
    );
  }
}
