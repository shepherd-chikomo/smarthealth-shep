import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/features/booking/models/booking_consent_options.dart';

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

final class ProfileShareToggled extends BookingEvent {
  const ProfileShareToggled(this.field, this.enabled);

  final BookingProfileShareField field;
  final bool enabled;

  @override
  List<Object?> get props => [field, enabled];
}

final class PaymentMethodSelected extends BookingEvent {
  const PaymentMethodSelected(this.method);

  final BookingPaymentMethod method;

  @override
  List<Object?> get props => [method];
}

final class EncounterSummaryConsentChanged extends BookingEvent {
  const EncounterSummaryConsentChanged(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

final class OngoingCareConsentChanged extends BookingEvent {
  const OngoingCareConsentChanged(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

final class BookingConfirmed extends BookingEvent {
  const BookingConfirmed({
    this.notes,
    this.consent,
    this.profileSnapshot,
  });

  final String? notes;
  final BookingConsentOptions? consent;
  final Map<String, dynamic>? profileSnapshot;

  @override
  List<Object?> get props => [notes, consent, profileSnapshot];
}
