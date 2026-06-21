import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/remote/facility_api_client.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final claimsRepositoryProvider = Provider<ClaimsRepository>((ref) {
  return ClaimsRepository(
    db: ref.watch(appDatabaseProvider),
    api: ref.watch(facilityRepositoryProvider).api,
    facilityId: ref.watch(facilityIdProvider) ?? 'seed-facility-001',
  );
});

class ClaimsRepository {
  ClaimsRepository({
    required this.db,
    required this.api,
    required this.facilityId,
  });

  final AppDatabase db;
  final FacilityApiClient? api;
  final String facilityId;

  Stream<List<InsuranceClaim>> watchClaims() {
    return (db.select(db.insuranceClaims)
          ..where((t) => t.facilityId.equals(facilityId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Future<void> refreshFromApi() async {
    if (api == null) return;
    try {
      final res = await api!.getClaims();
      final now = DateTime.now().toUtc();
      for (final raw in res) {
        final id = raw['id'] as String? ?? _uuid.v4();
        await db.into(db.insuranceClaims).insertOnConflictUpdate(
              InsuranceClaimsCompanion.insert(
                id: id,
                facilityId: facilityId,
                patientId: raw['patient_id'] as String? ?? 'unknown',
                providerId: raw['provider_id'] as String? ?? 'unknown',
                payerKey: raw['payer_key'] as String? ?? 'unknown',
                status: raw['status'] as String? ?? 'draft',
                amount: Value(_toDouble(raw['amount'])),
                amountPaid: Value(_toDouble(raw['amount_paid'])),
                submittedAt: Value(_parseDate(raw['submitted_at'])),
                updatedAt: now,
              ),
            );
      }
    } catch (_) {}
  }

  Future<void> submitClaim(String claimId) async {
    final now = DateTime.now().toUtc();
    await (db.update(db.insuranceClaims)..where((t) => t.id.equals(claimId)))
        .write(
      InsuranceClaimsCompanion(
        status: const Value('submitted'),
        submittedAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
      ),
    );
    // API hook when POST /clinical/claims/:id/submit lands on backend.
  }

  Future<int> submitAllDrafts() async {
    final drafts = await (db.select(db.insuranceClaims)
          ..where(
            (t) =>
                t.facilityId.equals(facilityId) &
                t.status.equals('draft'),
          ))
        .get();
    for (final c in drafts) {
      await submitClaim(c.id);
    }
    return drafts.length;
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}
