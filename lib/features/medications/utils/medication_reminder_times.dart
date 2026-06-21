import 'package:flutter/material.dart';
import 'package:smarthealth_shep/features/medications/utils/medication_schedule_utils.dart';
import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';

/// Builds and formats per-dose reminder times for medication rows.
abstract final class MedicationReminderTimes {
  static int dosesForFrequency(String? frequency) =>
      MedicationScheduleUtils.dosesPerDayFromFrequency(frequency);

  static List<TimeOfDay> parseStoredTimes(Iterable<String> raw) {
    return raw
        .map(_parseTimeString)
        .whereType<TimeOfDay>()
        .toList();
  }

  static List<TimeOfDay> resolveSlots({
    required MedicationEntry entry,
    List<TimeOfDay> existing = const [],
  }) {
    final doses = entry.frequency != null && entry.frequency!.trim().isNotEmpty
        ? MedicationScheduleUtils.dosesPerDayFromFrequency(entry.frequency)
        : (entry.dosesPerDay ?? 1);

    if (existing.length == doses) return List<TimeOfDay>.from(existing);

    final explicit = existing
        .take(doses)
        .map((time) => MedicationTimeOfDay(time.hour, time.minute))
        .toList();

    final resolved = explicit.isEmpty
        ? MedicationScheduleUtils.resolveReminderTimes(entry)
        : MedicationScheduleUtils.resolveReminderTimes(
            entry.copyWith(
              reminderTimes: explicit
                  .map((t) => _formatTimeOfDay(t.hour, t.minute))
                  .toList(),
            ),
          );

    return resolved
        .map((time) => TimeOfDay(hour: time.hour, minute: time.minute))
        .toList();
  }

  static List<String> toStorage(List<TimeOfDay> times) {
    return times.map((time) => _formatTimeOfDay(time.hour, time.minute)).toList();
  }

  static String formatDisplay(List<TimeOfDay> times) {
    return toStorage(times).join(', ');
  }

  static TimeOfDay? _parseTimeString(String raw) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw.trim());
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String _formatTimeOfDay(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
