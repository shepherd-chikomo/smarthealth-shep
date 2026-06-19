enum SyncPhase { idle, syncing, offline, error }

class SyncState {
  const SyncState({
    required this.phase,
    this.lastSyncedAt,
    this.pendingMutations = 0,
    this.errorMessage,
  });

  const SyncState.initial()
      : phase = SyncPhase.idle,
        lastSyncedAt = null,
        pendingMutations = 0,
        errorMessage = null;

  final SyncPhase phase;
  final DateTime? lastSyncedAt;
  final int pendingMutations;
  final String? errorMessage;

  bool get isSyncing => phase == SyncPhase.syncing;

  SyncState copyWith({
    SyncPhase? phase,
    DateTime? lastSyncedAt,
    int? pendingMutations,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SyncState(
      phase: phase ?? this.phase,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      pendingMutations: pendingMutations ?? this.pendingMutations,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
