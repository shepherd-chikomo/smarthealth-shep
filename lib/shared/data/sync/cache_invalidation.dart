import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';

/// TTL and invalidation rules for aggressively cached offline data.
abstract final class CacheInvalidationPolicy {
  /// Emergency services — always kept locally, refreshed when online.
  static const emergencyTtl = Duration(days: 30);

  /// Provider directory — aggressive cache for discovery offline.
  static const providerTtl = Duration(days: 14);

  /// Facility information — aggressive cache.
  static const facilityTtl = Duration(days: 14);

  /// Operating hours — always cached locally.
  static const operatingHoursTtl = Duration(days: 30);

  static Duration ttlFor(SyncEntityType entity) => switch (entity) {
        SyncEntityType.emergency => emergencyTtl,
        SyncEntityType.provider => providerTtl,
        SyncEntityType.facility => facilityTtl,
        SyncEntityType.operatingHours => operatingHoursTtl,
        _ => const Duration(hours: 24),
      };

  /// Whether cached data should be refreshed during delta sync.
  static bool shouldRefresh({
    required SyncEntityType entity,
    required DateTime? lastSyncedAt,
    DateTime? now,
  }) {
    if (lastSyncedAt == null) return true;
    final age = (now ?? DateTime.now()).difference(lastSyncedAt);
    return age >= ttlFor(entity);
  }

  /// Whether a record is stale and should show offline badge.
  static bool isStale({
    required SyncEntityType entity,
    required DateTime cachedAt,
    DateTime? now,
  }) {
    final age = (now ?? DateTime.now()).difference(cachedAt);
    return age > ttlFor(entity);
  }

  /// Keys to invalidate after a successful delta pull for [entity].
  static List<String> invalidationKeysFor(SyncEntityType entity) =>
      switch (entity) {
        SyncEntityType.provider => ['providers', 'provider_search'],
        SyncEntityType.facility => ['facilities'],
        SyncEntityType.emergency => ['emergency', 'emergency_nearest'],
        SyncEntityType.operatingHours => ['operating_hours'],
        _ => [],
      };
}
