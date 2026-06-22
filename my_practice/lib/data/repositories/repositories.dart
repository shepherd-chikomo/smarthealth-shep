import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/remote/facility_api_client.dart';
import 'package:my_practice/data/seed/dev_provider_schedule.dart';
import 'package:my_practice/data/seed/dev_team_seed.dart';
import 'package:my_practice/domain/models/facility_hour.dart';
import 'package:my_practice/data/seed/seed_data_loader.dart';
import 'package:my_practice/data/sync/sync_engine.dart';
import 'package:my_practice/shared/utils/patient_formatters.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';
  return DashboardRepository(
    db: db,
    api: MyPracticeConfig.skipAuthForTesting
        ? null
        : FacilityApiClient(ref.watch(facilityDioProvider), facilityId: facilityId),
    facilityId: facilityId,
  );
});

class DashboardRepository {
  DashboardRepository({
    required this.db,
    required this.api,
    required this.facilityId,
  });

  final AppDatabase db;
  final FacilityApiClient? api;
  final String facilityId;

  Future<Map<String, dynamic>> getDashboardStats() async {
    if (api != null) {
      try {
        final data = await api!.getDashboard();
        return data['stats'] as Map<String, dynamic>? ?? data;
      } catch (_) {}
    }

    final appointments = await (db.select(db.appointments)
          ..where((t) => t.facilityId.equals(facilityId)))
        .get();
    final today = DateTime.now();
    final todayAppts = appointments.where((a) =>
        a.scheduledAt.year == today.year &&
        a.scheduledAt.month == today.month &&
        a.scheduledAt.day == today.day);

    final queue = await (db.select(db.queueEntries)
          ..where((t) => t.facilityId.equals(facilityId)))
        .get();

    final completed = await (db.select(db.consultations)
          ..where(
            (t) =>
                t.facilityId.equals(facilityId) &
                t.status.equals('completed'),
          ))
        .get();

    return {
      'appointmentsToday': todayAppts.length,
      'queueSize': queue.where((q) => q.status != 'completed').length,
      'encountersCompleted': completed.length,
      'revenueToday': 1250.0,
      'notifications': 3,
      'syncStatus': MyPracticeConfig.skipAuthForTesting ? 'simulated' : 'online',
    };
  }
}

final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';
  return QueueRepository(
    db: db,
    api: MyPracticeConfig.skipAuthForTesting
        ? null
        : FacilityApiClient(ref.watch(facilityDioProvider), facilityId: facilityId),
    sync: ref.watch(syncEngineProvider),
    facilityId: facilityId,
  );
});

class QueueRepository {
  QueueRepository({
    required this.db,
    required this.api,
    required this.sync,
    required this.facilityId,
  });

  final AppDatabase db;
  final FacilityApiClient? api;
  final SyncEngine? sync;
  final String facilityId;

  Stream<List<QueueEntry>> watchQueue() {
    return (db.select(db.queueEntries)
          ..where((t) => t.facilityId.equals(facilityId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .watch();
  }

  Stream<List<QueueEntryWithPatient>> watchEnrichedQueue() {
    return watchQueue().asyncMap(_enrichQueue);
  }

  Future<List<QueueEntryWithPatient>> _enrichQueue(List<QueueEntry> entries) async {
    if (entries.isEmpty) return [];
    final patientIds = entries.map((e) => e.patientId).toSet();
    final patients = await (db.select(db.patients)
          ..where((t) => t.id.isIn(patientIds.toList())))
        .get();
    final byId = {for (final p in patients) p.id: p};
    return entries
        .map((e) => QueueEntryWithPatient(entry: e, patient: byId[e.patientId]))
        .toList();
  }

  Future<void> updateStatus(String id, String status) async {
    await (db.update(db.queueEntries)..where((t) => t.id.equals(id))).write(
          QueueEntriesCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now().toUtc()),
            syncStatus: const Value('pending'),
          ),
        );

    if (api != null) {
      try {
        await api!.updateQueueStatus(id, status);
        await (db.update(db.queueEntries)..where((t) => t.id.equals(id))).write(
              const QueueEntriesCompanion(
                syncStatus: Value('synced'),
              ),
            );
        return;
      } catch (_) {}
    }

    await sync?.enqueue(
      entityType: 'queue',
      entityId: id,
      operation: 'updateStatus',
      payload: {'status': status},
    );
  }
}

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';
  return PatientRepository(
    db: db,
    api: MyPracticeConfig.skipAuthForTesting
        ? null
        : FacilityApiClient(ref.watch(facilityDioProvider), facilityId: facilityId),
    facilityId: facilityId,
  );
});

