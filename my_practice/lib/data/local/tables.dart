import 'package:drift/drift.dart';

class SyncMetadata {
  static const synced = 'synced';
  static const pending = 'pending';
  static const conflict = 'conflict';
}

class Facilities extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get city => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncMetadata.synced))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class FacilityMemberships extends Table {
  TextColumn get id => text()();
  TextColumn get facilityId => text().references(Facilities, #id)();
  TextColumn get userId => text()();
  TextColumn get role => text()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncMetadata.synced))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Practitioners extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get facilityId => text().references(Facilities, #id)();
  TextColumn get name => text()();
  TextColumn get specialty => text().nullable()();
  TextColumn get registrationNumber => text().nullable()();
  TextColumn get role => text().nullable()();
  // Stores additional roles as comma-separated string (e.g. "doctor,facility_admin").
  TextColumn get additionalRoles => text().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncMetadata.synced))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get smarthealthPatientId => text().nullable()();
  TextColumn get nationalId => text().nullable()();
  TextColumn get passport => text().nullable()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get gender => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get insuranceInfo => text().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncMetadata.synced))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PatientAllergies extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get allergen => text()();
  TextColumn get severity => text().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncMetadata.synced))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PatientConditions extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get conditionName => text()();
  TextColumn get icd11Code => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncMetadata.synced))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Appointments extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get facilityId => text().references(Facilities, #id)();
  TextColumn get providerId => text().nullable()();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get status => text()();
  TextColumn get appointmentType => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncMetadata.synced))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class QueueEntries extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get facilityId => text().references(Facilities, #id)();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get appointmentId => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  TextColumn get triageStatus => text().nullable()();
  DateTimeColumn get arrivedAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncMetadata.synced))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Consultations extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get facilityId => text().references(Facilities, #id)();
  TextColumn get providerId => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get appointmentId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('in_progress'))();
  TextColumn get chiefComplaint => text().nullable()();
  TextColumn get historyOfPresentIllness => text().nullable()();
  TextColumn get pastMedicalHistory => text().nullable()();
  TextColumn get surgicalHistory => text().nullable()();
  TextColumn get familyHistory => text().nullable()();
  TextColumn get socialHistory => text().nullable()();
  TextColumn get examinationNotes => text().nullable()();
  TextColumn get assessment => text().nullable()();
  TextColumn get plan => text().nullable()();
  TextColumn get followUpPlan => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncMetadata.pending))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Diagnoses extends Table {
  TextColumn get id => text()();
  TextColumn get consultationId => text().references(Consultations, #id)();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get providerId => text()();
  TextColumn get facilityId => text()();
  TextColumn get icd11Code => text().nullable()();
  TextColumn get icd10Code => text().nullable()();
  TextColumn get description => text()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncMetadata.pending))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Vitals extends Table {
  TextColumn get id => text()();
  TextColumn get consultationId => text().references(Consultations, #id)();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get facilityId => text()();
  RealColumn get temperatureCelsius => real().nullable()();
  IntColumn get pulseBpm => integer().nullable()();
  IntColumn get bpSystolic => integer().nullable()();
  IntColumn get bpDiastolic => integer().nullable()();
  IntColumn get oxygenSaturation => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get heightCm => real().nullable()();
  DateTimeColumn get recordedAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncMetadata.pending))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Prescriptions extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get consultationId => text().references(Consultations, #id)();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get providerId => text()();
  TextColumn get facilityId => text()();
  TextColumn get medication => text()();
  TextColumn get dosage => text().nullable()();
  TextColumn get frequency => text().nullable()();
  TextColumn get duration => text().nullable()();
  TextColumn get instructions => text().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncMetadata.pending))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payloadJson => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
}

class SyncCursors extends Table {
  TextColumn get entityType => text()();
  TextColumn get facilityId => text()();
  DateTimeColumn get lastSyncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {entityType, facilityId};
}

class FeatureFlags extends Table {
  TextColumn get key => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

class Icd11Codes extends Table {
  TextColumn get code => text()();
  TextColumn get description => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get useCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {code};
}

class Medications extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get formulation => text().nullable()();
  TextColumn get defaultDosage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class EdlizRecommendations extends Table {
  TextColumn get id => text()();
  TextColumn get icd11Code => text()();
  TextColumn get firstLine => text()();
  TextColumn get alternative => text().nullable()();
  TextColumn get dosage => text().nullable()();
  TextColumn get formulation => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get action => text()();
  TextColumn get subjectId => text().nullable()();
  TextColumn get facilityId => text().nullable()();
  TextColumn get providerId => text().nullable()();
  TextColumn get detailsJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class InsuranceClaims extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get facilityId => text().references(Facilities, #id)();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get providerId => text()();
  TextColumn get payerKey => text()();
  TextColumn get status => text()();
  RealColumn get amount => real().withDefault(const Constant(0))();
  RealColumn get amountPaid => real().withDefault(const Constant(0))();
  DateTimeColumn get submittedAt => dateTime().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncMetadata.synced))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ClinicalTasks extends Table {
  TextColumn get id => text()();
  TextColumn get facilityId => text().references(Facilities, #id)();
  TextColumn get assigneeId => text().nullable()();
  TextColumn get patientId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get taskType => text()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class InternalMessages extends Table {
  TextColumn get id => text()();
  TextColumn get facilityId => text().references(Facilities, #id)();
  TextColumn get senderId => text()();
  TextColumn get recipientId => text()();
  TextColumn get body => text()();
  DateTimeColumn get sentAt => dateTime()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class PractitionerCredentials extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text()();
  TextColumn get credentialType => text()();
  TextColumn get title => text()();
  DateTimeColumn get issuedAt => dateTime().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  TextColumn get storagePath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class FinancialSummaries extends Table {
  TextColumn get id => text()();
  TextColumn get facilityId => text().references(Facilities, #id)();
  TextColumn get providerId => text().nullable()();
  TextColumn get period => text()();
  RealColumn get revenue => real().withDefault(const Constant(0))();
  RealColumn get expenses => real().withDefault(const Constant(0))();
  RealColumn get outstanding => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
