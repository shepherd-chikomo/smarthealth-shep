import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/operational_status.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/models/working_hours_entry.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/availability_indicator.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/status_chip.dart';

/// Live availability summary for provider profiles and detail views.
class ProviderAvailabilitySection extends StatelessWidget {
  const ProviderAvailabilitySection({
    super.key,
    required this.provider,
    this.compact = false,
  });

  factory ProviderAvailabilitySection.fromProvider(
    ProviderModel provider, {
    bool compact = false,
  }) {
    return ProviderAvailabilitySection(provider: provider, compact: compact);
  }

  final ProviderModel provider;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!_hasAvailabilityInfo) return const SizedBox.shrink();

    final todayHours = _todayHours(provider.weeklyHours);
    final padding = compact ? 12.0 : 16.0;

    return Material(
      color: HomeDashboardColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E8EE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Availability',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: HomeDashboardColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            AvailabilityIndicator.fromProvider(provider),
            if (provider.nextAvailableSlot != null) ...[
              const SizedBox(height: 10),
              _InfoRow(
                icon: Symbols.event_available,
                label: 'Next available appointment',
                value: _formatNextSlot(provider.nextAvailableSlot!),
              ),
            ],
            if (todayHours != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Symbols.schedule,
                label: "Today's hours",
                value: todayHours.isClosed
                    ? 'Closed'
                    : (todayHours.hours ?? '—'),
                valueColor: todayHours.isClosed
                    ? HomeDashboardColors.emergency
                    : null,
              ),
            ],
            if (_badges.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _badges,
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _hasAvailabilityInfo =>
      provider.isOpenNow != null ||
      provider.isClosingSoon == true ||
      provider.nextAvailableSlot != null ||
      provider.availableToday == true ||
      provider.acceptsWalkIns == true ||
      provider.emergencyAvailable == true ||
      provider.hasQueue == true ||
      provider.weeklyHours.isNotEmpty;

  List<Widget> get _badges {
    final chips = <Widget>[];
    if (provider.availableToday == true) {
      chips.add(StatusChip.facility(FacilityOperationalStatus.availableToday));
    }
    if (provider.acceptsWalkIns == true) {
      chips.add(StatusChip.facility(FacilityOperationalStatus.walkInsAccepted));
    }
    if (provider.hasQueue == true) {
      chips.add(StatusChip.facility(FacilityOperationalStatus.queueAvailable));
    }
    if (provider.emergencyAvailable == true) {
      chips.add(
        StatusChip.facility(FacilityOperationalStatus.emergencyAvailable),
      );
    }
    return chips;
  }

  WorkingHoursEntry? _todayHours(List<WorkingHoursEntry> hours) {
    if (hours.isEmpty) return null;
    final today = DateFormat('EEEE').format(DateTime.now());
    for (final entry in hours) {
      if (entry.day.toLowerCase() == today.toLowerCase()) return entry;
    }
    return null;
  }

  static String _formatNextSlot(DateTime slot) {
    final local = slot.toLocal();
    return '${DateFormat('EEE, d MMM').format(local)} · ${DateFormat.jm().format(local)}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: HomeDashboardColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: HomeDashboardColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? HomeDashboardColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
