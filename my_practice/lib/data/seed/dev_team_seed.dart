import 'package:drift/drift.dart';
import 'package:my_practice/data/local/app_database.dart';

/// Dev-mode facility staff — single source of truth for team seeding + fallback.
abstract final class DevTeamSeed {
  static const seedFacilityId = 'seed-facility-001';

  static const members = [
    (
      id: 'seed-provider-001',
      name: 'Dr. Seed Practitioner',
      specialty: 'General Practice',
      role: 'doctor',
      registration: 'MDPCZ-SEED-001',
    ),
    (
      id: 'seed-nurse-001',
      name: 'Sr. Rudo Ncube',
      specialty: 'Nursing',
      role: 'Nurse',
      registration: null,
    ),
    (
      id: 'seed-reception-001',
      name: 'Tinashe Mutasa',
      specialty: null,
      role: 'Receptionist',
      registration: null,
    ),
    (
      id: 'seed-admin-001',
      name: 'Grace Chikwanha',
      specialty: null,
      role: 'Administrator',
      registration: null,
    ),
  ];

  static String effectiveFacilityId(String? raw) {
    if (raw == null || raw.isEmpty) return seedFacilityId;
    return raw;
  }

  static Future<void> ensure(AppDatabase db, String facilityId) async {
    final target = effectiveFacilityId(facilityId);
    final now = DateTime.now().toUtc();

    await db.into(db.facilities).insert(
          FacilitiesCompanion.insert(
            id: target,
            name: 'Avenues Clinic (Seed)',
            city: const Value('Harare'),
            address: const Value('1 Borrowdale Road'),
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );

    for (final m in members) {
      await db.into(db.practitioners).insert(
            PractitionersCompanion.insert(
              id: m.id,
              facilityId: target,
              name: m.name,
              specialty: Value(m.specialty),
              role: Value(m.role),
              registrationNumber: Value(m.registration),
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  static List<Practitioner> fallbackRows(String facilityId) {
    final target = effectiveFacilityId(facilityId);
    final now = DateTime.now().toUtc();
    return members
        .map(
          (m) => Practitioner(
            id: m.id,
            facilityId: target,
            name: m.name,
            specialty: m.specialty,
            registrationNumber: m.registration,
            role: m.role,
            syncStatus: 'synced',
            updatedAt: now,
          ),
        )
        .toList();
  }
}
