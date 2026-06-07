import 'dart:convert';

import 'package:smarthealth_shep/core/health_vault/health_vault_dao.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_models.dart';
import 'package:smarthealth_shep/core/security/audit_log.dart';
import 'package:smarthealth_shep/features/family/data/local/family_member_dao.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

/// Device-only encrypted medical record store (Health Vault).
class HealthVaultRepository {
  HealthVaultRepository({
    HealthVaultDao? dao,
    FamilyMemberDao? familyDao,
    AuditLog? auditLog,
  })  : _dao = dao ?? HealthVaultDao(),
        _familyDao = familyDao ?? FamilyMemberDao(),
        _auditLog = auditLog ?? AuditLog();

  final HealthVaultDao _dao;
  final FamilyMemberDao _familyDao;
  final AuditLog _auditLog;

  Future<HealthVaultRecord> getOrCreate(String subjectId) async {
    final existing = await _dao.getBySubject(subjectId);
    if (existing != null) return existing;
    return HealthVaultRecord(
      subjectId: subjectId,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Future<HealthVaultRecord> save(HealthVaultRecord record) async {
    final updated = record.copyWith(updatedAt: DateTime.now().toUtc());
    await _dao.upsert(updated);
    return updated;
  }

  Future<HealthVaultRecord> saveFromFamilyMember(FamilyMemberModel member) async {
    final record = HealthVaultRecord.fromFamilyMember(member);
    return save(record);
  }

  Future<FamilyMemberModel> enrichMember(FamilyMemberModel member) async {
    final vault = await _dao.getBySubject(member.id);
    if (vault == null) return member;
    return vault.applyToFamilyMember(member);
  }

  Future<List<FamilyMemberModel>> enrichAllMembers(
    List<FamilyMemberModel> members,
  ) async {
    final enriched = <FamilyMemberModel>[];
    for (final member in members) {
      enriched.add(await enrichMember(member));
    }
    return enriched;
  }

  Future<void> migrateLegacyFamilyPhiIfNeeded() async {
    final members = await _familyDao.getAll();
    for (final member in members) {
      final existing = await _dao.getBySubject(member.id);
      final hasLegacyPhi = member.metadata != null ||
          member.allergies != null ||
          member.medicalConditions.isNotEmpty;
      if (existing == null && hasLegacyPhi) {
        await saveFromFamilyMember(member);
      }
    }
  }

  Future<Map<String, dynamic>> exportSnapshot() async {
    final records = await _dao.getAll();
    return {
      'format': 'healthvault',
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'records': records.map((r) => r.toJson()).toList(),
    };
  }

  Future<void> importSnapshot(Map<String, dynamic> snapshot) async {
    final records = snapshot['records'] as List<dynamic>? ?? const [];
    for (final raw in records) {
      final record = HealthVaultRecord.fromJson(raw as Map<String, dynamic>);
      await save(record);
    }
    await _auditLog.record(
      action: 'health_vault_restore',
      details: {'recordCount': records.length},
    );
  }

  Future<String> emergencyProfileJson(String subjectId) async {
    final record = await getOrCreate(subjectId);
    await _auditLog.record(
      action: 'emergency_profile_read',
      subjectId: subjectId,
    );
    return jsonEncode({
      'bloodGroup': record.bloodGroup,
      'allergies': record.allergies,
      'conditions': record.chronicConditions,
      'medications': record.medications.map((m) => m.name).toList(),
      'emergencyContact': record.emergencyContact.toJson(),
    });
  }

  Future<void> deleteSubject(String subjectId) => _dao.deleteSubject(subjectId);

  Future<void> wipeAll() => _dao.wipeAll();
}
