import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/features/appointments/models/appointment_model.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/status_chip.dart';
import 'package:smarthealth_shep/shared/widgets/smart_image.dart';

/// Operational appointment card for list views.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  final AppointmentModel appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat('EEE, d MMM · HH:mm').format(appointment.scheduledAt);
    final imageSource = appointment.providerImageUrl ??
        AppAssets.providerPortraitFor(appointment.providerId);

    return Semantics(
      button: onTap != null,
      label:
          '${appointment.providerName}, ${appointment.status.name}, $dateLabel',
      child: Material(
        color: HomeDashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
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
                SmartImage(
                  source: imageSource,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(12),
                  memCacheWidth: 128,
                  memCacheHeight: 128,
                  placeholder: _imageFallback(),
                  error: _imageFallback(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              appointment.providerName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: HomeDashboardColors.textPrimary,
                              ),
                            ),
                          ),
                          StatusChip.appointment(appointment.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.facilityName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: HomeDashboardColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dateLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: HomeDashboardColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _MetaChip(
                            icon: Symbols.medical_services,
                            label: appointment.appointmentTypeLabel,
                          ),
                          _MetaChip(
                            icon: Symbols.notifications,
                            label: appointment.reminderStateLabel,
                          ),
                          if (appointment.hasQueueInfo)
                            _MetaChip(
                              icon: Symbols.groups,
                              label: appointment.queuePosition != null
                                  ? 'Queue #${appointment.queuePosition}'
                                  : 'In queue',
                              tone: _ChipTone.queue,
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

  Widget _imageFallback() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: HomeDashboardColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.person_outline,
        color: HomeDashboardColors.primary,
        size: 28,
      ),
    );
  }
}

enum _ChipTone { neutral, queue }

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.tone = _ChipTone.neutral,
  });

  final IconData icon;
  final String label;
  final _ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final color = tone == _ChipTone.queue
        ? HomeDashboardColors.secondary
        : HomeDashboardColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