class PatientRepository {
  PatientRepository({
    required this.db,
    required this.api,
    required this.facilityId,
  });

  final AppDatabase db;
  final FacilityApiClient? api;
  final String facilityId;

  Future<Patient?> findById(String patientId) async {
    return (db.select(db.patients)..where((t) => t.id.equals(patientId)))
        .getSingleOrNull();
  }

  Future<List<Patient>> listRecent({int limit = 50}) async {
    return (db.select(db.patients)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(limit))
        .get();
  }

  Future<List<Patient>> search(String query) async {
    if (query.trim().isEmpty) return listRecent();

    if (api != null) {
      try {
        final remote = await api!.searchPatients(query);
        final patients = remote.map(_patientFromApi).toList();
        for (final p in patients) {
          await _cachePatient(p);
        }
        return patients;
      } catch (_) {}
    }

    final q = query.toLowerCase();
    final all = await db.select(db.patients).get();
    return all
        .where(
          (p) =>
              p.firstName.toLowerCase().contains(q) ||
              p.lastName.toLowerCase().contains(q) ||
              (p.phone?.contains(q) ?? false) ||
              (p.nationalId?.toLowerCase().contains(q) ?? false) ||
              (p.smarthealthPatientId?.toLowerCase().contains(q) ?? false),
        )
        .take(50)
        .toList();
  }

  Future<Map<String, dynamic>> getChart(String patientId) async {
    if (api != null) {
      try {
        final remote = await api!.getPatientChart(patientId);
        await _cacheChart(remote);
        final local = await _localChart(patientId);
        return _mergeCharts(remote, local);
      } catch (_) {}
    }

    return _localChart(patientId);
  }

