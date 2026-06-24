import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/remote/facility_api_client.dart';
import 'package:my_practice/data/sync/sync_engine.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final providerIdProvider = Provider<String?>((ref) {
  if (MyPracticeConfig.skipAuthForTesting) return 'seed-provider-001';
  final providerId = ref.watch(authStateProvider).profile?.provider?.id;
  if (providerId == null || providerId.isEmpty) return null;
  return providerId;
});

class ProviderProfileRequired implements Exception {
  const ProviderProfileRequired();

  @override
  String toString() =>
      'Link your practitioner profile before starting clinical encounters.';
}

final clinicalRepositoryProvider = Provider<ClinicalRepository>((ref) {
  final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';
  final providerId = ref.watch(providerIdProvider);
  return ClinicalRepository(
    db: ref.watch(appDatabaseProvider),
    api: MyPracticeConfig.skipAuthForTesting
        ? null
        : FacilityApiClient(ref.watch(facilityDioProvider), facilityId: facilityId),
    sync: ref.watch(syncEngineProvider),
    facilityId: facilityId,
    providerId: providerId,
  );
});

class ClinicalRepository {
  ClinicalRepository({
    required this.db,
    required this.api,
    required this.sync,
    required this.facilityId,
    required this.providerId,
  });

  final AppDatabase db;
  final FacilityApiClient? api;
  final SyncEngine? sync;
  final String facilityId;
  final String? providerId;

  String get _effectiveProviderId {
    if (providerId != null && providerId!.isNotEmpty) return providerId!;
    if (MyPracticeConfig.skipAuthForTesting) return 'seed-provider-001';
    throw const ProviderProfileRequired();
  }

  Future<String> ensureConsultation({
    String? consultationId,
    required String patientId,
    String? walkInSessionId,
    String? appointmentId,
  }) async {
    if (consultationId != null) {
      final existing = await (db.select(db.consultations)
            ..where((t) => t.id.equals(consultationId)))
          .getSingleOrNull();
      if (existing != null) {
        await _ensureServerConsultation(existing, walkInSessionId, appointmentId);
        return existing.id;
      }
    }

    final effectiveProviderId = _effectiveProviderId;
    final localId = consultationId ?? _uuid.v4();
    final now = DateTime.now().toUtc();
    await db.into(db.consultations).insert(
          ConsultationsCompanion.insert(
            id: localId,
            facilityId: facilityId,
            providerId: effectiveProviderId,
            patientId: patientId,
            appointmentId: Value(appointmentId),
            startedAt: Value(now),
            updatedAt: now,
            syncStatus: const Value('pending'),
          ),
        );

    final row = await (db.select(db.consultations)
          ..where((t) => t.id.equals(localId)))
        .getSingle();
    await _ensureServerConsultation(row, walkInSessionId, appointmentId);
    return localId;
  }

