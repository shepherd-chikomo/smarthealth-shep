/// SmartHealth data domain boundaries — cloud vs device-only health vault.
abstract final class DataDomains {
  /// Server-stored account and system data (no clinical PHI).
  static const cloudAccountFields = {
    'id',
    'smarthealthPatientId',
    'firstName',
    'lastName',
    'phone',
    'email',
    'dateOfBirth',
    'gender',
    'avatarPath',
    'preferredLanguage',
    'timezone',
  };

  /// Booking payloads sent to server (minimal identifiers only).
  static const cloudBookingFields = {
    'patientId',
    'smarthealthPatientId',
    'facilityId',
    'providerId',
    'scheduledAt',
    'familyMemberId',
    'shareEmergencyProfile',
    'shareMedicalSummary',
  };

  /// Never transmitted to SmartHealth servers by default.
  static const healthVaultOnlyFields = {
    'bloodGroup',
    'allergies',
    'chronicConditions',
    'medications',
    'vaccinations',
    'medicalHistory',
    'familyHistory',
    'emergencyContacts',
    'healthDocuments',
    'labResults',
    'imagingReports',
    'healthNotes',
    'healthSummary',
    'diagnoses',
    'clinicalNotes',
  };
}