  Future<Map<String, dynamic>> _localChart(String patientId) async {
    final patient = await (db.select(db.patients)
          ..where((t) => t.id.equals(patientId)))
        .getSingleOrNull();

    final allergies = await (db.select(db.patientAllergies)
          ..where((t) => t.patientId.equals(patientId)))
        .get();

    final conditions = await (db.select(db.patientConditions)
          ..where((t) => t.patientId.equals(patientId)))
        .get();

    final consultations = await (db.select(db.consultations)
          ..where((t) => t.patientId.equals(patientId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();

    return {
      'patient': patient,
      'allergies': allergies,
      'conditions': conditions,
      'timeline': consultations,
    };
  }

  Map<String, dynamic> _mergeCharts(
    Map<String, dynamic> remote,
    Map<String, dynamic> local,
  ) {
    final remoteTimeline = remote['timeline'] as List? ?? [];
    final localTimeline = local['timeline'] as List? ?? [];
    final pendingLocal = localTimeline.where((item) {
      if (item is Consultation) {
        return item.syncStatus == 'pending' || item.serverId == null;
      }
      return false;
    });

    return {
      ...remote,
      'timeline': [...remoteTimeline, ...pendingLocal],
    };
  }

  Future<void> _cachePatient(Patient patient) async {
    await db.into(db.patients).insertOnConflictUpdate(
          PatientsCompanion.insert(
            id: patient.id,
            serverId: Value(patient.serverId ?? patient.id),
            firstName: patient.firstName,
            lastName: patient.lastName,
            phone: Value(patient.phone),
            email: Value(patient.email),
            nationalId: Value(patient.nationalId),
            smarthealthPatientId: Value(patient.smarthealthPatientId),
            gender: Value(patient.gender),
            dateOfBirth: Value(patient.dateOfBirth),
            passport: Value(patient.passport),
            insuranceInfo: Value(patient.insuranceInfo),
            updatedAt: DateTime.now().toUtc(),
            syncStatus: const Value('synced'),
          ),
        );
  }

  Future<void> _cacheChart(Map<String, dynamic> chart) async {
    final patientRaw = chart['patient'];
    if (patientRaw is Map<String, dynamic>) {
      await _cachePatient(_patientFromApi(patientRaw));
    }

    final patientId = patientRaw is Map
        ? patientRaw['id'] as String?
        : (patientRaw as Patient?)?.id;
    if (patientId == null) return;

    final now = DateTime.now().toUtc();
    for (final raw in chart['allergies'] as List? ?? []) {
      if (raw is! Map<String, dynamic>) continue;
      await db.into(db.patientAllergies).insertOnConflictUpdate(
            PatientAllergiesCompanion.insert(
              id: raw['id'] as String? ?? '${patientId}-${raw['allergen']}',
              patientId: patientId,
              allergen: raw['allergen'] as String? ?? 'Unknown',
              severity: Value(raw['severity'] as String?),
              updatedAt: now,
            ),
          );
    }

    for (final raw in chart['conditions'] as List? ?? []) {
      if (raw is! Map<String, dynamic>) continue;
      await db.into(db.patientConditions).insertOnConflictUpdate(
            PatientConditionsCompanion.insert(
              id: raw['id'] as String? ?? '${patientId}-${raw['condition_name']}',
              patientId: patientId,
              conditionName: raw['condition_name'] as String? ??
                  raw['conditionName'] as String? ??
                  'Condition',
              icd11Code: Value(
                raw['icd11_code'] as String? ?? raw['icd11Code'] as String?,
              ),
              updatedAt: now,
            ),
          );
    }

    for (final raw in chart['timeline'] as List? ?? []) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['id'] as String?;
      if (id == null) continue;
      await db.into(db.consultations).insertOnConflictUpdate(
            ConsultationsCompanion.insert(
              id: id,
              serverId: Value(id),
              facilityId: facilityId,
              providerId: raw['provider_id'] as String? ??
                  raw['providerId'] as String? ??
                  'unknown',
              patientId: patientId,
              status: Value(raw['status'] as String? ?? 'completed'),
              chiefComplaint: Value(
                raw['chief_complaint'] as String? ?? raw['chiefComplaint'] as String?,
              ),
              assessment: Value(raw['assessment'] as String?),
              plan: Value(raw['plan'] as String?),
              startedAt: Value(
                DateTime.tryParse(raw['started_at'] as String? ?? '') ??
                    DateTime.tryParse(raw['startedAt'] as String? ?? ''),
              ),
              completedAt: Value(
                DateTime.tryParse(raw['completed_at'] as String? ?? '') ??
                    DateTime.tryParse(raw['completedAt'] as String? ?? ''),
              ),
              updatedAt: now,
              syncStatus: const Value('synced'),
            ),
          );
    }
  }

  Patient _patientFromApi(Map<String, dynamic> m) {
    return Patient(
      id: m['id'] as String,
      firstName: m['firstName'] as String? ?? m['first_name'] as String? ?? '',
      lastName: m['lastName'] as String? ?? m['last_name'] as String? ?? '',
      phone: m['phone'] as String?,
      nationalId: m['nationalId'] as String? ?? m['national_id'] as String?,
      smarthealthPatientId: m['smarthealthPatientId'] as String?,
      email: m['email'] as String?,
      gender: m['gender'] as String?,
      dateOfBirth: m['dateOfBirth'] != null
          ? DateTime.tryParse(m['dateOfBirth'] as String)
          : m['date_of_birth'] != null
              ? DateTime.tryParse(m['date_of_birth'] as String)
              : null,
      passport: null,
      insuranceInfo: null,
      serverId: m['id'] as String?,
      syncStatus: 'synced',
      updatedAt: DateTime.now(),
      deletedAt: null,
    );
  }
}

final seedLoaderProvider = Provider<SeedDataLoader>((ref) {
  return SeedDataLoader(ref.watch(appDatabaseProvider));
});

final facilityRepositoryProvider = Provider<FacilityRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';
  return FacilityRepository(
    db: db,
    api: FacilityApiClient(ref.watch(facilityDioProvider), facilityId: facilityId),
    facilityId: facilityId,
  );
});

