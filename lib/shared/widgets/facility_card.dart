import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/location/location_service.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/verification_badge.dart';
import 'package:smarthealth_shep/shared/widgets/smart_image.dart';

/// Nearby healthcare facility card for home and directory lists.
class FacilityCard extends StatelessWidget {
  const FacilityCard({
    super.key,
    required this.facility,
    this.onTap,
  });

  final FacilityModel facility;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final distance = facility.distanceKm != null
        ? LocationService.formatDistance(facility.distanceKm!)
        : null;
    final subtitle = _formatFacilityType(facility.facilityType);
    final location = [
      if (facility.addressLine1 != null && facility.addressLine1!.isNotEmpty)
        facility.addressLine1,
      facility.city,
    ].whereType<String>().join(', ');

    return Semantics(
      button: onTap != null,
      label: '${facility.name}, $subtitle',
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
                _Thumbnail(
                  logoPath: facility.logoPath,
                  facilityType: facility.facilityType,
                ),
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
                              facility.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: HomeDashboardColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (facility.isVerified) ...[
                            const SizedBox(width: 6),
                            const VerificationBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: HomeDashboardColors.textSecondary,
                        ),
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: HomeDashboardColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (distance != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Symbols.near_me,
                              size: 14,
                              color: HomeDashboardColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distance,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: HomeDashboardColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  static String _formatFacilityType(String type) {
    return switch (type) {
      'hospital' => 'Hospital',
      'clinic' => 'Clinic',
      'pharmacy' => 'Pharmacy',
      'laboratory' => 'Laboratory',
      'dental' => 'Dental',
      'optometry' => 'Optometry',
      'imaging' => 'Imaging',
      _ => 'Healthcare facility',
    };
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.logoPath,
    required this.facilityType,
  });

  final String? logoPath;
  final String facilityType;

  @override
  Widget build(BuildContext context) {
    final icon = switch (facilityType) {
      'hospital' => Symbols.local_hospital,
      'pharmacy' => Symbols.vaccines,
      'laboratory' => Symbols.science,
      'dental' => Symbols.dentistry,
      _ => Symbols.medical_services,
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 56,
        height: 56,
        child: logoPath != null && logoPath!.isNotEmpty
            ? SmartImage(
                source: logoPath,
                width: 56,
                height: 56,
                placeholder: _iconPlaceholder(icon),
                error: _iconPlaceholder(icon),
              )
            : _iconPlaceholder(icon),
      ),
    );
  }

  Widget _iconPlaceholder(IconData icon) {
    return ColoredBox(
      color: HomeDashboardColors.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(icon, color: HomeDashboardColors.primary, size: 28),
      ),
    );
  }
}
