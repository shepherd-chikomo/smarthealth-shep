import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';

class MedicationTimeOfDay {
  const MedicationTimeOfDay(this.hour, this.minute);

  final int hour;
  final int minute;
}

/// Derives reminder times from medication frequency and local preferences.
abstract final class MedicationScheduleUtils {
  static const defaultTimes = [
    MedicationTimeOfDay(8, 0),
    MedicationTimeOfDay(14, 0),
    MedicationTimeOfDay(20, 0),
    MedicationTimeOfDay(12, 0),
  ];

  static List<MedicationTimeOfDay> resolveReminderTimes(MedicationEntry entry) {
    final explicit = entry.reminderTimes
        .map(_parseTimeString)
        .whereType<MedicationTimeOfDay>()
        .toList();
    if (explicit.isNotEmpty) return explicit;

    final doses = entry.dosesPerDay ?? _dosesFromFrequency(entry.frequency);
    return _timesForDoses(doses);
  }

  static int dosesPerDayFromFrequency(String? frequency) =>
      _dosesFromFrequency(frequency);

  static MedicationTimeOfDay? _parseTimeString(String raw) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw.trim());
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return MedicationTimeOfDay(hour, minute);
  }

  static int _dosesFromFrequency(String? frequency) {
    final value = frequency?.trim().toLowerCase() ?? '';
    if (value.isEmpty) return 1;
    if (value.contains('qid') || value.contains('four')) return 4;
    if (value.contains('tds') || value.contains('three')) return 3;
    if (value.contains('bd') ||
        value.contains('twice') ||
        value.contains('2x')) {
      return 2;
    }
    if (value.contains('od') ||
        value.contains('once') ||
        value.contains('daily') ||
        value.contains('1x')) {
      return 1;
    }
    final everyHours = RegExp(r'every\s+(\d+)\s*h').firstMatch(value);
    if (everyHours != null) {
      final hours = int.tryParse(everyHours.group(1)!) ?? 24;
      if (hours <= 0) return 1;
      return (24 / hours).ceil().clamp(1, 6);
    }
    return 1;
  }

  static List<MedicationTimeOfDay> _timesForDoses(int doses) {
    switch (doses.clamp(1, 4)) {
      case 4:
        return const [
          MedicationTimeOfDay(8, 0),
          MedicationTimeOfDay(12, 0),
          MedicationTimeOfDay(16, 0),
          MedicationTimeOfDay(20, 0),
        ];
      case 3:
        return const [
          MedicationTimeOfDay(8, 0),
          MedicationTimeOfDay(14, 0),
          MedicationTimeOfDay(20, 0),
        ];
      case 2:
        return const [
          MedicationTimeOfDay(8, 0),
          MedicationTimeOfDay(20, 0),
        ];
      default:
        return const [MedicationTimeOfDay(8, 0)];
    }
  }
}
