import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Summary card shown on the confirm and success screens.
class AppointmentSummaryCard extends StatelessWidget {
  const AppointmentSummaryCard({
    super.key,
    required this.providerName,
    required this.facilityName,
    required this.date,
    required this.time,
    required this.durationMinutes,
    this.specialty,
    this.referenceNumber,
    this.patientName,
    this.notes,
  });

  final String providerName;
  final String facilityName;
  final String? specialty;
  final DateTime date;
  final String time;
  final int durationMinutes;
  final String? referenceNumber;
  final String? patientName;
  final String? notes;

  factory AppointmentSummaryCard.fromProvider({
    required ProviderModel provider,
    required DateTime date,
    required String time,
    required int durationMinutes,
    String? referenceNumber,
    String? patientName,
    String? notes,
  }) {
    return AppointmentSummaryCard(
      providerName: provider.name,
      facilityName: provider.facilityName ?? provider.name,
      specialty: provider.specialty,
      date: date,
      time: time,
      durationMinutes: durationMinutes,
      referenceNumber: referenceNumber,
      patientName: patientName,
      notes: notes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, d MMM yyyy').format(date);

    return Material(
      color: HomeDashboardColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E8EE)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (referenceNumber != null) ...[
              Row(
                children: [
                  const Icon(
                    Symbols.confirmation_number,
                    size: 18,
                    color: HomeDashboardColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    referenceNumber!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: HomeDashboardColors.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
            ],
            _Row(
              icon: Symbols.person,
              label: providerName,
              sublabel: specialty,
            ),
            const SizedBox(height: 12),
            _Row(icon: Symbols.location_on, label: facilityName),
            const SizedBox(height: 12),
            _Row(icon: Symbols.calendar_month, label: dateLabel),
            const SizedBox(height: 12),
            _Row(
              icon: Symbols.schedule,
              label: '$time · $durationMinutes min',
            ),
            if (patientName != null) ...[
              const SizedBox(height: 12),
              _Row(icon: Symbols.group, label: patientName!),
            ],
            if (notes != null && notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _Row(icon: Symbols.notes, label: notes!),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    this.sublabel,
  });

  final IconData icon;
  final String label;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: HomeDashboardColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: HomeDashboardColors.textPrimary,
                ),
              ),
              if (sublabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  sublabel!,
                  style: const TextStyle(
                    fontSize: 13,
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