class FacilityRepository {
  FacilityRepository({
    required this.db,
    required this.api,
    required this.facilityId,
  });

  final AppDatabase db;
  final FacilityApiClient? api;
  final String facilityId;

  Future<Facility?> getLocalFacility() {
    return (db.select(db.facilities)..where((t) => t.id.equals(facilityId)))
        .getSingleOrNull();
  }

  Future<Map<String, dynamic>> getProfile() async {
    if (api != null) {
      try {
        return await api!.getProfile();
      } catch (_) {}
    }
    final local = await getLocalFacility();
    if (local == null) return {};
    return {
      'facility': {
        'name': local.name,
        'addressLine1': local.address,
        'city': local.city,
        'latitude': local.latitude,
        'longitude': local.longitude,
      },
      'profileSettings': const <String, dynamic>{},
    };
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    if (api == null) {
      throw StateError('Saving profile requires a signed-in facility session.');
    }
    return api!.updateProfile(body);
  }

  Future<Map<String, dynamic>> updateProfileSettings(
    Map<String, dynamic> body,
  ) async {
    if (api == null) {
      throw StateError('Saving settings requires a signed-in facility session.');
    }
    return api!.updateProfileSettings(body);
  }

  Future<Map<String, List<Map<String, dynamic>>>> getServicesCatalog() async {
    if (api == null) {
      return {'preset': [], 'other': []};
    }
    return api!.getServicesCatalog();
  }

  Future<Map<String, dynamic>> submitServiceProposal(String label) async {
    if (api == null) {
      throw StateError('Proposing a service requires a signed-in facility session.');
    }
    return api!.submitServiceProposal(label: label);
  }

  Future<List<Map<String, dynamic>>> getMedicalAidCatalog() async {
    if (api == null) return [];
    return api!.getMedicalAidCatalog();
  }

  Future<List<Map<String, dynamic>>> getMedicalAidSubmissions({
    String status = 'pending',
  }) async {
    if (api == null) return [];
    return api!.getMedicalAidSubmissions(status: status);
  }

  Future<Map<String, dynamic>> submitMedicalAidProposal(String name) async {
    if (api == null) {
      throw StateError('Proposing medical aid requires a signed-in facility session.');
    }
    return api!.submitMedicalAidProposal(name);
  }

  Future<Map<String, dynamic>> uploadLogo(String filePath, String fileName) async {
    if (api == null) {
      throw StateError('Uploading a logo requires a signed-in facility session.');
    }
    return api!.uploadLogo(filePath, fileName);
  }

  Future<void> removeLogo() async {
    if (api == null) {
      throw StateError('Removing a logo requires a signed-in facility session.');
    }
    return api!.removeLogo();
  }

  Future<Map<String, dynamic>> getSlots() async {
    if (api == null) return {};
    return api!.getSlots();
  }

  Future<Map<String, dynamic>> updateSlots(Map<String, dynamic> body) async {
    if (api == null) {
      throw StateError('Updating slots requires a signed-in facility session.');
    }
    return api!.updateSlots(body);
  }

  Future<List<Map<String, dynamic>>> getCredentials() async {
    if (api == null) return [];
    return api!.getCredentials();
  }

