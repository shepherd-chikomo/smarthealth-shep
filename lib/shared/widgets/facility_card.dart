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
                _Thumbnail(
                  logoPath: facility.logoPath,
                  facilityType: facility.facilityType,
                ),
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
                              facility.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: HomeDashboardColors.of(context).textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (facility.isVerified) ...[
                            SizedBox(width: 6),
                            VerificationBadge(),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: HomeDashboardColors.of(context).textSecondary,
                        ),
                      ),
                      if (location.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 12,
                            color: HomeDashboardColors.of(context).textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (facility.acceptsYourMedicalAid) ...[
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Symbols.shield,
                              size: 14,
                              color: const Color(0xFF1B8F4E),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Accepts your medical aid',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1B8F4E),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (distance != null) ...[
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Symbols.near_me,
                              size: 14,
                              color: HomeDashboardColors.of(context).primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              distance,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: HomeDashboardColors.of(context).primary,
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
                placeholder: _iconPlaceholder(context, icon),
                error: _iconPlaceholder(context, icon),
              )
            : _iconPlaceholder(context, icon),
      ),
    );
  }

  Widget _iconPlaceholder(BuildContext context, IconData icon) {
    return ColoredBox(
      color: HomeDashboardColors.of(context).primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(icon, color: HomeDashboardColors.of(context).primary, size: 28),
      ),
    );
  }
}
