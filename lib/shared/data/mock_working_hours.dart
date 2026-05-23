import 'package:smarthealth_shep/shared/models/working_hours_entry.dart';

/// Default Mon–Sat clinic hours used for mock provider profiles.
abstract final class MockWorkingHours {
  static const standardWeek = [
    WorkingHoursEntry(day: 'Monday', hours: '8:00 AM – 5:00 PM'),
    WorkingHoursEntry(day: 'Tuesday', hours: '8:00 AM – 5:00 PM'),
    WorkingHoursEntry(day: 'Wednesday', hours: '8:00 AM – 5:00 PM'),
    WorkingHoursEntry(day: 'Thursday', hours: '8:00 AM – 5:00 PM'),
    WorkingHoursEntry(day: 'Friday', hours: '8:00 AM – 5:00 PM'),
    WorkingHoursEntry(day: 'Saturday', hours: '9:00 AM – 1:00 PM'),
    WorkingHoursEntry(day: 'Sunday', isClosed: true),
  ];
}
