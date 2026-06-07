import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/models/operational_status.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/availability_indicator.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/status_chip.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/verification_badge.dart';
import 'package:smarthealth_shep/shared/widgets/smart_image.dart';
import 'package:smarthealth_shep/core/assets.dart';

/// Reusable nearby-facility card for the home dashboard and search results.
class ProviderCard extends StatelessWidget {
  const ProviderCard({
    super.key,
    required this.provider,
    this.onTap,
  });

  final ProviderModel provider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final distance = provider.distanceKm != null
        ? l10n.homeDistanceKm(provider.distanceKm!)
        : null;
    final imageSource =
        provider.imageUrl ?? AppAssets.providerPortraitFor(provider.id);
    final hasOperationalInfo = _hasOperationalInfo(provider);

    return Semantics(
      button: onTap != null,
      label: _semanticLabel(l10n),
      child: Material(
        color: HomeDashboardColors.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E8EE)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(imageSource: imageSource),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              provider.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: HomeDashboardColors.of(context).textPrimary,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (provider.isVerified) ...[
                            const SizedBox(width: 6),
                            VerificationBadge(
                              style: VerificationBadgeStyle.source,
                              source: provider.verificationSource ?? 'MDPCZ',
                            ),
                          ],
                          if (provider.rating != null) ...[
                            SizedBox(width: 6),
                            _RatingBadge(rating: provider.rating!),
                          ],
                        ],
                      ),
                      if (provider.specialty != null) ...[
                        SizedBox(height: 2),
                        Text(
                          provider.specialty!,
                          style: TextStyle(
                            fontSize: 13,
                            color: HomeDashboardColors.of(context).primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (provider.facilityName != null) ...[
                        SizedBox(height: 4),
                        Text(
                          provider.facilityName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: HomeDashboardColors.of(context).textSecondary,
                          ),
                        ),
                      ],
                      if (hasOperationalInfo) ...[
                        SizedBox(height: 6),
                        AvailabilityIndicator.fromProvider(provider),
                        if (_hasOperationalBadges(provider)) ...[
                          SizedBox(height: 6),
                          _OperationalBadges(provider: provider),
                        ],
                      ],
                      SizedBox(height: 8),
                      Row(
                        children: [
                          if (distance != null) ...[
                            Icon(
                              Icons.near_me_outlined,
                              size: 14,
                              color: HomeDashboardColors.of(context).textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              distance,
                              style: TextStyle(
                                fontSize: 12,
                                color: HomeDashboardColors.of(context).textSecondary,
                              ),
                            ),
                            SizedBox(width: 12),
                          ],
                          if (provider.hours != null && !hasOperationalInfo)
                            Expanded(
                              child: Text(
                                provider.hours!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: HomeDashboardColors.of(context).textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasOperationalInfo(ProviderModel provider) {
    return provider.isOpenNow != null ||
        provider.isClosingSoon == true ||
        provider.queueLength != null ||
        provider.waitEstimateMinutes != null ||
        provider.nextAvailableSlot != null;
  }

  bool _hasOperationalBadges(ProviderModel provider) {
    return provider.acceptsWalkIns == true ||
        provider.hasQueue == true ||
        provider.availableToday == true ||
        provider.emergencyAvailable == true;
  }

  String _semanticLabel(AppLocalizations l10n) {
    final verified =
        provider.isVerified ? ', ${l10n.homeMdpczVerified}' : '';
    final open = provider.isOpenNow == true ? ', Open Now' : '';
    final queue = provider.queueLength != null
        ? ', Queue ${provider.queueLength}'
        : '';
    return '${provider.name}$verified$open$queue';
  }
}

class _OperationalBadges extends StatelessWidget {
  const _OperationalBadges({required this.provider});

  final ProviderModel provider;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (provider.emergencyAvailable == true)
          StatusChip.facility(FacilityOperationalStatus.emergencyAvailable),
        if (provider.hasQueue == true && provider.queueLength == null)
          StatusChip.facility(FacilityOperationalStatus.queueAvailable),
        if (provider.acceptsWalkIns == true)
          StatusChip.facility(FacilityOperationalStatus.walkInsAccepted),
        if (provider.availableToday == true)
          StatusChip.facility(FacilityOperationalStatus.availableToday),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: HomeDashboardColors.of(context).primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 14,
            color: HomeDashboardColors.of(context).primary,
          ),
          SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: HomeDashboardColors.of(context).primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.imageSource});

  final String? imageSource;

  static const double size = 72;

  @override
  Widget build(BuildContext context) {
    return SmartImage(
      source: imageSource,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(size / 2),
      memCacheWidth: 144,
      memCacheHeight: 144,
      placeholder: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: HomeDashboardColors.of(context).skeleton,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: HomeDashboardColors.of(context).background,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(
          Icons.local_hospital_outlined,
          color: HomeDashboardColors.of(context).primary,
          size: 32,
        ),
      ),
    );
  }
}

/// Formats a last-updated timestamp for offline badge display.
String formatLastUpdated(DateTime dateTime) {
  return DateFormat('d MMM, HH:mm').format(dateTime);
}
