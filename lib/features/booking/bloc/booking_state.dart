import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/features/booking/models/booking_confirmation.dart';
import 'package:smarthealth_shep/features/booking/models/patient_option.dart';
import 'package:smarthealth_shep/features/booking/models/time_slot.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

enum BookingStatus {
  initial,
  loading,
  ready,
  loadingSlots,
  confirming,
  confirmed,
  offlineBlocked,
  error,
}

class BookingState extends Equatable {
  const BookingState({
    this.status = BookingStatus.initial,
    this.providerId,
    this.provider,
    this.focusedDay,
    this.selectedDate,
    this.selectedTime,
    this.slots = const [],
    this.availableDates = const [],
    this.patients = const [],
    this.selectedPatientId = PatientOption.selfId,
    this.notes = '',
    this.isOffline = false,
    this.draftSaved = false,
    this.confirmation,
    this.pendingSync = false,
    this.errorMessage,
  });

  final BookingStatus status;
  final String? providerId;
  final ProviderModel? provider;
  final DateTime? focusedDay;
  final DateTime? selectedDate;
  final String? selectedTime;
  final List<TimeSlot> slots;
  final List<DateTime> availableDates;
  final List<PatientOption> patients;
  final String? selectedPatientId;
  final String notes;
  final bool isOffline;
  final bool draftSaved;
  final BookingConfirmation? confirmation;
  final bool pendingSync;
  final String? errorMessage;

  bool get canContinue =>
      selectedDate != null &&
      selectedTime != null &&
      slots.any((s) => s.time == selectedTime && s.isAvailable);

  PatientOption? get selectedPatient {
    for (final patient in patients) {
      if (patient.id == selectedPatientId) return patient;
    }
    return null;
  }

  BookingState copyWith({
    BookingStatus? status,
    String? providerId,
    ProviderModel? provider,
    DateTime? focusedDay,
    DateTime? selectedDate,
    String? selectedTime,
    List<TimeSlot>? slots,
    List<DateTime>? availableDates,
    List<PatientOption>? patients,
    String? selectedPatientId,
    String? notes,
    bool? isOffline,
    bool? draftSaved,
    BookingConfirmation? confirmation,
    bool? pendingSync,
    String? errorMessage,
    bool clearSelectedTime = false,
    bool clearError = false,
    bool clearConfirmation = false,
  }) {
    return BookingState(
      status: status ?? this.status,
      providerId: providerId ?? this.providerId,
      provider: provider ?? this.provider,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime:
          clearSelectedTime ? null : (selectedTime ?? this.selectedTime),
      slots: slots ?? this.slots,
      availableDates: availableDates ?? this.availableDates,
      patients: patients ?? this.patients,
      selectedPatientId: selectedPatientId ?? this.selectedPatientId,
      notes: notes ?? this.notes,
      isOffline: isOffline ?? this.isOffline,
      draftSaved: draftSaved ?? this.draftSaved,
      confirmation:
          clearConfirmation ? null : (confirmation ?? this.confirmation),
      pendingSync: pendingSync ?? this.pendingSync,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        providerId,
        provider,
        focusedDay,
        selectedDate,
        selectedTime,
        slots,
        availableDates,
        patients,
        selectedPatientId,
        notes,
        isOffline,
        draftSaved,
        confirmation,
        pendingSync,
        errorMessage,
      ];
}
