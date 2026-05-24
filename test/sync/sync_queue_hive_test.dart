import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_hive_dao.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';

void main() {
  late Box syncBox;
  late SyncQueueHiveDao dao;

  setUp(() async {
    Hive.init('./.dart_tool/test_hive');
    syncBox = await Hive.openBox(HiveBoxes.syncQueue);
    await syncBox.clear();
    dao = SyncQueueHiveDao(box: syncBox);
  });

  tearDown(() async {
    await syncBox.clear();
    await syncBox.close();
  });

  test('enqueue and retrieve runnable items by priority', () async {
    await dao.enqueue(
      SyncQueueItem(
        id: 'family_1',
        mutationType: SyncMutationType.create,
        entityType: SyncEntityType.family,
        entityId: 'fm_1',
        payload: const {},
        retryCount: 0,
        status: SyncQueueStatus.pending,
        createdAt: DateTime.utc(2026, 5, 23, 10),
      ),
    );
    await dao.enqueue(
      SyncQueueItem(
        id: 'emergency_1',
        mutationType: SyncMutationType.update,
        entityType: SyncEntityType.emergency,
        entityId: 'e_1',
        payload: const {},
        retryCount: 0,
        status: SyncQueueStatus.pending,
        createdAt: DateTime.utc(2026, 5, 23, 11),
      ),
    );

    final items = await dao.getRunnableItems();
    expect(items.length, 2);
    expect(items.first.entityType, SyncEntityType.emergency);
  });

  test('failed items respect next_retry_at', () async {
    await dao.enqueue(
      SyncQueueItem(
        id: 'appt_1',
        mutationType: SyncMutationType.create,
        entityType: SyncEntityType.appointment,
        entityId: 'a1',
        payload: const {},
        retryCount: 1,
        status: SyncQueueStatus.failed,
        createdAt: DateTime.utc(2026, 5, 23),
        nextRetryAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
    );

    final now = await dao.getRunnableItems(now: DateTime.now().toUtc());
    expect(now, isEmpty);
  });

  test('countPending includes manual retry states', () async {
    await dao.enqueue(
      SyncQueueItem(
        id: 'appt_manual',
        mutationType: SyncMutationType.create,
        entityType: SyncEntityType.appointment,
        entityId: 'a2',
        payload: const {},
        retryCount: 10,
        status: SyncQueueStatus.needsManualConflict,
        createdAt: DateTime.utc(2026, 5, 23),
      ),
    );

    expect(await dao.countPending(), 1);
  });
}
