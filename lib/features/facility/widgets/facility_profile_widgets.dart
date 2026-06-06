import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/location/location_service.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/facility_public_profile.dart';
import 'package:smarthealth_shep/shared/utils/maps_launcher.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/operating_hours_card.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/verification_badge.dart';
import 'package:smarthealth_shep/shared/widgets/smart_image.dart';

class FacilityProfileHeader extends StatelessWidget {
  const FacilityProfileHeader({super.key, required this.profile});

  final FacilityPublicProfile profile;

  String _typeLabel(String type) {
    return switch (type) {
      'hospital' => 'Hospital',
      'clinic' => 'Clinic',
      'specialist_centre' => 'Specialist Centre',
      'laboratory' => 'Laboratory',
      'pharmacy' => 'Pharmacy',
      'medical_centre' => 'Medical Centre',
      _ => type.replaceAll('_', ' '),
    };
  }

  @override
  Widget build(BuildContext context) {
    final facility = profile.facility;
    final type = facility.facilityTypes.isNotEmpty
        ? facility.facilityTypes.first
        : facility.facilityType;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SmartImage(
            source: profile.logoUrl,
            width: 72,
            height: 72,
            borderRadius: BorderRadius.circular(16),
            placeholder: Container(
              width: 72,
              height: 72,
              color: HomeDashboardColors.primary.withValues(alpha: 0.08),
              child: const Icon(Symbols.local_hospital, color: HomeDashboardColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                facility.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: HomeDashboardColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: HomeDashboardColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _typeLabel(type),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HomeDashboardColors.primary,
                  ),
                ),
              ),
              if (facility.description != null && facility.description!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  facility.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: HomeDashboardColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class FacilityPrimaryActions extends StatelessWidget {
  const FacilityPrimaryActions({
    super.key,
    required this.profile,
    required this.onBook,
    required this.onCall,
    required this.onWhatsApp,
    required this.onDirections,
  });

  final FacilityPublicProfile profile;
  final VoidCallback? onBook;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onDirections;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (profile.booking.enabled)
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: onBook,
              style: FilledButton.styleFrom(
                backgroundColor: HomeDashboardColors.primary,
                minimumSize: const Size.fromHeight(AppConstants.minTapTarget),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Symbols.calendar_month, size: 20),
              label: const Text('Book'),
            ),
          ),
        if (profile.booking.enabled) const SizedBox(width: 8),
        if (profile.facility.phone != null)
          _ActionIconButton(icon: Symbols.call, onPressed: onCall),
        if (profile.facility.whatsappPhone != null) ...[
          const SizedBox(width: 8),
          _ActionIconButton(icon: Symbols.chat, onPressed: onWhatsApp),
        ],
        if (profile.facility.mapsQuery != null) ...[
          const SizedBox(width: 8),
          _ActionIconButton(icon: Symbols.directions, onPressed: onDirections),
        ],
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(AppConstants.minTapTarget, AppConstants.minTapTarget),
        padding: EdgeInsets.zero,
        side: const BorderSide(color: HomeDashboardColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Icon(icon, color: HomeDashboardColors.primary, size: 22),
    );
  }
}

class FacilityCompactContactCard extends StatelessWidget {
  const FacilityCompactContactCard({
    super.key,
    required this.profile,
    this.onAddressTap,
    this.onPhoneTap,
    this.onWebsiteTap,
  });

  final FacilityPublicProfile profile;
  final VoidCallback? onAddressTap;
  final VoidCallback? onPhoneTap;
  final VoidCallback? onWebsiteTap;

