import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/working_hours_entry.dart';

/// Weekly operating hours in a rounded card with muted row separators.
class OperatingHoursCard extends StatelessWidget {
  const OperatingHoursCard({
    super.key,
    required this.hours,
    this.title,
    this.closedLabel = 'Closed',
    this.highlightToday = true,
    this.padding = const EdgeInsets.all(16),
  });

  final List<WorkingHoursEntry> hours;
  final String? title;
  final String closedLabel;
  final bool highlightToday;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) return const SizedBox.shrink();

    final todayName = DateFormat('EEEE').format(DateTime.now());

    return Material(
      color: HomeDashboardColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E8EE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HomeDashboardColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
            ],
            ...hours.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              final isToday = highlightToday &&
                  row.day.toLowerCase() == todayName.toLowerCase();

              return Column(
                children: [
                  if (index > 0)
                    Divider(
                      height: 1,
                      color: HomeDashboardColors.textSecondary
                          .withValues(alpha: 0.15),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            row.day,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isToday ? FontWeight.w700 : FontWeight.w600,
                              color: isToday
                                  ? HomeDashboardColors.primary
                                  : HomeDashboardColors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            row.isClosed ? closedLabel : (row.hours ?? '—'),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 14,
                              color: row.isClosed
                                  ? HomeDashboardColors.emergency
                                  : HomeDashboardColors.textSecondary,
                              fontWeight: row.isClosed || isToday
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
