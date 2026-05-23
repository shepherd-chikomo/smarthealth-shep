import 'package:freezed_annotation/freezed_annotation.dart';

part 'working_hours_entry.freezed.dart';
part 'working_hours_entry.g.dart';

@freezed
abstract class WorkingHoursEntry with _$WorkingHoursEntry {
  const factory WorkingHoursEntry({
    required String day,
    String? hours,
    @Default(false) bool isClosed,
  }) = _WorkingHoursEntry;

  factory WorkingHoursEntry.fromJson(Map<String, dynamic> json) =>
      _$WorkingHoursEntryFromJson(json);
}
