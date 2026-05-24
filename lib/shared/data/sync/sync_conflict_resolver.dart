import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';

/// Resolves sync conflicts between local and server copies.
abstract final class SyncConflictResolver {
  /// Whether the local mutation should be applied over server data (LWW).
  static bool shouldApplyLocalMutation({
    required SyncEntityType entityType,
    required DateTime? clientUpdatedAt,
    required DateTime? serverUpdatedAt,
  }) {
    if (entityType.serverWinsOnConflict) return false;

    if (entityType.requiresManualConflictResolution) {
      return _appointmentLocalWins(
        clientUpdatedAt: clientUpdatedAt,
        serverUpdatedAt: serverUpdatedAt,
      );
    }

    if (entityType.usesLastWriteWins) {
      return _lastWriteWinsLocal(
        clientUpdatedAt: clientUpdatedAt,
        serverUpdatedAt: serverUpdatedAt,
      );
    }

    if (clientUpdatedAt == null) return true;
    if (serverUpdatedAt == null) return true;

    return !clientUpdatedAt.isBefore(serverUpdatedAt);
  }

  /// Full conflict resolution with manual appointment handling.
  static SyncConflictResult resolve({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime? clientUpdatedAt,
    required DateTime? serverUpdatedAt,
    bool serverModifiedWhilePending = false,
  }) {
    if (entityType.serverWinsOnConflict) {
      return SyncConflictResult(
        resolution: SyncConflictResolution.appliedServer,
        entityType: entityType,
        entityId: entityId,
        serverUpdatedAt: serverUpdatedAt,
        clientUpdatedAt: clientUpdatedAt,
        message: 'Server directory data takes precedence',
      );
    }

    if (entityType.requiresManualConflictResolution) {
      if (serverModifiedWhilePending ||
          _appointmentRequiresManual(
            clientUpdatedAt: clientUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
          )) {
        return SyncConflictResult(
          resolution: SyncConflictResolution.requiresManual,
          entityType: entityType,
          entityId: entityId,
          serverUpdatedAt: serverUpdatedAt,
          clientUpdatedAt: clientUpdatedAt,
          message: 'Appointment changed on server while offline — review required',
        );
      }

      final applyLocal = _appointmentLocalWins(
        clientUpdatedAt: clientUpdatedAt,
        serverUpdatedAt: serverUpdatedAt,
      );
      return SyncConflictResult(
        resolution: applyLocal
            ? SyncConflictResolution.appliedLocal
            : SyncConflictResolution.appliedServer,
        entityType: entityType,
        entityId: entityId,
        serverUpdatedAt: serverUpdatedAt,
        clientUpdatedAt: clientUpdatedAt,
      );
    }

    if (entityType.usesLastWriteWins) {
      final applyLocal = _lastWriteWinsLocal(
        clientUpdatedAt: clientUpdatedAt,
        serverUpdatedAt: serverUpdatedAt,
      );
      return SyncConflictResult(
        resolution: applyLocal
            ? SyncConflictResolution.appliedLocal
            : SyncConflictResolution.appliedServer,
        entityType: entityType,
        entityId: entityId,
        serverUpdatedAt: serverUpdatedAt,
        clientUpdatedAt: clientUpdatedAt,
      );
    }

    return SyncConflictResult(
      resolution: SyncConflictResolution.appliedLocal,
      entityType: entityType,
      entityId: entityId,
      serverUpdatedAt: serverUpdatedAt,
      clientUpdatedAt: clientUpdatedAt,
    );
  }

  /// Whether incoming server directory data should overwrite local cache.
  static bool shouldApplyServerDirectoryRecord({
    required SyncEntityType entityType,
  }) {
    return entityType.serverWinsOnConflict;
  }

  static bool _lastWriteWinsLocal({
    required DateTime? clientUpdatedAt,
    required DateTime? serverUpdatedAt,
  }) {
    if (clientUpdatedAt == null) return true;
    if (serverUpdatedAt == null) return true;
    return !clientUpdatedAt.isBefore(serverUpdatedAt);
  }

  /// Appointments: local wins only if strictly newer; equal timestamps → manual.
  static bool _appointmentLocalWins({
    required DateTime? clientUpdatedAt,
    required DateTime? serverUpdatedAt,
  }) {
    if (clientUpdatedAt == null) return false;
    if (serverUpdatedAt == null) return true;
    return clientUpdatedAt.isAfter(serverUpdatedAt);
  }

  static bool _appointmentRequiresManual({
    required DateTime? clientUpdatedAt,
    required DateTime? serverUpdatedAt,
  }) {
    if (clientUpdatedAt == null || serverUpdatedAt == null) return false;
    return clientUpdatedAt.isAtSameMomentAs(serverUpdatedAt);
  }
}
