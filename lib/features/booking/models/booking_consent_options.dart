import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

/// Fields the patient may opt to share with the provider at booking time.
enum BookingProfileShareField {
  allergies,
  conditions,
  medications,
  bloodGroup,
  emergencyContact,
}

enum BookingPaymentMethod {
  selfPay('cash', 'Self-pay / cash'),
  medicalAid('insurance', 'Medical aid'),
  mobileMoney('mobile_money', 'Mobile money'),
  card('card', 'Card');

  const BookingPaymentMethod(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class BookingConsentOptions {
  const BookingConsentOptions({
    this.sharedFields = const {
      BookingProfileShareField.allergies,
      BookingProfileShareField.conditions,
      BookingProfileShareField.medications,
      BookingProfileShareField.bloodGroup,
      BookingProfileShareField.emergencyContact,
    },
    this.paymentMethod = BookingPaymentMethod.selfPay,
    this.receiveEncounterSummary = true,
    this.enableOngoingCare = false,
  });

  final Set<BookingProfileShareField> sharedFields;
  final BookingPaymentMethod paymentMethod;
  final bool receiveEncounterSummary;
  final bool enableOngoingCare;

  BookingConsentOptions copyWith({
    Set<BookingProfileShareField>? sharedFields,
    BookingPaymentMethod? paymentMethod,
    bool? receiveEncounterSummary,
    bool? enableOngoingCare,
  }) {
    return BookingConsentOptions(
      sharedFields: sharedFields ?? this.sharedFields,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiveEncounterSummary:
          receiveEncounterSummary ?? this.receiveEncounterSummary,
      enableOngoingCare: enableOngoingCare ?? this.enableOngoingCare,
    );
  }

  Map<String, bool> toShareProfileFlags() {
    return {
      for (final field in BookingProfileShareField.values)
        field.name: sharedFields.contains(field),
    };
  }

  /// Builds the payload sent to the server — only checked fields included.
  Map<String, dynamic> buildProfileSnapshot(FamilyMemberModel member) {
    final metadata = member.metadata ?? const EmergencyMedicalMetadata();
    final snapshot = <String, dynamic>{};

    if (sharedFields.contains(BookingProfileShareField.allergies) &&
        member.allergies != null &&
        member.allergies!.trim().isNotEmpty) {
      snapshot['allergies'] = member.allergies!.trim();
    }

    if (sharedFields.contains(BookingProfileShareField.conditions) &&
        member.medicalConditions.isNotEmpty) {
      snapshot['conditions'] = member.medicalConditions;
    }

    if (sharedFields.contains(BookingProfileShareField.medications) &&
        metadata.medications.isNotEmpty) {
      snapshot['medications'] =
          metadata.medications.map((m) => m.toApiJson()).where((m) => m.isNotEmpty).toList();
    }

    if (sharedFields.contains(BookingProfileShareField.bloodGroup) &&
        metadata.bloodGroup != null &&
        metadata.bloodGroup!.trim().isNotEmpty) {
      snapshot['bloodGroup'] = metadata.bloodGroup!.trim();
    }

    if (sharedFields.contains(BookingProfileShareField.emergencyContact) &&
        metadata.hasAnyEmergencyContact) {
      final contact = metadata.primaryEmergencyContact;
      snapshot['emergencyContact'] = {
        if (contact.name != null) 'name': contact.name,
        if (contact.relationship != null) 'relationship': contact.relationship,
        if (contact.phone != null) 'phone': contact.phone,
      };
    }

    if (paymentMethod == BookingPaymentMethod.medicalAid) {
      final aid = metadata.medicalAid;
      if (aid.hasAny) {
        snapshot['medicalAid'] = aid.toJson();
      }
    }

    return snapshot;
  }
}
