import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/widgets/smart_image.dart';

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

    return Semantics(
      button: onTap != null,
      label: _semanticLabel(l10n),
      child: Material(
        color: HomeDashboardColors.surface,
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
                const SizedBox(width: 12),
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
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: HomeDashboardColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (provider.isVerified) ...[
                            const SizedBox(width: 6),
                            _MdpczBadge(label: l10n.homeMdpczVerified),
                          ],
                        ],
                      ),
                      if (provider.specialty != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          provider.specialty!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: HomeDashboardColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (provider.facilityName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          provider.facilityName!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: HomeDashboardColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (distance != null) ...[
                            const Icon(
                              Icons.near_me_outlined,
                              size: 14,
                              color: HomeDashboardColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distance,
                              style: const TextStyle(
                                fontSize: 12,
                                color: HomeDashboardColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (provider.hours != null)
                            Expanded(
                              child: Text(
                                provider.hours!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: HomeDashboardColors.textSecondary,
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

  String _semanticLabel(AppLocalizations l10n) {
    final verified =
        provider.isVerified ? ', ${l10n.homeMdpczVerified}' : '';
    return '${provider.name}$verified';
  }
}

class _MdpczBadge extends StatelessWidget {
  const _MdpczBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: HomeDashboardColors.secondary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppAssets.verifiedBadge,
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(
                HomeDashboardColors.secondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 2),
            const Text(
              'MDPCZ',
              style: TextStyle(
                fontSize: 10,
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
      borderRadius: BorderRadius.circular(12),
      memCacheWidth: 144,
      memCacheHeight: 144,
      placeholder: Container(
        width: size,
        height: size,
        color: HomeDashboardColors.skeleton,
        child: const Center(
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
          color: HomeDashboardColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.local_hospital_outlined,
          color: HomeDashboardColors.primary,
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
