import 'dart:developer' as developer;

import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_storage.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_service.dart';

const _logName = 'SyncRecoveryService';

/// Recovers failed sync items and resolves manual appointment conflicts.
class SyncRecoveryService {
  SyncRecoveryService({
    required SyncService syncService,
    SyncQueueStorage? queueStorage,
  })  : _sync = syncService,
        _queue = queueStorage ?? syncService.queueStorage;

  final SyncService _sync;
  final SyncQueueStorage _queue;

  Future<SyncRunResult> retryAllManual() async {
    developer.log('Resetting manual retry items', name: _logName);
    return _sync.retryManualItems();
  }

  Future<SyncRunResult> resolveManualConflict({
    required String queueItemId,
    required bool preferLocal,
  }) async {
    final manual = await _queue.getManualRetryItems();
    SyncQueueItem? item;
    for (final candidate in manual) {
      if (candidate.id == queueItemId) {
        item = candidate;
        break;
      }
    }

    if (item == null) {
      developer.log('Conflict item $queueItemId not found', name: _logName);
      return const SyncRunResult.idle();
    }

    if (preferLocal) {
      await _queue.updateItem(
        item.copyWith(
          status: SyncQueueStatus.pending,
          retryCount: 0,
          clearNextRetryAt: true,
          clearLastError: true,
        ),
      );
    } else {
      await _queue.markCompleted(item.id);
    }

    return _sync.syncNow(trigger: SyncTrigger.manualRetry);
  }

  Future<int> recoverStaleProcessingItems() async {
    final all = await _queue.getAllPending();
    var recovered = 0;

    for (final item in all) {
      if (item.status == SyncQueueStatus.processing) {
        await _queue.updateItem(
          item.copyWith(
            status: SyncQueueStatus.pending,
            nextRetryAt: DateTime.now().toUtc(),
          ),
        );
        recovered++;
      }
    }

    if (recovered > 0) {
      developer.log('Recovered $recovered stale processing items', name: _logName);
    }
    return recovered;
  }
}
