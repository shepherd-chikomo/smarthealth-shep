import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:my_practice/data/local/tables.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Facilities,
  FacilityMemberships,
  Practitioners,
  Patients,
  PatientAllergies,
  PatientConditions,
  Appointments,
  QueueEntries,
  Consultations,
  Diagnoses,
  Vitals,
  Prescriptions,
  SyncQueue,
  SyncCursors,
  FeatureFlags,
  Icd11Codes,
  Medications,
  EdlizRecommendations,
  AuditLogs,
  InsuranceClaims,
  ClinicalTasks,
  InternalMessages,
  PractitionerCredentials,
  FinancialSummaries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(practitioners, practitioners.additionalRoles);
          }
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'my_practice.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  Future<void> wipeAll() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}