  Future<Map<String, dynamic>> createCredential({
    required String credentialType,
    required String title,
    String? issuedAt,
    String? expiresAt,
  }) async {
    if (api == null) {
      throw StateError('Adding credentials requires a signed-in facility session.');
    }
    return api!.createCredential(
      credentialType: credentialType,
      title: title,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
    );
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    if (api == null) return [];
    return api!.getMessages();
  }

  Future<Map<String, dynamic>> sendMessage({
    required String recipientId,
    required String body,
  }) async {
    if (api == null) {
      throw StateError('Sending messages requires a signed-in facility session.');
    }
    return api!.sendMessage(recipientId: recipientId, body: body);
  }

  Future<void> markMessageRead(String messageId) async {
    if (api == null) return;
    return api!.markMessageRead(messageId);
  }

  Future<List<String>> getDoctorServiceIds(String providerId) async {
    if (api == null) return [];
    return api!.getDoctorServiceIds(providerId);
  }

  Future<List<String>> updateDoctorServiceIds(
    String providerId,
    List<String> serviceIds,
  ) async {
    if (api == null) {
      throw StateError('Saving services requires a signed-in facility session.');
    }
    return api!.updateDoctorServiceIds(providerId, serviceIds);
  }

  Future<List<Practitioner>> getTeam() async {
    if (api != null) {
      try {
        final data = await api!.getStaff();
        final items = data['staff'] as List? ?? data['items'] as List? ?? [];
        final now = DateTime.now().toUtc();
        final team = <Practitioner>[];
        for (final raw in items) {
          if (raw is! Map) continue;
          final map = Map<String, dynamic>.from(raw);
          // Use user_id as the stable practitioner ID; store the membership
          // ID in serverId so the UI can call update/suspend/remove endpoints.
          final userId = _pickString(map, ['user_id', 'userId']) ?? '';
          final membershipId = _pickString(map, ['id', 'membership_id', 'membershipId']) ?? userId;
          final id = userId.isNotEmpty ? userId : membershipId;
          if (id.isEmpty) continue;
          final first = _pickString(map, ['first_name', 'firstName']) ?? '';
          final last = _pickString(map, ['last_name', 'lastName']) ?? '';
          var name = '$first $last'.trim();
          name = name.isNotEmpty
              ? name
              : (_pickString(map, ['name', 'displayName', 'email']) ??
                  'Staff member');
          final role = _pickString(map, ['role']) ?? 'staff';
          final suspended = map['suspended'] == true;
          // Encode suspended state in syncStatus so it survives local DB
          // without needing a schema change: 'suspended' vs 'synced'.
          final syncStatus = suspended ? 'suspended' : 'synced';
          final p = Practitioner(
            id: id,
            facilityId: facilityId,
            name: name,
            specialty: _pickString(map, ['specialty']),
            registrationNumber: _pickString(
              map,
              ['registrationNumber', 'mdpcz_number', 'registration_number'],
            ),
            role: role,
            serverId: membershipId,
            syncStatus: syncStatus,
            updatedAt: now,
          );
          team.add(p);
          await db.into(db.practitioners).insertOnConflictUpdate(
                PractitionersCompanion.insert(
                  id: p.id,
                  facilityId: facilityId,
                  name: p.name,
                  specialty: Value(p.specialty),
                  registrationNumber: Value(p.registrationNumber),
                  role: Value(p.role),
                  serverId: Value(p.serverId),
                  syncStatus: p.syncStatus,
                  updatedAt: now,
                ),
              );
        }
        if (team.isNotEmpty) return team;
      } catch (_) {
        // Fall through to local cache / seed below.
      }
    }

    // Only write seed practitioners in full dev-bypass mode (SKIP_AUTH=true).
    // When the user is authenticated against a real server we must not pollute
    // the local DB with fake seed rows.
    if (MyPracticeConfig.skipAuthForTesting) {
      await DevTeamSeed.ensure(db, facilityId);
    }

    var local = await (db.select(db.practitioners)
          ..where((t) => t.facilityId.equals(facilityId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();

    if (local.isEmpty && MyPracticeConfig.skipAuthForTesting) {
      return DevTeamSeed.fallbackRows(facilityId);
    }

    return local;
  }

  static String? _pickString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  static String _pickStaffId(Map<String, dynamic> map) {
    return _pickString(
          map,
          ['user_id', 'userId', 'id', 'membership_id', 'membershipId'],
        ) ??
        '';
  }

  Future<void> inviteStaffMember({
    required String fullName,
    required String email,
    required String role,
    String? phone,
  }) async {
    if (api == null) {
      throw StateError('Staff invites require a signed-in facility session.');
    }
    await api!.addStaff(
      fullName: fullName,
      email: email,
      role: role,
      phone: phone,
    );
  }

  Future<void> updateStaffMember(
    String membershipId, {
    String? fullName,
    String? email,
    String? phone,
    String? role,
  }) async {
    if (api == null) throw StateError('Editing staff requires a signed-in session.');
    await api!.updateStaff(
      membershipId,
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
    );
  }

  Future<void> removeStaffMember(String membershipId) async {
    if (api == null) throw StateError('Removing staff requires a signed-in session.');
    await api!.removeStaff(membershipId);
  }

  Future<void> suspendStaffMember(String membershipId) async {
    if (api == null) throw StateError('Suspending staff requires a signed-in session.');
    await api!.suspendStaff(membershipId);
  }

  Future<void> unsuspendStaffMember(String membershipId) async {
    if (api == null) throw StateError('Restoring staff requires a signed-in session.');
    await api!.unsuspendStaff(membershipId);
  }

  Future<List<FacilityHour>> getFacilityHours() async {
    if (api != null) {
      try {
        final rows = await api!.getFacilityHours();
        if (rows.isNotEmpty) {
          return FacilityHour.mergeWeek(
            rows.map(FacilityHour.fromJson).toList(),
          );
        }
      } catch (_) {}
    }
    if (MyPracticeConfig.useLocalDevSeed) {
      return FacilityHour.devDefaults();
    }
    return FacilityHour.mergeWeek(const []);
  }

  Future<List<FacilityHour>> updateFacilityHours(List<FacilityHour> hours) async {
    if (api != null) {
      try {
        final rows = await api!.updateFacilityHours(
          hours.map((h) => h.toJson()).toList(),
        );
        return FacilityHour.mergeWeek(rows.map(FacilityHour.fromJson).toList());
      } catch (_) {
        rethrow;
      }
    }
    if (MyPracticeConfig.useLocalDevSeed) {
      return hours;
    }
    throw StateError('Saving hours requires a signed-in facility session.');
  }

  Future<List<FacilityHour>> getProviderSchedule(String providerId) async {
    if (api != null) {
      try {
        final rows = await api!.getProviderAvailability(providerId: providerId);
        if (rows.isNotEmpty) {
          return FacilityHour.mergeWeek(rows.map(FacilityHour.fromJson).toList());
        }
      } catch (_) {}
    }
    if (MyPracticeConfig.useLocalDevSeed) {
      return DevProviderSchedule.defaults();
    }
    return FacilityHour.mergeWeek(const []);
  }

  Future<List<FacilityHour>> updateProviderSchedule(
    String providerId,
    List<FacilityHour> hours,
  ) async {
    if (api != null) {
      try {
        final rows = await api!.updateProviderAvailability(
          providerId,
          hours.map((h) => h.toJson()).toList(),
        );
        return FacilityHour.mergeWeek(rows.map(FacilityHour.fromJson).toList());
      } catch (_) {
        rethrow;
      }
    }
    if (MyPracticeConfig.useLocalDevSeed) {
      return hours;
    }
    throw StateError('Saving schedule requires a signed-in facility session.');
  }

  Future<void> ensureTeamSeeded() async {
    await DevTeamSeed.ensure(db, facilityId);
  }

  Future<void> _ensureDefaultTeam() async {
    await DevTeamSeed.ensure(db, facilityId);
  }
}
