import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/features/appointments/models/appointment_model.dart';
import 'package:smarthealth_shep/shared/models/operational_status.dart';

enum AppointmentsStatus { initial, loading, ready, error }

class AppointmentsState extends Equatable {
  const AppointmentsState({
    this.status = AppointmentsStatus.initial,
    this.appointments = const [],
    this.errorMessage,
  });

  final AppointmentsStatus status;
  final List<AppointmentModel> appointments;
  final String? errorMessage;

  List<AppointmentModel> get upcoming => appointments
      .where(
        (a) =>
            a.isUpcoming ||
            a.isActive ||
            a.status == AppointmentOperationalStatus.rescheduled,
      )
      .toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  List<AppointmentModel> get past => appointments
      .where((a) => a.isTerminal)
      .toList()
    ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

  AppointmentsState copyWith({
    AppointmentsStatus? status,
    List<AppointmentModel>? appointments,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppointmentsState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, appointments, errorMessage];
}