  @override
  Widget build(BuildContext context) {
    final facility = profile.facility;
    final address = [
      facility.addressLine1,
      facility.city,
      facility.province,
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');

    if (address.isEmpty && facility.phone == null && facility.website == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: HomeDashboardColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E8EE)),
        ),
        child: Row(
          children: [
            if (address.isNotEmpty)
              Expanded(
                child: _ContactCell(
                  icon: Symbols.location_on,
                  label: address,
                  sublabel: facility.distanceKm != null
                      ? LocationService.formatDistance(facility.distanceKm!)
                      : null,
                  onTap: onAddressTap,
                ),
              ),
            if (facility.phone != null) ...[
              if (address.isNotEmpty) const VerticalDivider(width: 16),
              Expanded(
                child: _ContactCell(
                  icon: Symbols.call,
                  label: facility.phone!,
                  onTap: onPhoneTap,
                ),
              ),
            ],
            if (facility.website != null && facility.website!.isNotEmpty) ...[
              const VerticalDivider(width: 16),
              Expanded(
                child: _ContactCell(
                  icon: Symbols.language,
                  label: facility.website!,
                  onTap: onWebsiteTap,
                  linkStyle: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactCell extends StatelessWidget {
  const _ContactCell({
    required this.icon,
    required this.label,
    this.sublabel,
    this.onTap,
    this.linkStyle = false,
  });

  final IconData icon;
  final String label;
  final String? sublabel;
  final VoidCallback? onTap;
  final bool linkStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: HomeDashboardColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: linkStyle ? HomeDashboardColors.primary : HomeDashboardColors.textPrimary,
                decoration: linkStyle ? TextDecoration.underline : null,
              ),
            ),
            if (sublabel != null)
              Text(
                sublabel!,
                style: const TextStyle(fontSize: 11, color: HomeDashboardColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}

class FacilityServicesGrid extends StatelessWidget {
  const FacilityServicesGrid({
    super.key,
    required this.services,
    this.onViewAll,
  });

  final List<FacilityServiceItem> services;
  final VoidCallback? onViewAll;

  IconData _iconFor(String key) {
    return switch (key) {
      'gp' => Symbols.medical_services,
      'emergency' => Symbols.emergency,
      'maternity' => Symbols.pregnant_woman,
      'paediatrics' => Symbols.child_care,
      'laboratory' => Symbols.biotech,
      'radiology' => Symbols.radiology,
      'pharmacy' => Symbols.local_pharmacy,
      'surgery' => Symbols.surgical,
      'physiotherapy' => Symbols.physical_therapy,
      'dentistry' => Symbols.dentistry,
      _ => Symbols.health_and_safety,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();
    final visible = services.take(9).toList();

    return _SectionCard(
      title: 'Services Offered',
      actionLabel: services.length > 9 ? 'View all' : null,
      onAction: onViewAll,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: visible.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          final service = visible[index];
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HomeDashboardColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E8EE)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_iconFor(service.iconKey), color: HomeDashboardColors.primary, size: 22),
                const SizedBox(height: 6),
                Text(
                  service.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FacilityOperatingHoursSection extends StatelessWidget {
  const FacilityOperatingHoursSection({super.key, required this.profile});

  final FacilityPublicProfile profile;

  @override
  Widget build(BuildContext context) {
    if (profile.operatingHours.isEmpty) return const SizedBox.shrink();

    final hours = profile.operatingHours.map((h) => h.toWorkingHoursEntry()).toList();
    final statusLabel = switch (profile.openStatus) {
      'open_24h' => '24-Hour Facility',
      'open' => 'Open Now',
      'closes_soon' => 'Closes Soon',
      _ => 'Closed',
    };
    final statusColor = switch (profile.openStatus) {
      'open' || 'open_24h' => Colors.green.shade700,
      'closes_soon' => Colors.orange.shade800,
      _ => Colors.red.shade700,
    };

    return _SectionCard(
      title: 'Operating Hours',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(statusLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
          ),
          const SizedBox(height: 10),
          OperatingHoursCard(hours: hours, highlightToday: true),
          if (profile.emergency.is24Hour == true || profile.openStatus == 'open_24h')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Symbols.emergency, size: 18, color: Colors.green.shade700),
                  const SizedBox(width: 6),
                  Text(
                    '24-Hour Emergency Department',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class FacilityMedicalAidSection extends StatelessWidget {
  const FacilityMedicalAidSection({super.key, required this.medicalAids, this.onViewAll});

  final List<FacilityMedicalAidItem> medicalAids;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    if (medicalAids.isEmpty) return const SizedBox.shrink();
    final visible = medicalAids.take(6).toList();

    return _SectionCard(
      title: 'Medical Aid Accepted',
      actionLabel: medicalAids.length > 6 ? 'View all' : null,
      onAction: onViewAll,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: visible
            .map(
              (aid) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E8EE)),
                ),
                child: Text(aid.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            )
            .toList(),
      ),
    );
  }
}

class FacilityInfoStatusRow extends StatelessWidget {
  const FacilityInfoStatusRow({super.key, required this.info});

  final FacilityInfoRow info;

  @override
  Widget build(BuildContext context) {
    if (!info.hasAny) return const SizedBox.shrink();

    final cards = <Widget>[];
    if (info.waitTimeMinutes != null) {
      cards.add(_StatusCard(icon: Symbols.schedule, label: 'Wait', value: '${info.waitTimeMinutes} mins'));
    }
    if (info.emergencyAvailable == true) {
      cards.add(_StatusCard(icon: Symbols.shield, label: 'Emergency', value: 'Available'));
    }
    if (info.wheelchairAccessible == true) {
      cards.add(_StatusCard(icon: Symbols.accessible, label: 'Wheelchair', value: 'Yes'));
    }
    if (info.parkingAvailable == true) {
      cards.add(_StatusCard(icon: Symbols.local_parking, label: 'Parking', value: 'Yes'));
    }

    return Row(
      children: cards
          .map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: c)))
          .toList(),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HomeDashboardColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E8EE)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: HomeDashboardColors.primary),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(fontSize: 10, color: HomeDashboardColors.textSecondary)),
        ],
      ),
    );
  }
}

