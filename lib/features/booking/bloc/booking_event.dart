import 'package:equatable/equatable.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

final class LoadAvailability extends BookingEvent {
  const LoadAvailability(this.providerId);

  final String providerId;

  @override
  List<Object?> get props => [providerId];
}

final class DateSelected extends BookingEvent {
  const DateSelected(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

final class TimeSelected extends BookingEvent {
  const TimeSelected(this.time);

  final String time;

  @override
  List<Object?> get props => [time];
}

final class PatientSelected extends BookingEvent {
  const PatientSelected(this.patientId);

  final String patientId;

  @override
  List<Object?> get props => [patientId];
}

final class BookingConfirmed extends BookingEvent {
  const BookingConfirmed({this.notes});

  final String? notes;

  @override
  List<Object?> get props => [notes];
}
