import 'package:my_practice/domain/models/facility_hour.dart';

/// Per-provider weekly schedule (same shape as facility hours API).
abstract final class DevProviderSchedule {
  static const defaultProviderId = 'seed-provider-001';

  static List<FacilityHour> defaults() => const [
        FacilityHour(dayOfWeek: 0, isClosed: true),
        FacilityHour(dayOfWeek: 1, opensAt: '08:00', closesAt: '17:00'),
        FacilityHour(dayOfWeek: 2, opensAt: '08:00', closesAt: '17:00'),
        FacilityHour(dayOfWeek: 3, opensAt: '08:00', closesAt: '17:00'),
        FacilityHour(dayOfWeek: 4, opensAt: '08:00', closesAt: '17:00'),
        FacilityHour(dayOfWeek: 5, opensAt: '08:00', closesAt: '17:00'),
        FacilityHour(dayOfWeek: 6, opensAt: '09:00', closesAt: '13:00'),
      ];
}
