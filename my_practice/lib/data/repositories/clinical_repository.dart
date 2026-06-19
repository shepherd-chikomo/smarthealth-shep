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

final providerIdProvider = Provider<String>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.profile?.provider?.id ?? auth.profile?.id ?? 'seed-provider-001';
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
  final String providerId;

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

    final localId = consultationId ?? _uuid.v4();
    final now = DateTime.now().toUtc();
    await db.into(db.consultations).insert(
          ConsultationsCompanion.insert(
            id: localId,
            facilityId: facilityId,
            providerId: providerId,
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

    try {
      final res = await api!.createConsultation({
        'patientId': row.patientId,
        'providerId': providerId,
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
          'provider_id': providerId,
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
    await db.into(db.diagnoses).insert(
          DiagnosesCompanion.insert(
            id: id,
            consultationId: consultationId,
            patientId: patientId,
            providerId: providerId,
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
        providerId: providerId,
        icd11Code: icd11Code,
        description: description,
        isPrimary: true,
      );
    } catch (_) {
      // Diagnosis sync via consultation update is sufficient for pilot.
    }
  }
}