class FacilityAppointmentSlotsSection extends StatelessWidget {
  const FacilityAppointmentSlotsSection({
    super.key,
    required this.days,
    this.onSlotTap,
    this.onViewCalendar,
  });

  final List<FacilityAvailabilityDay> days;
  final void Function(FacilityAvailabilitySlot slot)? onSlotTap;
  final VoidCallback? onViewCalendar;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Available Appointments',
      actionLabel: 'View Full Calendar',
      onAction: onViewCalendar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: days.map((day) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: day.slots
                      .map(
                        (slot) => OutlinedButton(
                          onPressed: onSlotTap == null ? null : () => onSlotTap!(slot),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: HomeDashboardColors.primary,
                            side: const BorderSide(color: HomeDashboardColors.primary),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          child: Text(slot.time),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FacilitySpecialistsSection extends StatelessWidget {
  const FacilitySpecialistsSection({
    super.key,
    required this.specialists,
    this.onBook,
    this.onViewAll,
  });

  final List<FacilitySpecialistSummary> specialists;
  final void Function(FacilitySpecialistSummary specialist)? onBook;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    if (specialists.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Specialists',
      actionLabel: 'View all',
      onAction: onViewAll,
      child: Column(
        children: specialists.map((s) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SmartImage(
                    source: s.photoUrl,
                    width: 48,
                    height: 48,
                    placeholder: const CircleAvatar(child: Icon(Symbols.person)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (s.specialty != null)
                        Text(s.specialty!, style: const TextStyle(fontSize: 12, color: HomeDashboardColors.textSecondary)),
                      if (s.nextAvailableAt != null)
                        Text(
                          'Next: ${DateTime.tryParse(s.nextAvailableAt!)?.toLocal().toString().substring(0, 16) ?? s.nextAvailableAt}',
                          style: const TextStyle(fontSize: 11, color: HomeDashboardColors.primary),
                        ),
                    ],
                  ),
                ),
                if (onBook != null)
                  TextButton(onPressed: () => onBook!(s), child: const Text('Book')),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FacilityAccessibilitySection extends StatelessWidget {
  const FacilityAccessibilitySection({super.key, required this.accessibility});

  final FacilityAccessibilityInfo accessibility;

  @override
  Widget build(BuildContext context) {
    if (!accessibility.hasAny) return const SizedBox.shrink();

    final items = <String>[];
    if (accessibility.wheelchair == true) items.add('Wheelchair Accessible');
    if (accessibility.parking == true) items.add('Parking Available');
    if (accessibility.elevator == true) items.add('Elevator Available');
    if (accessibility.babyFacilities == true) items.add('Baby Facilities');

    return _SectionCard(
      title: 'Accessibility',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map((label) => Chip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  backgroundColor: HomeDashboardColors.primary.withValues(alpha: 0.08),
                ))
            .toList(),
      ),
    );
  }
}

class FacilityVerificationSection extends StatelessWidget {
  const FacilityVerificationSection({super.key, required this.features});

  final FacilitySmarthealthFeatures features;

  @override
  Widget build(BuildContext context) {
    if (!features.verified && !features.hasFeatureChips) return const SizedBox.shrink();

    final chips = <String>[];
    if (features.verified) chips.add('SmartHealth Verified');
    if (features.onlineBooking == true) chips.add('Online Booking');
    if (features.digitalPrescriptions == true) chips.add('Digital Prescriptions');
    if (features.labResults == true) chips.add('Lab Results');
    if (features.patientPortal == true) chips.add('Patient Portal');
    if (features.telehealth == true) chips.add('Telehealth');

    return _SectionCard(
      title: 'SmartHealth',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (features.verified) const VerificationBadge(),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (c) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Symbols.check_circle, size: 16, color: HomeDashboardColors.primary),
                      const SizedBox(width: 4),
                      Text(c, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
