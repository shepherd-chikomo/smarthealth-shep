import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/sync/network_state_manager.dart';
import 'package:smarthealth_shep/core/sync/sync_providers.dart';
import 'package:smarthealth_shep/core/sync/sync_state.dart';
import 'package:smarthealth_shep/shared/data/sync/background_sync_service.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_recovery_service.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_service.dart';

const _logName = 'SyncManager';

/// Riverpod sync manager — coordinates queue processing, delta pulls, and recovery.
class SyncManager extends Notifier<SyncManagerState> {
  Timer? _retryTimer;

  SyncService get _sync => ref.read(syncServiceProvider);
  SyncRecoveryService get _recovery => ref.read(syncRecoveryServiceProvider);

  @override
  SyncManagerState build() {
    ref.onDispose(_dispose);
    _boot();
    return const SyncManagerState();
  }

  Future<void> _boot() async {
    await _refreshCounts();
    ref.listen(networkStateManagerProvider, (previous, next) {
      if (next.isOnline && (previous?.isOnline == false)) {
        developer.log('Network restored — auto sync', name: _logName);
        unawaited(syncNow(trigger: SyncTrigger.networkRestored));
      }
      state = state.copyWith(isOnline: next.isOnline);
    });

    _retryTimer = Timer.periodic(
      BackgroundSyncService.retryInterval,
      (_) => unawaited(_scheduledRetry()),
    );
  }

  Future<void> initialize() async {
    await _sync.initialize();
    await BackgroundSyncService.register();
    if (await ref.read(networkStateManagerProvider.notifier).checkOnline()) {
      await syncNow(trigger: SyncTrigger.appLaunch);
    }
    await _refreshCounts();
  }

  Future<SyncRunResult> syncNow({SyncTrigger trigger = SyncTrigger.manual}) async {
    state = state.copyWith(isSyncing: true, clearError: true);

    try {
      final result = await _sync.syncNow(trigger: trigger);
      await _refreshCounts();

      state = state.copyWith(
        isSyncing: false,
        lastSyncAt: DateTime.now(),
        lastResult: result,
      );
      return result;
    } catch (error, stackTrace) {
      developer.log('Sync failed', name: _logName, error: error, stackTrace: stackTrace);
      state = state.copyWith(
        isSyncing: false,
        lastError: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> pullToRefresh() async {
    await syncNow(trigger: SyncTrigger.pullToRefresh);
  }

  Future<SyncRunResult> retryFailed() => _recovery.retryAllManual();

  Future<SyncRunResult> resolveConflict({
    required String queueItemId,
    required bool preferLocal,
  }) {
    return _recovery.resolveManualConflict(
      queueItemId: queueItemId,
      preferLocal: preferLocal,
    );
  }

  Future<void> _scheduledRetry() async {
    if (!state.isOnline || state.isSyncing) return;
    if (state.pendingCount == 0 && state.manualRetryCount == 0) return;

    developer.log('Scheduled 15-minute retry sync', name: _logName);
    await syncNow(trigger: SyncTrigger.background);
  }

  Future<void> _refreshCounts() async {
    final pending = await _sync.pendingCount();
    final manual = await _sync.manualRetryItems();
    final conflicts = manual
        .where((i) => i.status == SyncQueueStatus.needsManualConflict)
        .toList();

    state = state.copyWith(
      pendingCount: pending,
      manualRetryCount: manual.length,
      conflictCount: conflicts.length,
      manualConflicts: conflicts,
    );
  }

  void _dispose() {
    _retryTimer?.cancel();
    _sync.dispose();
  }
}

final syncManagerProvider =
    NotifierProvider<SyncManager, SyncManagerState>(SyncManager.new);

final syncPendingCountProvider = Provider<int>((ref) {
  return ref.watch(syncManagerProvider).pendingCount;
});

final syncNeedsAttentionProvider = Provider<bool>((ref) {
  return ref.watch(syncManagerProvider).needsAttention;
});
