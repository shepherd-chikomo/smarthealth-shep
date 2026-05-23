import 'package:equatable/equatable.dart';

/// A bookable time on a given day (e.g. "08:30").
class TimeSlot extends Equatable {
  const TimeSlot({
    required this.time,
    required this.isAvailable,
  });

  final String time;
  final bool isAvailable;

  @override
  List<Object?> get props => [time, isAvailable];
}
