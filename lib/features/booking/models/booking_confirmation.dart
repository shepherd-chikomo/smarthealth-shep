import 'package:equatable/equatable.dart';

/// Confirmed appointment returned after a successful booking.
class BookingConfirmation extends Equatable {
  const BookingConfirmation({
    required this.referenceNumber,
    required this.providerId,
    required this.providerName,
    required this.facilityName,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.patientName,
    this.notes,
  });

  final String referenceNumber;
  final String providerId;
  final String providerName;
  final String facilityName;
  final DateTime date;
  final String time;
  final int durationMinutes;
  final String patientName;
  final String? notes;

  @override
  List<Object?> get props => [
        referenceNumber,
        providerId,
        providerName,
        facilityName,
        date,
        time,
        durationMinutes,
        patientName,
        notes,
      ];
}
