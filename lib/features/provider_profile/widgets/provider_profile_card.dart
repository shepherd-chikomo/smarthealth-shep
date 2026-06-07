import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/provider_profile/provider_profile_utils.dart';
import 'package:smarthealth_shep/shared/utils/maps_launcher.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/widgets/smart_image.dart';

class ProviderProfileCard extends StatelessWidget {
  ProviderProfileCard({super.key, required this.provider});

  final ProviderModel provider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      color: HomeDashboardColors.of(context).surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: SmartImage(
                    source: provider.imageUrl ??
                        AppAssets.providerPortraitFor(provider.id),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    error: CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          HomeDashboardColors.of(context).primary.withValues(alpha: 0.12),
                      child: Text(
                        providerInitials(provider.name),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: HomeDashboardColors.of(context).primary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: HomeDashboardColors.of(context).textPrimary,
                        ),
                      ),
                      if (provider.specialty != null) ...[
                        SizedBox(height: 4),
                        Text(
                          provider.specialty!,
                          style: TextStyle(
                            fontSize: 14,
                            color: HomeDashboardColors.of(context).primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (provider.mdpczNumber != null) ...[
                        SizedBox(height: 4),
                        Text(
                          provider.mdpczNumber!,
                          style: TextStyle(
                            fontSize: 12,
                            color: HomeDashboardColors.of(context).textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (provider.isVerified) ...[
              SizedBox(height: 12),
              _MdpczVerifiedBadge(label: l10n.profileMdpczVerified),
            ],
            if (provider.distanceKm != null) ...[
              SizedBox(height: 16),
              Divider(height: 1),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Symbols.near_me,
                    size: 18,
                    color: HomeDashboardColors.of(context).textSecondary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    l10n.homeDistanceKm(provider.distanceKm!),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: HomeDashboardColors.of(context).textPrimary,
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
  _MdpczVerifiedBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: HomeDashboardColors.of(context).secondary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.verified,
              size: 16,
              color: HomeDashboardColors.of(context).secondary,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: HomeDashboardColors.of(context).secondary,
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
                backgroundColor: HomeDashboardColors.of(context).secondary,
                minimumSize: const Size.fromHeight(AppConstants.minTapTarget),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Symbols.call),
              label: Text(callLabel),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Semantics(
            button: true,
            label: directionsLabel,
            child: FilledButton.icon(
              onPressed: provider.mapsQuery != null ? onDirections : null,
              style: FilledButton.styleFrom(
                backgroundColor: HomeDashboardColors.of(context).primary,
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
