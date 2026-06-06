import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_event.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_state.dart';
import 'package:smarthealth_shep/features/booking/data/booking_repository.dart';
import 'package:smarthealth_shep/features/booking/models/patient_option.dart';

const _logName = 'BookingBloc';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc({
    required String providerId,
    BookingRepository? repository,
    String? facilityId,
    String? serviceId,
  })  : _repository = repository ?? BookingRepository(),
        super(BookingState(
          providerId: providerId,
          facilityId: facilityId,
          serviceId: serviceId,
        )) {
    on<LoadAvailability>(_onLoadAvailability);
    on<DateSelected>(_onDateSelected);
    on<TimeSelected>(_onTimeSelected);
    on<PatientSelected>(_onPatientSelected);
    on<BookingConfirmed>(_onBookingConfirmed);

    add(LoadAvailability(providerId));
  }

  final BookingRepository _repository;

  Future<void> _onLoadAvailability(
    LoadAvailability event,
    Emitter<BookingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: BookingStatus.loading,
        providerId: event.providerId,
        clearError: true,
      ),
    );

    try {
      final isOffline = !(await _repository.isOnline());
      final provider = await _repository.getProvider(event.providerId);
      if (provider == null) {
        emit(
          state.copyWith(
            status: BookingStatus.error,
            errorMessage: 'Provider not found',
          ),
        );
        return;
      }

      final patients = await _repository.getPatients();
      final availableDates = _repository.availableDates();
      final today = DateTime.now();
      final focusedDay = DateTime(today.year, today.month, today.day);

      emit(
        state.copyWith(
          status: BookingStatus.ready,
          provider: provider,
          focusedDay: focusedDay,
          availableDates: availableDates,
          patients: patients,
          selectedPatientId: PatientOption.selfId,
          isOffline: isOffline,
        ),
      );
    } catch (error, stackTrace) {
      developer.log(
        'LoadAvailability failed',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: BookingStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDateSelected(
    DateSelected event,
    Emitter<BookingState> emit,
  ) async {
    final provider = state.provider;
    if (provider == null) return;

    final normalized =
        DateTime(event.date.year, event.date.month, event.date.day);
    if (!_repository.isDateAvailable(normalized, state.availableDates)) {
      return;
    }

    emit(
      state.copyWith(
        status: BookingStatus.loadingSlots,
        selectedDate: normalized,
        focusedDay: normalized,
        clearSelectedTime: true,
        slots: const [],
        clearError: true,
      ),
    );

    try {
      final slots = await _repository.getTimeSlots(
        provider.id,
        normalized,
        facilityId: state.facilityId,
        serviceId: state.serviceId,
      );
      emit(
        state.copyWith(
          status: BookingStatus.ready,
          slots: slots,
        ),
      );
    } catch (error, stackTrace) {
      developer.log(
        'DateSelected slot load failed',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: BookingStatus.error,
          errorMessage: 'Could not load time slots',
        ),
      );
    }
  }

  void _onTimeSelected(TimeSelected event, Emitter<BookingState> emit) {
    final slot = state.slots.where((s) => s.time == event.time).firstOrNull;
    if (slot == null || !slot.isAvailable) return;

    emit(
      state.copyWith(
        selectedTime: event.time,
        clearError: true,
      ),
    );
  }

  void _onPatientSelected(
    PatientSelected event,
    Emitter<BookingState> emit,
  ) {
    emit(
      state.copyWith(
        selectedPatientId: event.patientId,
        clearError: true,
      ),
    );
  }

  Future<void> _onBookingConfirmed(
    BookingConfirmed event,
    Emitter<BookingState> emit,
  ) async {
    final provider = state.provider;
    final date = state.selectedDate;
    final time = state.selectedTime;
    final patient = state.selectedPatient;

    if (provider == null || date == null || time == null || patient == null) {
      emit(
        state.copyWith(
          status: BookingStatus.error,
          errorMessage: 'Please complete all booking details',
        ),
      );
      return;
    }

    final notes = event.notes?.trim();
    emit(
      state.copyWith(
        status: BookingStatus.confirming,
        notes: notes ?? '',
        clearError: true,
        draftSaved: false,
      ),
    );

    try {
      final result = await _repository.confirmBooking(
        provider: provider,
        date: date,
        time: time,
        patient: patient,
        notes: notes,
        facilityId: state.facilityId,
        serviceId: state.serviceId,
      );

      emit(
        state.copyWith(
          status: BookingStatus.confirmed,
          confirmation: result.confirmation,
          isOffline: result.isPendingSync,
          pendingSync: result.isPendingSync,
        ),
      );
    } catch (error, stackTrace) {
      developer.log(
        'BookingConfirmed failed',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: BookingStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
