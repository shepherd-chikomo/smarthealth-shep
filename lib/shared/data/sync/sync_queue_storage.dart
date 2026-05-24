import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';

/// Abstraction over sync queue persistence (Hive primary, SQLite legacy).
abstract class SyncQueueStorage {
  Future<void> enqueue(SyncQueueItem item);
  Future<List<SyncQueueItem>> getRunnableItems({DateTime? now});
  Future<List<SyncQueueItem>> getManualRetryItems();
  Future<List<SyncQueueItem>> getAllPending();
  Future<int> countPending();
  Future<void> updateItem(SyncQueueItem item);
  Future<void> markProcessing(String id);
  Future<void> markCompleted(String id);
  Future<void> deleteCompleted({Duration olderThan = const Duration(days: 7)});
  Future<void> resetManualRetryItems();
}
