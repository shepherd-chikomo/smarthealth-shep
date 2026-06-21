import 'dart:math';

import 'package:drift/drift.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/seed/dev_team_seed.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates realistic dev-mode seed data (1000+ patients).
class SeedDataLoader {
  SeedDataLoader(this._db);

  final AppDatabase _db;
  final _rng = Random(42);

  static const _firstNames = [
    'Tendai', 'Rudo', 'Tatenda', 'Kudzai', 'Nyasha', 'Tinashe', 'Chipo', 'Farai',
    'Brian', 'Grace', 'John', 'Mary', 'Peter', 'Sarah', 'David', 'Elizabeth',
  ];

  static const _lastNames = [
    'Moyo', 'Ncube', 'Sibanda', 'Dube', 'Mpofu', 'Ndlovu', 'Chikwanha', 'Mutasa',
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
  ];

  static const _conditions = [
    ('5A11', 'Type 2 diabetes mellitus'),
    ('BA00', 'Essential hypertension'),
    ('CA40', 'Acute upper respiratory infection'),
    ('1F40', 'Malaria'),
    ('MD11', 'Low back pain'),
  ];

  static const _allergens = ['Penicillin', 'Sulfa drugs', 'Peanuts', 'Latex', 'Aspirin'];

  static const _payers = ['cimas', 'psmas', 'first_mutual', 'cellmed', 'alliance_health'];

  static const _claimStatuses = [
    'draft', 'submitted', 'under_review', 'approved', 'partially_paid', 'paid', 'rejected',
  ];

  Future<void> loadIfNeeded() async {
    if (!MyPracticeConfig.devMode) return;

    final existing = await _db.select(_db.patients).get();
    if (existing.length < 100) {
      await _db.wipeAll();
      await _seedAll();
    }
    if (MyPracticeConfig.useLocalDevSeed) {
      await ensureTeamData();
    }
    await _ensurePhase2Data();
  }

  /// Public — safe to await on splash (fast, idempotent).
  Future<void> ensureTeamData([String? facilityId]) async {
    await DevTeamSeed.ensure(_db, facilityId ?? DevTeamSeed.seedFacilityId);
  }

