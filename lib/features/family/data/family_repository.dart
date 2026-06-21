import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/features/family/data/family_member_ids.dart';
import 'package:smarthealth_shep/features/family/data/local/family_member_dao.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_repository.dart';
import 'package:smarthealth_shep/core/privacy/phi_boundary.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_service.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

const _logName = 'FamilyRepository';

/// Local-first family member storage synced with `/patients/family`.
class FamilyRepository {
  FamilyRepository({
    FamilyMemberDao? dao,
    SyncService? syncService,
    Connectivity? connectivity,
    Dio? dio,
    HealthVaultRepository? healthVault,
  })  : _dao = dao ?? FamilyMemberDao(),
        _syncService = syncService ?? SyncService.instance ?? SyncService.forBackground(),
        _connectivity = connectivity ?? Connectivity(),
        _dio = dio ?? createApiDio(),
        _healthVault = healthVault ?? HealthVaultRepository();

  final FamilyMemberDao _dao;
  final SyncService _syncService;
  final Connectivity _connectivity;
  final Dio _dio;
  final HealthVaultRepository _healthVault;

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Pulls family members from the API and replaces local demo/offline rows.
  Future<void> syncFromRemote() async {
    if (!await isOnline()) return;

    try {
      final response = await _dio.get<Map<String, dynamic>>('/patients/family');
      final raw = response.data?['family'] as List<dynamic>? ?? const [];
      final members = raw
          .whereType<Map<String, dynamic>>()
          .map(FamilyMemberModel.fromApiJson)
          .toList();

      final cloudOnly = members
          .map(
            (m) => m.copyWith(
              allergies: null,
              medicalConditions: const [],
              metadata: null,
            ),
          )
          .toList();

      if (AppConfig.useMainDatabase) {
        await _dao.replaceAll(cloudOnly);
      } else if (cloudOnly.isNotEmpty) {
        await _dao.replaceAll(cloudOnly);
      }

      developer.log(
        'Synced ${members.length} family members from API',
        name: _logName,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Family sync pull failed — keeping local cache',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<FamilyMemberModel>> loadMembers({bool syncRemote = false}) async {
    if (syncRemote) {
      await syncFromRemote();
    }
    final members = await _dao.getAll();
    return _healthVault.enrichAllMembers(members);
  }

  Future<FamilyMemberModel> addMember(FamilyMemberModel member) =>
      saveMember(member);

  Future<FamilyMemberModel> updateMember(FamilyMemberModel member) =>
      saveMember(member);

  Future<FamilyMemberModel> saveMember(FamilyMemberModel member) async {
    final now = DateTime.now().toUtc();
    var prepared = _prepareForApi(
      (member.id.isEmpty ? member.copyWith(id: _newLocalId()) : member)
          .copyWith(updatedAt: now),
    );

    await _healthVault.saveFromFamilyMember(prepared);

    if (await isOnline()) {
      try {
        final saved = await _pushToServer(prepared);
        final cloudMember = saved.copyWith(
          allergies: null,
          medicalConditions: const [],
          metadata: null,
        );
        await _dao.upsertServerMember(cloudMember, previousLocalId: prepared.id);
        developer.log('Saved family member ${cloudMember.id} to API', name: _logName);
        return prepared;
      } on DioException catch (error, stackTrace) {
        if (_shouldQueueAfterApiFailure(error)) {
          developer.log(
            'Family API save failed — saved locally and queued for sync',
            name: _logName,
            error: error,
            stackTrace: stackTrace,
          );
          return _persistLocallyAndQueue(prepared);
        }
        developer.log(
          'Authenticated family save failed',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      } catch (error, stackTrace) {
        developer.log(
          'Family save failed',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    }

    if (isServerFamilyMemberId(prepared.id)) {
      await _dao.update(prepared);
      await _enqueue(SyncMutationType.update, prepared);
    } else {
      prepared = prepared.copyWith(id: prepared.id.isEmpty ? _newLocalId() : prepared.id);
      await _dao.insert(prepared);
      await _enqueue(SyncMutationType.create, prepared);
    }
    return prepared;
  }

  Future<FamilyMemberModel> _pushToServer(FamilyMemberModel member) async {
    final payload = PhiBoundary.stripPhi(member.toApiPayload());
    PhiBoundary.assertCloudSafe(payload);

    if (isServerFamilyMemberId(member.id)) {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/patients/family/${member.id}',
        data: payload,
      );
      return _parseMemberResponse(response.data);
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/patients/family',
      data: payload,
    );
    return _parseMemberResponse(response.data);
  }

  FamilyMemberModel _parseMemberResponse(Map<String, dynamic>? data) {
    final memberJson = data?['member'] as Map<String, dynamic>? ?? data;
    if (memberJson == null) {
      throw StateError('Family API response missing member payload');
    }
    return FamilyMemberModel.fromApiJson(memberJson);
  }

  Future<void> _enqueue(
    SyncMutationType type,
    FamilyMemberModel member,
  ) async {
    await _syncService.enqueue(
      mutationType: type,
      entityType: SyncEntityType.family,
      entityId: member.id,
      payload: member.toApiPayload(),
      clientUpdatedAt: member.updatedAt ?? DateTime.now().toUtc(),
    );
  }

  Future<void> deleteMember(String id) async {
    final existing = await _dao.getById(id);
    if (existing == null) return;
    await _healthVault.deleteSubject(id);

    if (await isOnline() && isServerFamilyMemberId(id)) {
      try {
        await _dio.delete<void>('/patients/family/$id');
        await _dao.delete(id);
        return;
      } catch (error, stackTrace) {
        developer.log(
          'Direct family delete failed — queueing',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    await _dao.delete(id);
    if (isServerFamilyMemberId(id)) {
      await _syncService.enqueue(
        mutationType: SyncMutationType.delete,
        entityType: SyncEntityType.family,
        entityId: id,
        payload: const {},
      );
    }
  }

  bool _shouldQueueAfterApiFailure(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) return true;
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError;
  }

  Future<FamilyMemberModel> _persistLocallyAndQueue(
    FamilyMemberModel prepared,
  ) async {
    var member = prepared;
    if (isServerFamilyMemberId(member.id)) {
      await _dao.update(member);
      await _enqueue(SyncMutationType.update, member);
    } else {
      member = member.copyWith(
        id: member.id.isEmpty ? _newLocalId() : member.id,
      );
      await _dao.insert(member);
      await _enqueue(SyncMutationType.create, member);
    }
    return member;
  }

  String _newLocalId() => 'fm_${DateTime.now().millisecondsSinceEpoch}';

  FamilyMemberModel _prepareForApi(FamilyMemberModel member) {
    final dob = _normalizeDateOnly(member.dateOfBirth);
    if (dob == member.dateOfBirth) return member;
    return member.copyWith(dateOfBirth: dob);
  }

  String? _normalizeDateOnly(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) return trimmed;
    final parsed = DateTime.tryParse(trimmed);
    if (parsed == null) return null;
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }
}
