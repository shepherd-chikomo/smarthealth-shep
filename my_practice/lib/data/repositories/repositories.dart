import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/seed/seed_data_loader.dart';
import 'package:my_practice/data/remote/facility_api_client.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';
  return DashboardRepository(
    db: db,
    api: MyPracticeConfig.devMode
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
      'syncStatus': MyPracticeConfig.devMode ? 'simulated' : 'online',
    };
  }
}

final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';
  return QueueRepository(
    db: db,
    api: MyPracticeConfig.devMode
        ? null
        : FacilityApiClient(ref.watch(facilityDioProvider), facilityId: facilityId),
    facilityId: facilityId,
  );
});

class QueueRepository {
  QueueRepository({
    required this.db,
    required this.api,
    required this.facilityId,
  });

  final AppDatabase db;
  final FacilityApiClient? api;
  final String facilityId;

  Stream<List<QueueEntry>> watchQueue() {
    return (db.select(db.queueEntries)
          ..where((t) => t.facilityId.equals(facilityId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .watch();
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
      await api!.updateQueueStatus(id, status);
    }
  }
}

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';
  return PatientRepository(
    db: db,
    api: MyPracticeConfig.devMode
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

  Future<List<Patient>> search(String query) async {
    if (query.trim().isEmpty) return [];

    if (api != null) {
      try {
        final remote = await api!.searchPatients(query);
        return remote.map(_patientFromApi).toList();
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
        return await api!.getPatientChart(patientId);
      } catch (_) {}
    }

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

  Patient _patientFromApi(Map<String, dynamic> m) {
    return Patient(
      id: m['id'] as String,
      firstName: m['firstName'] as String? ?? '',
      lastName: m['lastName'] as String? ?? '',
      phone: m['phone'] as String?,
      nationalId: m['nationalId'] as String?,
      smarthealthPatientId: m['smarthealthPatientId'] as String?,
      email: m['email'] as String?,
      gender: m['gender'] as String?,
      dateOfBirth: null,
      passport: null,
      insuranceInfo: null,
      serverId: null,
      syncStatus: 'synced',
      updatedAt: DateTime.now(),
      deletedAt: null,
    );
  }
}

final seedLoaderProvider = Provider<SeedDataLoader>((ref) {
  return SeedDataLoader(ref.watch(appDatabaseProvider));
});
