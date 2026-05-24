import 'package:equatable/equatable.dart';

sealed class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();

  @override
  List<Object?> get props => [];
}

final class AppointmentsLoadRequested extends AppointmentsEvent {
  const AppointmentsLoadRequested();
}

final class AppointmentsRefreshRequested extends AppointmentsEvent {
  const AppointmentsRefreshRequested();
}
