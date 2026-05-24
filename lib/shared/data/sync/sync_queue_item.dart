import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Mutation operation stored in the offline sync queue.
enum SyncMutationType {
  create,
  update,
  delete,
}

/// Entity targeted by a queued sync operation.
///
/// Priority order (lower = synced first) reflects mission-critical data for
/// low-connectivity African environments.
enum SyncEntityType {
  emergency,
  provider,
  facility,
  operatingHours,
  queueUpdate,
  appointment,
  family,
}

/// Lifecycle state of a [SyncQueueItem].
enum SyncQueueStatus {
  pending,
  processing,
  failed,
  needsManualRetry,
  needsManualConflict,
  completed,
}

/// How a sync conflict was resolved.
enum SyncConflictResolution {
  appliedLocal,
  appliedServer,
  requiresManual,
}

extension SyncEntityTypeX on SyncEntityType {
  /// Lower value = higher sync priority.
  int get priority => switch (this) {
        SyncEntityType.emergency => 0,
        SyncEntityType.provider => 1,
        SyncEntityType.facility => 2,
        SyncEntityType.operatingHours => 3,
        SyncEntityType.queueUpdate => 4,
        SyncEntityType.appointment => 5,
        SyncEntityType.family => 6,
      };

  String get apiPath => switch (this) {
        SyncEntityType.emergency => 'emergency',
        SyncEntityType.provider => 'providers',
        SyncEntityType.facility => 'facilities',
        SyncEntityType.operatingHours => 'providers',
        SyncEntityType.queueUpdate => 'appointments/queue',
        SyncEntityType.appointment => 'appointments',
        SyncEntityType.family => 'patients/family',
      };

  /// Directory/catalog data — server wins on conflict (aggressive cache).
  bool get serverWinsOnConflict => switch (this) {
        SyncEntityType.emergency => true,
        SyncEntityType.provider => true,
        SyncEntityType.facility => true,
        SyncEntityType.operatingHours => true,
        SyncEntityType.queueUpdate => false,
        SyncEntityType.appointment => false,
        SyncEntityType.family => false,
      };

  /// Last-write-wins using [updated_at] timestamps.
  bool get usesLastWriteWins => switch (this) {
        SyncEntityType.family => true,
        SyncEntityType.queueUpdate => true,
        SyncEntityType.appointment => false,
        _ => false,
      };

  /// Appointments require manual resolution when both sides changed.
  bool get requiresManualConflictResolution =>
      this == SyncEntityType.appointment;
}

extension SyncMutationTypeX on SyncMutationType {
  String get label => name.toUpperCase();
}

/// A pending user mutation waiting to be pushed to the server.
class SyncQueueItem extends Equatable {
  const SyncQueueItem({
    required this.id,
    required this.mutationType,
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.retryCount,
    required this.status,
    required this.createdAt,
    this.nextRetryAt,
    this.lastError,
    this.clientUpdatedAt,
    this.optimistic = true,
  });

  final String id;
  final SyncMutationType mutationType;
  final SyncEntityType entityType;
  final String entityId;
  final Map<String, dynamic> payload;
  final int retryCount;
  final SyncQueueStatus status;
  final DateTime createdAt;
  final DateTime? nextRetryAt;
  final String? lastError;
  final DateTime? clientUpdatedAt;

  /// Whether this item was applied optimistically to local storage.
  final bool optimistic;

  bool get requiresManualRetry =>
      status == SyncQueueStatus.needsManualRetry ||
      status == SyncQueueStatus.needsManualConflict;

  SyncQueueItem copyWith({
    SyncMutationType? mutationType,
    SyncEntityType? entityType,
    String? entityId,
    Map<String, dynamic>? payload,
    int? retryCount,
    SyncQueueStatus? status,
    DateTime? nextRetryAt,
    String? lastError,
    DateTime? clientUpdatedAt,
    bool? optimistic,
    bool clearNextRetryAt = false,
    bool clearLastError = false,
  }) {
    return SyncQueueItem(
      id: id,
      mutationType: mutationType ?? this.mutationType,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      createdAt: createdAt,
      nextRetryAt:
          clearNextRetryAt ? null : (nextRetryAt ?? this.nextRetryAt),
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
      optimistic: optimistic ?? this.optimistic,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mutation_type': mutationType.name,
      'entity_type': entityType.name,
      'entity_id': entityId,
      'payload_json': jsonEncode(payload),
      'retry_count': retryCount,
      'status': status.name,
      'created_at': createdAt.toUtc().toIso8601String(),
      'next_retry_at': nextRetryAt?.toUtc().toIso8601String(),
      'last_error': lastError,
      'client_updated_at': clientUpdatedAt?.toUtc().toIso8601String(),
      'optimistic': optimistic,
    };
  }

  Map<String, Object?> toRow() => toMap();

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id']! as String,
      mutationType: SyncMutationType.values.byName(
        map['mutation_type']! as String,
      ),
      entityType: SyncEntityType.values.byName(map['entity_type']! as String),
      entityId: map['entity_id']! as String,
      payload: jsonDecode(map['payload_json']! as String) as Map<String, dynamic>,
      retryCount: map['retry_count']! as int,
      status: SyncQueueStatus.values.byName(map['status']! as String),
      createdAt: DateTime.parse(map['created_at']! as String),
      nextRetryAt: map['next_retry_at'] != null
          ? DateTime.parse(map['next_retry_at']! as String)
          : null,
      lastError: map['last_error'] as String?,
      clientUpdatedAt: map['client_updated_at'] != null
          ? DateTime.parse(map['client_updated_at']! as String)
          : null,
      optimistic: map['optimistic'] as bool? ?? true,
    );
  }

  factory SyncQueueItem.fromRow(Map<String, Object?> row) {
    return SyncQueueItem.fromMap(Map<String, dynamic>.from(row));
  }

  @override
  List<Object?> get props => [
        id,
        mutationType,
        entityType,
        entityId,
        payload,
        retryCount,
        status,
        createdAt,
        nextRetryAt,
        lastError,
        clientUpdatedAt,
        optimistic,
      ];
}

/// Result of conflict resolution between local and server copies.
class SyncConflictResult extends Equatable {
  const SyncConflictResult({
    required this.resolution,
    required this.entityType,
    required this.entityId,
    this.serverUpdatedAt,
    this.clientUpdatedAt,
    this.message,
  });

  final SyncConflictResolution resolution;
  final SyncEntityType entityType;
  final String entityId;
  final DateTime? serverUpdatedAt;
  final DateTime? clientUpdatedAt;
  final String? message;

  bool get requiresManual =>
      resolution == SyncConflictResolution.requiresManual;

  @override
  List<Object?> get props => [
        resolution,
        entityType,
        entityId,
        serverUpdatedAt,
        clientUpdatedAt,
        message,
      ];
}

/// Summary returned after a sync run.
class SyncRunResult extends Equatable {
  const SyncRunResult({
    required this.processed,
    required this.succeeded,
    required this.failed,
    required this.skippedOffline,
    required this.needsManualRetry,
    this.conflicts = 0,
  });

  const SyncRunResult.idle()
      : processed = 0,
        succeeded = 0,
        failed = 0,
        skippedOffline = false,
        needsManualRetry = 0,
        conflicts = 0;

  final int processed;
  final int succeeded;
  final int failed;
  final bool skippedOffline;
  final int needsManualRetry;
  final int conflicts;

  @override
  List<Object?> get props =>
      [processed, succeeded, failed, skippedOffline, needsManualRetry, conflicts];
}
