import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';

/// Riverpod-facing sync engine state.
class SyncManagerState extends Equatable {
  const SyncManagerState({
    this.isSyncing = false,
    this.isOnline = true,
    this.pendingCount = 0,
    this.manualRetryCount = 0,
    this.conflictCount = 0,
    this.lastSyncAt,
    this.lastResult = const SyncRunResult.idle(),
    this.lastError,
    this.manualConflicts = const [],
  });

  final bool isSyncing;
  final bool isOnline;
  final int pendingCount;
  final int manualRetryCount;
  final int conflictCount;
  final DateTime? lastSyncAt;
  final SyncRunResult lastResult;
  final String? lastError;
  final List<SyncQueueItem> manualConflicts;

  bool get hasPendingWork => pendingCount > 0;
  bool get needsAttention => manualRetryCount > 0 || conflictCount > 0;

  SyncManagerState copyWith({
    bool? isSyncing,
    bool? isOnline,
    int? pendingCount,
    int? manualRetryCount,
    int? conflictCount,
    DateTime? lastSyncAt,
    SyncRunResult? lastResult,
    String? lastError,
    List<SyncQueueItem>? manualConflicts,
    bool clearError = false,
  }) {
    return SyncManagerState(
      isSyncing: isSyncing ?? this.isSyncing,
      isOnline: isOnline ?? this.isOnline,
      pendingCount: pendingCount ?? this.pendingCount,
      manualRetryCount: manualRetryCount ?? this.manualRetryCount,
      conflictCount: conflictCount ?? this.conflictCount,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastResult: lastResult ?? this.lastResult,
      lastError: clearError ? null : (lastError ?? this.lastError),
      manualConflicts: manualConflicts ?? this.manualConflicts,
    );
  }

  @override
  List<Object?> get props => [
        isSyncing,
        isOnline,
        pendingCount,
        manualRetryCount,
        conflictCount,
        lastSyncAt,
        lastResult,
        lastError,
        manualConflicts,
      ];
}
