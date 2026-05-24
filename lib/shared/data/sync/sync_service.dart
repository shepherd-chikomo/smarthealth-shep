import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/exceptions/network_exception.dart';
import 'package:smarthealth_shep/shared/data/sync/delta_sync_coordinator.dart';
import 'package:smarthealth_shep/shared/data/sync/optimistic_update_store.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_backoff.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_conflict_resolver.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_executor.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_hive_dao.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_storage.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_recovery_service.dart';

const _logName = 'SyncService';

/// Orchestrates offline mutation queue processing and delta sync pulls.
class SyncService {
  SyncService({
    required Dio dio,
    SyncQueueStorage? queueStorage,
    SyncExecutor? executor,
    DeltaSyncCoordinator? deltaCoordinator,
    OptimisticUpdateStore? optimisticStore,
    Connectivity? connectivity,
  })  : _queueDao = queueStorage ?? SyncQueueHiveDao(),
        _executor = executor ??
            SyncExecutor(
              dio: dio,
              deltaCoordinator: deltaCoordinator,
            ),
        _delta = deltaCoordinator ?? DeltaSyncCoordinator(dio: dio),
        _optimistic = optimisticStore ?? OptimisticUpdateStore(),
        _connectivity = connectivity ?? Connectivity();

  final SyncQueueStorage _queueDao;
  final SyncExecutor _executor;
  final DeltaSyncCoordinator _delta;
  final OptimisticUpdateStore _optimistic;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _wasOffline = false;
  bool _syncInFlight = false;

  static SyncService? _instance;

  SyncQueueStorage get queueStorage => _queueDao;

  static SyncService? get instance => _instance;

  static void register(SyncService service) {
    _instance = service;
  }

