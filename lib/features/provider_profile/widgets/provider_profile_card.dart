import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/provider_profile/provider_profile_utils.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

class ProviderProfileCard extends StatelessWidget {
  const ProviderProfileCard({super.key, required this.provider});

  final ProviderModel provider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      color: HomeDashboardColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor:
                      HomeDashboardColors.primary.withValues(alpha: 0.12),
                  backgroundImage: provider.imageUrl != null &&
                          provider.imageUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(provider.imageUrl!)
                      : null,
                  child: provider.imageUrl == null || provider.imageUrl!.isEmpty
                      ? Text(
                          providerInitials(provider.name),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: HomeDashboardColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: HomeDashboardColors.textPrimary,
                        ),
                      ),
                      if (provider.specialty != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          provider.specialty!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: HomeDashboardColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (provider.mdpczNumber != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          provider.mdpczNumber!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: HomeDashboardColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (provider.isVerified) ...[
              const SizedBox(height: 12),
              _MdpczVerifiedBadge(label: l10n.profileMdpczVerified),
            ],
            if (provider.distanceKm != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Symbols.near_me,
                    size: 18,
                    color: HomeDashboardColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.homeDistanceKm(provider.distanceKm!),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: HomeDashboardColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MdpczVerifiedBadge extends StatelessWidget {
  const _MdpczVerifiedBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: HomeDashboardColors.secondary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Symbols.verified,
              size: 16,
              color: HomeDashboardColors.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: HomeDashboardColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderActionButtons extends StatelessWidget {
  const ProviderActionButtons({
    super.key,
    required this.provider,
    required this.onCall,
    required this.onDirections,
    required this.callLabel,
    required this.directionsLabel,
  });

  final ProviderModel provider;
  final VoidCallback onCall;
  final VoidCallback onDirections;
  final String callLabel;
  final String directionsLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: callLabel,
            child: FilledButton.icon(
              onPressed: provider.phone != null ? onCall : null,
              style: FilledButton.styleFrom(
                backgroundColor: HomeDashboardColors.secondary,
                minimumSize: const Size.fromHeight(AppConstants.minTapTarget),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Symbols.call),
              label: Text(callLabel),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            button: true,
            label: directionsLabel,
            child: FilledButton.icon(
              onPressed: provider.mapsQuery != null ? onDirections : null,
              style: FilledButton.styleFrom(
                backgroundColor: HomeDashboardColors.primary,
                minimumSize: const Size.fromHeight(AppConstants.minTapTarget),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Symbols.directions),
              label: Text(directionsLabel),
            ),
          ),
        ),
      ],
    );
  }
}
