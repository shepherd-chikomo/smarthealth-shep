import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';

/// Resolves sync conflicts between local and server copies.
abstract final class SyncConflictResolver {
  /// Whether the local mutation should be applied over server data.
  static bool shouldApplyLocalMutation({
    required SyncEntityType entityType,
    required DateTime? clientUpdatedAt,
    required DateTime? serverUpdatedAt,
  }) {
    if (entityType.serverWinsOnConflict) return false;

    if (clientUpdatedAt == null) return true;
    if (serverUpdatedAt == null) return true;

    return !clientUpdatedAt.isBefore(serverUpdatedAt);
  }

  /// Whether incoming server directory data should overwrite local cache.
  static bool shouldApplyServerDirectoryRecord({
    required SyncEntityType entityType,
  }) {
    return entityType.serverWinsOnConflict;
  }
}