  Future<void> _ensureServerConsultation(
    Consultation row,
    String? walkInSessionId,
    String? appointmentId,
  ) async {
    if (row.serverId != null || api == null) return;

    final effectiveProviderId = _effectiveProviderId;
    try {
      final res = await api!.createConsultation({
        'patientId': row.patientId,
        'providerId': effectiveProviderId,
        if (appointmentId != null) 'appointmentId': appointmentId,
        if (walkInSessionId != null) 'walkInSessionId': walkInSessionId,
      });
      final serverId = res['id'] as String?;
      if (serverId == null) return;

      await (db.update(db.consultations)..where((t) => t.id.equals(row.id))).write(
            ConsultationsCompanion(
              serverId: Value(serverId),
              syncStatus: const Value('synced'),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
    } catch (_) {
      await sync?.enqueue(
        entityType: 'consultation',
        entityId: row.id,
        operation: 'create',
        payload: {
          'patient_id': row.patientId,
          'provider_id': effectiveProviderId,
          if (walkInSessionId != null) 'walk_in_session_id': walkInSessionId,
          if (appointmentId != null) 'appointment_id': appointmentId,
        },
      );
    }
  }

  Future<void> saveConsultation({
    required String consultationId,
    required Map<String, String> sections,
    bool complete = false,
    String? icd11Code,
    String? icd11Description,
  }) async {
    final now = DateTime.now().toUtc();
    await (db.update(db.consultations)..where((t) => t.id.equals(consultationId)))
        .write(
      ConsultationsCompanion(
        chiefComplaint: Value(sections['chiefComplaint']),
        historyOfPresentIllness: Value(sections['historyOfPresentIllness']),
        pastMedicalHistory: Value(sections['pastMedicalHistory']),
        surgicalHistory: Value(sections['surgicalHistory']),
        familyHistory: Value(sections['familyHistory']),
        socialHistory: Value(sections['socialHistory']),
        examinationNotes: Value(sections['examinationNotes']),
        assessment: Value(sections['assessment']),
        plan: Value(sections['plan']),
        followUpPlan: Value(sections['followUpPlan']),
        status: Value(complete ? 'completed' : 'in_progress'),
        completedAt: complete ? Value(now) : const Value(null),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
      ),
    );

    final row = await (db.select(db.consultations)
          ..where((t) => t.id.equals(consultationId)))
        .getSingle();

    if (icd11Code != null && icd11Description != null) {
      await _saveDiagnosis(
        consultationId: consultationId,
        patientId: row.patientId,
        icd11Code: icd11Code,
        description: icd11Description,
      );
    }

    final patch = _consultationPatch(sections);
    final serverId = row.serverId;

    if (api != null && serverId != null) {
      try {
        if (patch.isNotEmpty) {
          await api!.updateConsultation(serverId, patch);
        }
        if (complete) {
          await api!.completeConsultation(serverId);
        }
        await (db.update(db.consultations)..where((t) => t.id.equals(consultationId)))
            .write(
          ConsultationsCompanion(
            syncStatus: const Value('synced'),
            updatedAt: Value(now),
          ),
        );
        return;
      } catch (_) {}
    }

    if (patch.isNotEmpty) {
      await sync?.enqueue(
        entityType: 'consultation',
        entityId: serverId ?? consultationId,
        operation: 'update',
        payload: patch,
      );
    }
    if (complete) {
      await sync?.enqueue(
        entityType: 'consultation',
        entityId: serverId ?? consultationId,
        operation: 'complete',
        payload: const {},
      );
    }
  }

  Map<String, dynamic> _consultationPatch(Map<String, String> sections) {
    return {
      if (sections['chiefComplaint']?.isNotEmpty == true)
        'chief_complaint': sections['chiefComplaint'],
      if (sections['historyOfPresentIllness']?.isNotEmpty == true)
        'history_of_present_illness': sections['historyOfPresentIllness'],
      if (sections['pastMedicalHistory']?.isNotEmpty == true)
        'past_medical_history': sections['pastMedicalHistory'],
      if (sections['surgicalHistory']?.isNotEmpty == true)
        'surgical_history': sections['surgicalHistory'],
      if (sections['familyHistory']?.isNotEmpty == true)
        'family_history': sections['familyHistory'],
      if (sections['socialHistory']?.isNotEmpty == true)
        'social_history': sections['socialHistory'],
      if (sections['examinationNotes']?.isNotEmpty == true)
        'examination_notes': sections['examinationNotes'],
      if (sections['assessment']?.isNotEmpty == true)
        'assessment': sections['assessment'],
      if (sections['plan']?.isNotEmpty == true) 'plan': sections['plan'],
      if (sections['followUpPlan']?.isNotEmpty == true)
        'follow_up_plan': sections['followUpPlan'],
    };
  }

  Future<void> _saveDiagnosis({
    required String consultationId,
    required String patientId,
    required String icd11Code,
    required String description,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    final effectiveProviderId = _effectiveProviderId;
    await db.into(db.diagnoses).insert(
          DiagnosesCompanion.insert(
            id: id,
            consultationId: consultationId,
            patientId: patientId,
            providerId: effectiveProviderId,
            facilityId: facilityId,
            icd11Code: Value(icd11Code),
            description: description,
            isPrimary: const Value(true),
            updatedAt: now,
          ),
        );

    if (api == null) return;
    final row = await (db.select(db.consultations)
          ..where((t) => t.id.equals(consultationId)))
        .getSingle();
    final serverId = row.serverId;
    if (serverId == null) return;

    try {
      await api!.createDiagnosis(
        serverId,
        patientId: patientId,
        providerId: effectiveProviderId,
        icd11Code: icd11Code,
        description: description,
        isPrimary: true,
      );
    } catch (_) {
      // Diagnosis sync via consultation update is sufficient for pilot.
    }
  }
}
