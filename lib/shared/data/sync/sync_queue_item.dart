import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Mutation operation stored in the offline sync queue.
enum SyncMutationType {
  create,
  update,
  delete,
}

/// Entity targeted by a queued sync operation.
enum SyncEntityType {
  emergency,
  provider,
  appointment,
  family,
}

/// Lifecycle state of a [SyncQueueItem].
enum SyncQueueStatus {
  pending,
  processing,
  failed,
  needsManualRetry,
  completed,
}

extension SyncEntityTypeX on SyncEntityType {
  /// Lower value = higher sync priority.
  int get priority => switch (this) {
        SyncEntityType.emergency => 0,
        SyncEntityType.provider => 1,
        SyncEntityType.appointment => 2,
        SyncEntityType.family => 3,
      };

  String get apiPath => switch (this) {
        SyncEntityType.emergency => 'emergency',
        SyncEntityType.provider => 'providers',
        SyncEntityType.appointment => 'appointments',
        SyncEntityType.family => 'family',
      };

  /// Directory/catalog data — server wins on conflict.
  bool get serverWinsOnConflict => switch (this) {
        SyncEntityType.emergency => true,
        SyncEntityType.provider => true,
        SyncEntityType.appointment => false,
        SyncEntityType.family => false,
      };
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

  bool get requiresManualRetry => status == SyncQueueStatus.needsManualRetry;

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
    );
  }

  Map<String, dynamic> toRow() {
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
    };
  }

  factory SyncQueueItem.fromRow(Map<String, Object?> row) {
    return SyncQueueItem(
      id: row['id']! as String,
      mutationType: SyncMutationType.values.byName(
        row['mutation_type']! as String,
      ),
      entityType: SyncEntityType.values.byName(row['entity_type']! as String),
      entityId: row['entity_id']! as String,
      payload: jsonDecode(row['payload_json']! as String) as Map<String, dynamic>,
      retryCount: row['retry_count']! as int,
      status: SyncQueueStatus.values.byName(row['status']! as String),
      createdAt: DateTime.parse(row['created_at']! as String),
      nextRetryAt: row['next_retry_at'] != null
          ? DateTime.parse(row['next_retry_at']! as String)
          : null,
      lastError: row['last_error'] as String?,
      clientUpdatedAt: row['client_updated_at'] != null
          ? DateTime.parse(row['client_updated_at']! as String)
          : null,
    );
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
  });

  const SyncRunResult.idle()
      : processed = 0,
        succeeded = 0,
        failed = 0,
        skippedOffline = false,
        needsManualRetry = 0;

  final int processed;
  final int succeeded;
  final int failed;
  final bool skippedOffline;
  final int needsManualRetry;

  @override
  List<Object?> get props =>
      [processed, succeeded, failed, skippedOffline, needsManualRetry];
}
