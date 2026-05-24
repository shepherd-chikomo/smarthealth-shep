import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/appointments/bloc/appointments_event.dart';
import 'package:smarthealth_shep/features/appointments/bloc/appointments_state.dart';
import 'package:smarthealth_shep/features/appointments/data/appointments_repository.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  AppointmentsBloc({AppointmentsRepository? repository})
      : _repository = repository ?? AppointmentsRepository(),
        super(const AppointmentsState()) {
    on<AppointmentsLoadRequested>(_onLoad);
    on<AppointmentsRefreshRequested>(_onRefresh);

    add(const AppointmentsLoadRequested());
  }

  final AppointmentsRepository _repository;

  Future<void> _onLoad(
    AppointmentsLoadRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(state.copyWith(status: AppointmentsStatus.loading, clearError: true));
    try {
      final appointments = await _repository.loadAppointments();
      emit(
        state.copyWith(
          status: AppointmentsStatus.ready,
          appointments: appointments,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AppointmentsStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onRefresh(
    AppointmentsRefreshRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    try {
      final appointments = await _repository.loadAppointments();
      emit(
        state.copyWith(
          status: AppointmentsStatus.ready,
          appointments: appointments,
        ),
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }
}
