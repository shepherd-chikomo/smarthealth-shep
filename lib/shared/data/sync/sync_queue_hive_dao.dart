import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_storage.dart';

const _itemsKey = 'items';

/// Hive-backed persistence for the offline mutation sync queue.
class SyncQueueHiveDao implements SyncQueueStorage {
  SyncQueueHiveDao({Box? box}) : _box = box;

  Box? _box;

  Box get box => _box ?? Hive.box(HiveBoxes.syncQueue);

  Map<String, dynamic> _readStore() {
    final raw = box.get(_itemsKey);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return {};
  }

  Future<void> _writeStore(Map<String, dynamic> store) async {
    await box.put(_itemsKey, store);
  }

  @override
  Future<void> enqueue(SyncQueueItem item) async {
    final store = _readStore();
    store[item.id] = item.toMap();
    await _writeStore(store);
  }

  @override
  Future<List<SyncQueueItem>> getRunnableItems({DateTime? now}) async {
    final cutoff = now ?? DateTime.now();
    final store = _readStore();

    final items = store.values
        .map((v) => SyncQueueItem.fromMap(Map<String, dynamic>.from(v as Map)))
        .where((item) {
      if (item.status != SyncQueueStatus.pending &&
          item.status != SyncQueueStatus.failed) {
        return false;
      }
      if (item.nextRetryAt == null) return true;
      return !item.nextRetryAt!.isAfter(cutoff);
    }).toList();

    items.sort((a, b) {
      final priority = a.entityType.priority.compareTo(b.entityType.priority);
      if (priority != 0) return priority;
      return a.createdAt.compareTo(b.createdAt);
    });
    return items;
  }

  @override
  Future<List<SyncQueueItem>> getManualRetryItems() async {
    final store = _readStore();
    return store.values
        .map((v) => SyncQueueItem.fromMap(Map<String, dynamic>.from(v as Map)))
        .where(
          (item) =>
              item.status == SyncQueueStatus.needsManualRetry ||
              item.status == SyncQueueStatus.needsManualConflict,
        )
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<List<SyncQueueItem>> getAllPending() async {
    final store = _readStore();
    return store.values
        .map((v) => SyncQueueItem.fromMap(Map<String, dynamic>.from(v as Map)))
        .where(
          (item) =>
              item.status != SyncQueueStatus.completed &&
              item.status != SyncQueueStatus.processing,
        )
        .toList();
  }

  @override
  Future<int> countPending() async {
    final store = _readStore();
    return store.values
        .map((v) => SyncQueueItem.fromMap(Map<String, dynamic>.from(v as Map)))
        .where(
          (item) =>
              item.status == SyncQueueStatus.pending ||
              item.status == SyncQueueStatus.failed ||
              item.status == SyncQueueStatus.needsManualRetry ||
              item.status == SyncQueueStatus.needsManualConflict,
        )
        .length;
  }

  @override
  Future<void> updateItem(SyncQueueItem item) async {
    final store = _readStore();
    store[item.id] = item.toMap();
    await _writeStore(store);
  }

  @override
  Future<void> markProcessing(String id) async {
    final store = _readStore();
    final raw = store[id];
    if (raw == null) return;
    final item = SyncQueueItem.fromMap(Map<String, dynamic>.from(raw as Map));
    store[id] = item.copyWith(status: SyncQueueStatus.processing).toMap();
    await _writeStore(store);
  }

  @override
  Future<void> markCompleted(String id) async {
    final store = _readStore();
    final raw = store[id];
    if (raw == null) return;
    final item = SyncQueueItem.fromMap(Map<String, dynamic>.from(raw as Map));
    store[id] = item
        .copyWith(
          status: SyncQueueStatus.completed,
          clearLastError: true,
        )
        .toMap();
    await _writeStore(store);
  }

  @override
  Future<void> deleteCompleted({
    Duration olderThan = const Duration(days: 7),
  }) async {
    final cutoff = DateTime.now().toUtc().subtract(olderThan);
    final store = _readStore();
    final toRemove = <String>[];

    for (final entry in store.entries) {
      final item = SyncQueueItem.fromMap(
        Map<String, dynamic>.from(entry.value as Map),
      );
      if (item.status == SyncQueueStatus.completed &&
          item.createdAt.isBefore(cutoff)) {
        toRemove.add(entry.key);
      }
    }

    for (final id in toRemove) {
      store.remove(id);
    }
    if (toRemove.isNotEmpty) await _writeStore(store);
  }

  @override
  Future<void> resetManualRetryItems() async {
    final store = _readStore();
    for (final entry in store.entries.toList()) {
      final item = SyncQueueItem.fromMap(
        Map<String, dynamic>.from(entry.value as Map),
      );
      if (item.status == SyncQueueStatus.needsManualRetry ||
          item.status == SyncQueueStatus.needsManualConflict) {
        store[entry.key] = item
            .copyWith(
              status: SyncQueueStatus.pending,
              retryCount: 0,
              clearNextRetryAt: true,
              clearLastError: true,
            )
            .toMap();
      }
    }
    await _writeStore(store);
  }
}
