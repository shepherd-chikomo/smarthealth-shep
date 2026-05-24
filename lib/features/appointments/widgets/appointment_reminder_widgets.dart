import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/appointments/models/appointment_model.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';

/// Live countdown until an appointment starts.
class AppointmentCountdown extends StatefulWidget {
  const AppointmentCountdown({
    super.key,
    required this.target,
    this.compact = false,
  });

  final DateTime target;
  final bool compact;

  @override
  State<AppointmentCountdown> createState() => _AppointmentCountdownState();
}

class _AppointmentCountdownState extends State<AppointmentCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _tick());
  }

  @override
  void didUpdateWidget(covariant AppointmentCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) _tick();
  }

  void _tick() {
    setState(() {
      _remaining = widget.target.difference(DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return Text(
        'Starting now',
        style: TextStyle(
          fontSize: widget.compact ? 12 : 14,
          fontWeight: FontWeight.w600,
          color: HomeDashboardColors.secondary,
        ),
      );
    }

    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);
    final label = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Symbols.timer,
          size: widget.compact ? 14 : 16,
          color: HomeDashboardColors.primary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: widget.compact ? 12 : 14,
            fontWeight: FontWeight.w700,
            color: HomeDashboardColors.primary,
          ),
        ),
      ],
    );
  }
}

/// Reminder card for upcoming appointment notifications.
class AppointmentReminderCard extends StatelessWidget {
  const AppointmentReminderCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  final AppointmentModel appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheduledLabel =
        DateFormat('EEE, d MMM · HH:mm').format(appointment.scheduledAt);

    return Semantics(
      button: onTap != null,
      label: 'Reminder for ${appointment.providerName}',
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
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: HomeDashboardColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Symbols.notifications_active,
                    color: HomeDashboardColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.reminderStateLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: HomeDashboardColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appointment.providerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: HomeDashboardColors.textPrimary,
                        ),
                      ),
                      Text(
                        scheduledLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: HomeDashboardColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppointmentCountdown(
                  target: appointment.scheduledAt,
                  compact: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact home-screen banner for the next upcoming appointment.
class UpcomingAppointmentBanner extends StatelessWidget {
  const UpcomingAppointmentBanner({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  final AppointmentModel appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Upcoming appointment with ${appointment.providerName}',
      child: Material(
        color: HomeDashboardColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: HomeDashboardColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Symbols.event_upcoming,
                  color: HomeDashboardColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upcoming appointment',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: HomeDashboardColors.primary,
                        ),
                      ),
                      Text(
                        appointment.providerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: HomeDashboardColors.textPrimary,
                        ),
                      ),
                      Text(
                        appointment.facilityName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: HomeDashboardColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppointmentCountdown(target: appointment.scheduledAt),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
