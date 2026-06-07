import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/booking/models/time_slot.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';

/// Grid of selectable appointment time slots.
class TimeSlotsGrid extends StatelessWidget {
  const TimeSlotsGrid({
    super.key,
    required this.slots,
    required this.selectedTime,
    required this.onTimeSelected,
    this.isLoading = false,
  });

  final List<TimeSlot> slots;
  final String? selectedTime;
  final ValueChanged<String> onTimeSelected;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (slots.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Select a date to view available times',
          style: TextStyle(color: HomeDashboardColors.of(context).textSecondary),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final selected = slot.time == selectedTime;
        final enabled = slot.isAvailable;

        return Semantics(
          button: enabled,
          selected: selected,
          label: '${slot.time}${enabled ? '' : ', unavailable'}',
          child: SizedBox(
            width: 88,
            height: AppConstants.minTapTarget,
            child: FilterChip(
              label: Text(slot.time),
              selected: selected,
              onSelected: enabled ? (_) => onTimeSelected(slot.time) : null,
              showCheckmark: false,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: !enabled
                    ? HomeDashboardColors.of(context).textSecondary.withValues(alpha: 0.5)
                    : selected
                        ? Colors.white
                        : HomeDashboardColors.of(context).textPrimary,
              ),
              selectedColor: HomeDashboardColors.of(context).primary,
              backgroundColor: enabled
                  ? HomeDashboardColors.of(context).surface
                  : HomeDashboardColors.of(context).skeleton.withValues(alpha: 0.5),
              side: BorderSide(
                color: selected
                    ? HomeDashboardColors.of(context).primary
                    : const Color(0xFFE5E8EE),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
