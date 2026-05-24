import 'package:flutter_test/flutter_test.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_backoff.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_conflict_resolver.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';

void main() {
  group('SyncBackoff', () {
    test('retries every 15 minutes', () {
      expect(SyncBackoff.delayForRetry(1), const Duration(minutes: 15));
      expect(SyncBackoff.delayForRetry(5), const Duration(minutes: 15));
      expect(SyncBackoff.delayForRetry(9), const Duration(minutes: 15));
    });

    test('max retry count is 10', () {
      expect(SyncBackoff.maxRetries, 10);
      expect(SyncBackoff.exceededMaxRetries(9), false);
      expect(SyncBackoff.exceededMaxRetries(10), true);
    });

    test('nextRetryTime adds 15 minutes', () {
      final base = DateTime.utc(2026, 5, 23, 10, 0);
      final next = SyncBackoff.nextRetryTime(1, from: base);
      expect(next, DateTime.utc(2026, 5, 23, 10, 15));
    });
  });

  group('SyncEntityType priority', () {
    test('mission-critical entities sync first', () {
      expect(
        SyncEntityType.emergency.priority <
            SyncEntityType.provider.priority,
        isTrue,
      );
      expect(
        SyncEntityType.provider.priority <
            SyncEntityType.appointment.priority,
        isTrue,
      );
      expect(
        SyncEntityType.queueUpdate.priority <
            SyncEntityType.appointment.priority,
        isTrue,
      );
    });
  });

  group('SyncConflictResolver', () {
    test('server wins for directory data', () {
      final result = SyncConflictResolver.resolve(
        entityType: SyncEntityType.provider,
        entityId: 'p1',
        clientUpdatedAt: DateTime.utc(2026, 5, 23, 12),
        serverUpdatedAt: DateTime.utc(2026, 5, 23, 10),
      );
      expect(result.resolution, SyncConflictResolution.appliedServer);
    });

    test('LWW for family members', () {
      final result = SyncConflictResolver.resolve(
        entityType: SyncEntityType.family,
        entityId: 'f1',
        clientUpdatedAt: DateTime.utc(2026, 5, 23, 12),
        serverUpdatedAt: DateTime.utc(2026, 5, 23, 10),
      );
      expect(result.resolution, SyncConflictResolution.appliedLocal);
    });

    test('appointments require manual resolution on equal timestamps', () {
      final ts = DateTime.utc(2026, 5, 23, 12);
      final result = SyncConflictResolver.resolve(
        entityType: SyncEntityType.appointment,
        entityId: 'a1',
        clientUpdatedAt: ts,
        serverUpdatedAt: ts,
      );
      expect(result.resolution, SyncConflictResolution.requiresManual);
      expect(result.requiresManual, isTrue);
    });

    test('appointments local wins when newer', () {
      final result = SyncConflictResolver.resolve(
        entityType: SyncEntityType.appointment,
        entityId: 'a1',
        clientUpdatedAt: DateTime.utc(2026, 5, 23, 13),
        serverUpdatedAt: DateTime.utc(2026, 5, 23, 12),
      );
      expect(result.resolution, SyncConflictResolution.appliedLocal);
    });
  });

  group('SyncQueueItem', () {
    test('serializes to and from map', () {
      final item = SyncQueueItem(
        id: 'test_1',
        mutationType: SyncMutationType.create,
        entityType: SyncEntityType.appointment,
        entityId: 'appt_1',
        payload: {'status': 'pending'},
        retryCount: 0,
        status: SyncQueueStatus.pending,
        createdAt: DateTime.utc(2026, 5, 23),
        clientUpdatedAt: DateTime.utc(2026, 5, 23),
      );

      final restored = SyncQueueItem.fromMap(item.toMap());
      expect(restored.id, item.id);
      expect(restored.entityType, SyncEntityType.appointment);
      expect(restored.payload['status'], 'pending');
    });
  });
}