  Future<void> _seedAll() async {
    const facilityId = 'seed-facility-001';
    const providerId = 'seed-provider-001';

    await _db.into(_db.facilities).insert(
          FacilitiesCompanion.insert(
            id: facilityId,
            name: 'Avenues Clinic (Seed)',
            city: const Value('Harare'),
            address: const Value('1 Borrowdale Road'),
            updatedAt: DateTime.now().toUtc(),
          ),
        );

    await ensureTeamData(facilityId);

    for (final flag in FeatureFlagKeys.all) {
      await _db.into(_db.featureFlags).insertOnConflictUpdate(
            FeatureFlagsCompanion.insert(
              key: flag,
              enabled: Value(_defaultFlag(flag)),
              updatedAt: DateTime.now().toUtc(),
            ),
          );
    }

    for (final (code, desc) in _conditions) {
      await _db.into(_db.icd11Codes).insertOnConflictUpdate(
            Icd11CodesCompanion.insert(code: code, description: desc),
          );
      await _db.into(_db.edlizRecommendations).insert(
            EdlizRecommendationsCompanion.insert(
              id: _uuid.v4(),
              icd11Code: code,
              firstLine: 'Standard first-line for $desc',
              alternative: Value('Alternative therapy'),
              dosage: const Value('As per protocol'),
              formulation: const Value('Tablet'),
            ),
          );
    }

    const meds = [
      ('Paracetamol', 'Tablet', '500mg'),
      ('Metformin', 'Tablet', '500mg'),
      ('Amlodipine', 'Tablet', '5mg'),
      ('Amoxicillin', 'Capsule', '500mg'),
      ('Artemether-Lumefantrine', 'Tablet', '20/120mg'),
    ];
    for (final (name, form, dose) in meds) {
      await _db.into(_db.medications).insert(
            MedicationsCompanion.insert(
              id: _uuid.v4(),
              name: name,
              formulation: Value(form),
              defaultDosage: Value(dose),
            ),
          );
    }

    for (var i = 0; i < 1000; i++) {
      final patientId = 'seed-patient-${i.toString().padLeft(4, '0')}';
      final first = _firstNames[i % _firstNames.length];
      final last = _lastNames[(i ~/ 3) % _lastNames.length];

      await _db.into(_db.patients).insert(
            PatientsCompanion.insert(
              id: patientId,
              smarthealthPatientId: Value('SH-${(100000 + i).toString()}'),
              nationalId: Value('63-${(1000000 + i).toString()}A${i % 50}'),
              firstName: first,
              lastName: last,
              phone: Value('+2637${(70000000 + i).toString().substring(0, 8)}'),
              gender: Value(i.isEven ? 'female' : 'male'),
              dateOfBirth: Value(
                DateTime(1960 + (i % 50), (i % 12) + 1, (i % 28) + 1),
              ),
              insuranceInfo: Value(_payers[i % _payers.length]),
              updatedAt: DateTime.now().toUtc(),
            ),
          );

      if (i % 5 == 0) {
        await _db.into(_db.patientAllergies).insert(
              PatientAllergiesCompanion.insert(
                id: _uuid.v4(),
                patientId: patientId,
                allergen: _allergens[i % _allergens.length],
                severity: const Value('moderate'),
                updatedAt: DateTime.now().toUtc(),
              ),
            );
      }

      if (i % 3 == 0) {
        final (code, name) = _conditions[i % _conditions.length];
        await _db.into(_db.patientConditions).insert(
              PatientConditionsCompanion.insert(
                id: _uuid.v4(),
                patientId: patientId,
                conditionName: name,
                icd11Code: Value(code),
                updatedAt: DateTime.now().toUtc(),
              ),
            );
      }

      // Yield periodically so background seed does not freeze the UI.
      if (i % 100 == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    final now = DateTime.now();
    for (var d = 0; d < 14; d++) {
      for (var h = 8; h < 17; h += 2) {
        final idx = d * 5 + (h - 8) ~/ 2;
        if (idx >= 1000) break;
        final patientId = 'seed-patient-${(idx % 1000).toString().padLeft(4, '0')}';
        final scheduled = DateTime(now.year, now.month, now.day + d, h);
        await _db.into(_db.appointments).insert(
              AppointmentsCompanion.insert(
                id: _uuid.v4(),
                facilityId: facilityId,
                patientId: patientId,
                providerId: Value(providerId),
                status: _rng.nextBool() ? 'confirmed' : 'pending',
                scheduledAt: scheduled,
                updatedAt: now.toUtc(),
                referenceNumber: Value(
                  'SH-${scheduled.toIso8601String().substring(0, 10).replaceAll('-', '')}-${idx.toString().padLeft(4, '0')}',
                ),
                appointmentType: Value(
                  idx.isEven ? 'General consultation' : 'Follow-up',
                ),
              ),
            );
      }
    }

    for (var q = 0; q < 12; q++) {
      final patientId = 'seed-patient-${q.toString().padLeft(4, '0')}';
      await _db.into(_db.queueEntries).insert(
            QueueEntriesCompanion.insert(
              id: _uuid.v4(),
              facilityId: facilityId,
              patientId: patientId,
              position: Value(q + 1),
              status: q == 0 ? 'in_progress' : 'waiting',
              arrivedAt: now.subtract(Duration(minutes: 30 - q * 2)),
              updatedAt: now.toUtc(),
              triageStatus: Value(q % 3 == 0 ? 'urgent' : 'routine'),
            ),
          );
    }

    for (var e = 0; e < 500; e++) {
      final patientId = 'seed-patient-${(e % 1000).toString().padLeft(4, '0')}';
      final consultId = _uuid.v4();
      await _db.into(_db.consultations).insert(
            ConsultationsCompanion.insert(
              id: consultId,
              facilityId: facilityId,
              providerId: providerId,
              patientId: patientId,
              chiefComplaint: Value('Presenting complaint #$e'),
              historyOfPresentIllness: Value('HPI narrative for encounter $e'),
              assessment: Value('Assessment notes'),
              plan: Value('Treatment plan'),
              startedAt: Value(now.subtract(Duration(days: e ~/ 10))),
              completedAt: e % 4 == 0 ? const Value(null) : Value(now),
              updatedAt: now.toUtc(),
              syncStatus: const Value('synced'),
            ),
          );
      if (e % 4 != 0) {
        await (_db.update(_db.consultations)..where((t) => t.id.equals(consultId)))
            .write(
          ConsultationsCompanion(
            status: const Value('completed'),
            completedAt: Value(now),
          ),
        );
      }

      if (e % 2 == 0) {
        final (code, desc) = _conditions[e % _conditions.length];
        await _db.into(_db.diagnoses).insert(
              DiagnosesCompanion.insert(
                id: _uuid.v4(),
                consultationId: consultId,
                patientId: patientId,
                providerId: providerId,
                facilityId: facilityId,
                icd11Code: Value(code),
                description: desc,
                isPrimary: const Value(true),
                updatedAt: now.toUtc(),
                syncStatus: const Value('synced'),
              ),
            );
      }
    }

    for (var c = 0; c < 200; c++) {
      final patientId = 'seed-patient-${(c % 1000).toString().padLeft(4, '0')}';
      await _db.into(_db.insuranceClaims).insert(
            InsuranceClaimsCompanion.insert(
              id: _uuid.v4(),
              facilityId: facilityId,
              patientId: patientId,
              providerId: providerId,
              payerKey: _payers[c % _payers.length],
              status: _claimStatuses[c % _claimStatuses.length],
              amount: Value(50 + _rng.nextInt(450).toDouble()),
              amountPaid: Value(c % 3 == 0 ? 0 : 25 + _rng.nextInt(200).toDouble()),
              submittedAt: Value(now.subtract(Duration(days: c % 90))),
              updatedAt: now.toUtc(),
            ),
          );
    }

    for (var f = 0; f < 12; f++) {
      await _db.into(_db.financialSummaries).insert(
            FinancialSummariesCompanion.insert(
              id: _uuid.v4(),
              facilityId: facilityId,
              providerId: Value(providerId),
              period: '2026-${(f + 1).toString().padLeft(2, '0')}',
              revenue: Value(10000 + _rng.nextInt(50000).toDouble()),
              expenses: Value(2000 + _rng.nextInt(8000).toDouble()),
              outstanding: Value(500 + _rng.nextInt(5000).toDouble()),
              updatedAt: now.toUtc(),
            ),
          );
    }

    await _ensurePhase2Data();
  }

  Future<void> _ensurePhase2Data() async {
    const facilityId = 'seed-facility-001';
    const providerId = 'seed-provider-001';
    final now = DateTime.now().toUtc();

    final taskCount = await _db.select(_db.clinicalTasks).get();
    if (taskCount.isEmpty) {
      const tasks = [
        ('Review Hb results — Tatenda Gumbo', 'result_review', 'seed-patient-0000'),
        ('Call back Nyasha Dube re: fever', 'callback', 'seed-patient-0001'),
        ('Follow-up hypertension — Rumbidzai', 'follow_up', 'seed-patient-0002'),
        ('Renew APC practising certificate', 'admin', null),
        ('Sign off lab report batch', 'admin', null),
      ];
      for (final (title, type, patientId) in tasks) {
        await _db.into(_db.clinicalTasks).insert(
              ClinicalTasksCompanion.insert(
                id: _uuid.v4(),
                facilityId: facilityId,
                assigneeId: const Value(providerId),
                patientId: Value(patientId),
                title: title,
                taskType: type,
                status: const Value('open'),
                dueAt: Value(now.add(Duration(days: _rng.nextInt(7) + 1))),
                createdAt: now.subtract(Duration(hours: _rng.nextInt(48))),
              ),
            );
      }
    }

    final msgCount = await _db.select(_db.internalMessages).get();
    if (msgCount.isEmpty) {
      const threads = [
        ('seed-nurse-001', 'Patient in Room 2 ready for vitals.'),
        ('seed-reception-001', 'PSMAS pre-auth received for SH-100214.'),
        ('seed-admin-001', 'Monthly claims batch exported for review.'),
        ('seed-nurse-001', 'Dr, urgent walk-in — chest pain, triage complete.'),
      ];
      for (final (from, body) in threads) {
        await _db.into(_db.internalMessages).insert(
              InternalMessagesCompanion.insert(
                id: _uuid.v4(),
                facilityId: facilityId,
                senderId: from,
                recipientId: providerId,
                body: body,
                sentAt: now.subtract(Duration(minutes: _rng.nextInt(360))),
                read: Value(_rng.nextBool()),
              ),
            );
      }
    }

    final credCount = await _db.select(_db.practitionerCredentials).get();
    if (credCount.isEmpty) {
      const creds = [
        ('APC Certificate', 'apc', 365),
        ('Practising Licence', 'licence', 180),
        ('MDPCZ Registration', 'registration', 730),
        ('CPD Certificate 2025', 'cpd', 90),
      ];
      for (final (title, type, daysUntilExpiry) in creds) {
        await _db.into(_db.practitionerCredentials).insert(
              PractitionerCredentialsCompanion.insert(
                id: _uuid.v4(),
                providerId: providerId,
                credentialType: type,
                title: title,
                issuedAt: Value(now.subtract(const Duration(days: 365))),
                expiresAt: Value(now.add(Duration(days: daysUntilExpiry))),
              ),
            );
      }
    }
  }

  bool _defaultFlag(String key) {
    return switch (key) {
      FeatureFlagKeys.voiceDictation => true,
      FeatureFlagKeys.edliz => true,
      FeatureFlagKeys.icd11 => true,
      FeatureFlagKeys.claimsModule => true,
      _ => false,
    };
  }
}