  static SyncService forBackground() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    return SyncService(dio: dio);
  }

  Future<void> initialize() async {
    register(this);
    final recovery = SyncRecoveryService(syncService: this);
    await recovery.recoverStaleProcessingItems();

    _connectivitySub?.cancel();
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

    final online = await isOnline();
    _wasOffline = !online;
  }

  void dispose() {
    _connectivitySub?.cancel();
  }

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Enqueues a user mutation with optimistic local update tracking.
  Future<void> enqueue({
    required SyncMutationType mutationType,
    required SyncEntityType entityType,
    required String entityId,
    required Map<String, dynamic> payload,
    DateTime? clientUpdatedAt,
    bool optimistic = true,
  }) async {
    final updatedAt = clientUpdatedAt ?? DateTime.now().toUtc();

    if (optimistic) {
      await _optimistic.record(
        entityType: entityType,
        entityId: entityId,
        payload: payload,
        clientUpdatedAt: updatedAt,
      );
    }

    final item = SyncQueueItem(
      id: '${entityType.name}_${entityId}_${DateTime.now().microsecondsSinceEpoch}',
      mutationType: mutationType,
      entityType: entityType,
      entityId: entityId,
      payload: payload,
      retryCount: 0,
      status: SyncQueueStatus.pending,
      createdAt: DateTime.now().toUtc(),
      clientUpdatedAt: updatedAt,
      optimistic: optimistic,
    );

    await _queueDao.enqueue(item);
    developer.log(
      'Enqueued ${mutationType.label} ${entityType.name}/$entityId',
      name: _logName,
    );

    if (await isOnline()) {
      unawaited(syncNow(trigger: SyncTrigger.queueMutation));
    }
  }

  Future<SyncRunResult> syncPullToRefresh() {
    return syncNow(trigger: SyncTrigger.pullToRefresh);
  }

  Future<SyncRunResult> runBackgroundSync() {
    return syncNow(trigger: SyncTrigger.background);
  }

  Future<SyncRunResult> syncNow({SyncTrigger trigger = SyncTrigger.manual}) async {
    if (_syncInFlight) {
      developer.log('Sync already in flight — skipping', name: _logName);
      return const SyncRunResult.idle();
    }

    if (!await isOnline()) {
      developer.log('Sync skipped — offline ($trigger)', name: _logName);
      return const SyncRunResult(
        processed: 0,
        succeeded: 0,
        failed: 0,
        skippedOffline: true,
        needsManualRetry: 0,
      );
    }

    _syncInFlight = true;
    developer.log('Sync started ($trigger)', name: _logName);

    var processed = 0;
    var succeeded = 0;
    var failed = 0;
    var conflicts = 0;
    var needsManualRetry = 0;

    try {
      await _delta.runDeltaPulls();

      final items = await _queueDao.getRunnableItems();
      for (final item in items) {
        processed++;
        final outcome = await _processItem(item);
        switch (outcome) {
          case _ProcessOutcome.success:
            succeeded++;
          case _ProcessOutcome.failed:
            failed++;
          case _ProcessOutcome.conflict:
            conflicts++;
            failed++;
        }
      }

      await _queueDao.deleteCompleted();

      final manual = await _queueDao.getManualRetryItems();
      needsManualRetry = manual.length;

      developer.log(
        'Sync finished ($trigger): processed=$processed succeeded=$succeeded '
        'failed=$failed conflicts=$conflicts manualRetry=$needsManualRetry',
        name: _logName,
      );

      return SyncRunResult(
        processed: processed,
        succeeded: succeeded,
        failed: failed,
        skippedOffline: false,
        needsManualRetry: needsManualRetry,
        conflicts: conflicts,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Sync run failed',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return SyncRunResult(
        processed: processed,
        succeeded: succeeded,
        failed: failed + 1,
        skippedOffline: false,
        needsManualRetry: needsManualRetry,
        conflicts: conflicts,
      );
    } finally {
      _syncInFlight = false;
    }
  }

  Future<List<SyncQueueItem>> pendingItems() => _queueDao.getRunnableItems();

  Future<List<SyncQueueItem>> manualRetryItems() =>
      _queueDao.getManualRetryItems();

  Future<int> pendingCount() => _queueDao.countPending();

  Future<SyncRunResult> retryManualItems() async {
    await _queueDao.resetManualRetryItems();
    return syncNow(trigger: SyncTrigger.manualRetry);
  }

  void schedule(String key, Future<void> Function() task) {
    unawaited(_runLegacyTask(key, task));
  }

  Future<void> _runLegacyTask(String key, Future<void> Function() task) async {
    try {
      developer.log('Legacy scheduled task started', name: key);
      await task();
      developer.log('Legacy scheduled task completed', name: key);
    } catch (error, stackTrace) {
      developer.log(
        'Legacy scheduled task failed',
        name: key,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<_ProcessOutcome> _processItem(SyncQueueItem item) async {
    await _queueDao.markProcessing(item.id);

    try {
      final serverBody = await _executor.processQueueItem(item);

      if (serverBody != null) {
        final conflict = SyncConflictResolver.resolve(
          entityType: item.entityType,
          entityId: item.entityId,
          clientUpdatedAt: item.clientUpdatedAt,
          serverUpdatedAt: _parseUpdatedAt(serverBody),
          serverModifiedWhilePending:
              serverBody['conflict'] == true,
        );

        if (conflict.requiresManual) {
          await _queueDao.updateItem(
            item.copyWith(
              status: SyncQueueStatus.needsManualConflict,
              lastError: conflict.message,
            ),
          );
          return _ProcessOutcome.conflict;
        }

        if (conflict.resolution == SyncConflictResolution.appliedServer) {
          developer.log(
            'Server wins for ${item.entityType.name}/${item.entityId}',
            name: _logName,
          );
        }
      }

      await _queueDao.markCompleted(item.id);
      if (item.optimistic) {
        await _optimistic.clear(
          entityType: item.entityType,
          entityId: item.entityId,
        );
      }
      return _ProcessOutcome.success;
    } on NetworkException catch (error, stackTrace) {
      return _handleFailure(item, error.message, stackTrace);
    } on DioException catch (error, stackTrace) {
      final message = error.message ?? 'HTTP ${error.response?.statusCode}';
      return _handleFailure(item, message, stackTrace);
    } catch (error, stackTrace) {
      return _handleFailure(item, error.toString(), stackTrace);
    }
  }

  Future<_ProcessOutcome> _handleFailure(
    SyncQueueItem item,
    String message,
    StackTrace stackTrace,
  ) async {
    final nextRetry = item.retryCount + 1;
    developer.log(
      'Queue item failed (${item.id}): $message',
      name: _logName,
      error: message,
      stackTrace: stackTrace,
    );

    if (SyncBackoff.exceededMaxRetries(nextRetry)) {
      await _queueDao.updateItem(
        item.copyWith(
          retryCount: nextRetry,
          status: SyncQueueStatus.needsManualRetry,
          lastError: message,
          nextRetryAt: null,
        ),
      );
      return _ProcessOutcome.failed;
    }

    await _queueDao.updateItem(
      item.copyWith(
        retryCount: nextRetry,
        status: SyncQueueStatus.failed,
        lastError: message,
        nextRetryAt: SyncBackoff.nextRetryTime(nextRetry),
      ),
    );
    return _ProcessOutcome.failed;
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online && _wasOffline) {
      developer.log('Network restored — triggering sync', name: _logName);
      unawaited(syncNow(trigger: SyncTrigger.networkRestored));
    }
    _wasOffline = !online;
  }

  DateTime? _parseUpdatedAt(Map<String, dynamic> body) {
    final raw = body['updatedAt'] ?? body['updated_at'];
    if (raw is String) return DateTime.tryParse(raw)?.toUtc();
    return null;
  }
}

enum _ProcessOutcome { success, failed, conflict }

enum SyncTrigger {
  appLaunch,
  pullToRefresh,
  background,
  networkRestored,
  queueMutation,
  manual,
  manualRetry,
}
