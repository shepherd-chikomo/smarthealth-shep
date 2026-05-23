import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:smarthealth_shep/features/family/data/local/family_member_dao.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_service.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

const _logName = 'FamilyRepository';

/// Local-first family member storage with queued background sync.
class FamilyRepository {
  FamilyRepository({
    FamilyMemberDao? dao,
    SyncService? syncService,
    Connectivity? connectivity,
  })  : _dao = dao ?? FamilyMemberDao(),
        _syncService = syncService ?? SyncService.instance ?? SyncService.forBackground(),
        _connectivity = connectivity ?? Connectivity();

  final FamilyMemberDao _dao;
  final SyncService _syncService;
  final Connectivity _connectivity;

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<List<FamilyMemberModel>> loadMembers() => _dao.getAll();

  Future<FamilyMemberModel> addMember(FamilyMemberModel member) async {
    final saved =
        member.id.isEmpty ? member.copyWith(id: _newId()) : member;

    await _dao.insert(saved);
    await _syncService.enqueue(
      mutationType: SyncMutationType.create,
      entityType: SyncEntityType.family,
      entityId: saved.id,
      payload: saved.toJson(),
      clientUpdatedAt: DateTime.now().toUtc(),
    );

    developer.log('Added family member ${saved.id} (queued sync)', name: _logName);
    return saved;
  }

  Future<FamilyMemberModel> updateMember(FamilyMemberModel member) async {
    await _dao.update(member);
    await _syncService.enqueue(
      mutationType: SyncMutationType.update,
      entityType: SyncEntityType.family,
      entityId: member.id,
      payload: member.toJson(),
      clientUpdatedAt: DateTime.now().toUtc(),
    );
    return member;
  }

  Future<void> deleteMember(String id) async {
    final existing = await _dao.getById(id);
    await _dao.delete(id);
    if (existing != null) {
      await _syncService.enqueue(
        mutationType: SyncMutationType.delete,
        entityType: SyncEntityType.family,
        entityId: id,
        payload: const {},
      );
    }
  }

  String _newId() => 'fm_${DateTime.now().millisecondsSinceEpoch}';
}
