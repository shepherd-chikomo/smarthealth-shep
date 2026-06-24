import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/data/sync/sync_engine.dart';
import 'package:my_practice/data/sync/sync_state.dart';

final syncNotifierProvider =
    NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);

class SyncNotifier extends Notifier<SyncState> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  SyncState build() {
    ref.onDispose(() => _connectivitySub?.cancel());

    ref.listen<String?>(facilityIdProvider, (prev, next) {
      if (next != null && next != prev && _syncEnabled) {
        Future.microtask(() => syncNow());
      }
    });

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && _syncEnabled && ref.read(facilityIdProvider) != null) {
        Future.microtask(() => syncNow());
      } else if (!online) {
        state = state.copyWith(phase: SyncPhase.offline);
      }
    });

    Future.microtask(_refreshPendingCount);
    return const SyncState.initial();
  }

  bool get _syncEnabled => !MyPracticeConfig.skipAuthForTesting;

  SyncEngine? get _engine => ref.read(syncEngineProvider);

  Future<void> _refreshPendingCount() async {
    final db = ref.read(appDatabaseProvider);
    final count = await db.select(db.syncQueue).get();
    state = state.copyWith(pendingMutations: count.length);
  }

  Future<void> syncNow() async {
    if (!_syncEnabled) {
      state = state.copyWith(
        phase: SyncPhase.idle,
        errorMessage: 'Simulated (dev auth bypass)',
        clearError: false,
      );
      return;
    }

    final facilityId = ref.read(facilityIdProvider);
    final engine = _engine;
    if (facilityId == null || engine == null) return;

    if (!(await engine.isOnline)) {
      state = state.copyWith(phase: SyncPhase.offline);
      await _refreshPendingCount();
      return;
    }

    state = state.copyWith(phase: SyncPhase.syncing, clearError: true);
    try {
      await engine.syncAll(facilityId);
      await ref.read(patientRepositoryProvider).hydrateMissingQueuePatients();
      await _refreshPendingCount();
      state = state.copyWith(
        phase: SyncPhase.idle,
        lastSyncedAt: DateTime.now().toUtc(),
        clearError: true,
      );
    } catch (e) {
      await _refreshPendingCount();
      state = state.copyWith(
        phase: SyncPhase.error,
        errorMessage: e.toString(),
      );
    }
  }
}
