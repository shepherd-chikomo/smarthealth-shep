import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:smarthealth_shep/core/exceptions/network_exception.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_backoff.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_executor.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_dao.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';

const _logName = 'SyncService';

/// Orchestrates offline mutation queue processing and delta sync pulls.
class SyncService {
  SyncService({
    required Dio dio,
    SyncQueueDao? queueDao,
    SyncExecutor? executor,
    Connectivity? connectivity,
    this.baseUrl = 'https://api.smarthealth.example/v1',
  })  : _queueDao = queueDao ?? SyncQueueDao(),
        _executor = executor ??
            SyncExecutor(dio: dio, baseUrl: baseUrl),
        _connectivity = connectivity ?? Connectivity();

  final SyncQueueDao _queueDao;
  final SyncExecutor _executor;
  final Connectivity _connectivity;

  final String baseUrl;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _wasOffline = false;
  bool _syncInFlight = false;

  static SyncService? _instance;

  /// Shared instance for background isolates and repositories.
  static SyncService? get instance => _instance;

  /// Registers the process-wide [SyncService] singleton.
  static void register(SyncService service) {
    _instance = service;
  }

  /// Builds a standalone service for background entrypoints.
  static SyncService forBackground({
    String baseUrl = 'https://api.smarthealth.example/v1',
  }) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    return SyncService(dio: dio, baseUrl: baseUrl);
  }

  /// Initializes listeners — call once on app launch.
  Future<void> initialize() async {
    register(this);
    _connectivitySub?.cancel();
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

    final online = await isOnline();
    _wasOffline = !online;
    if (online) {
      unawaited(syncNow(trigger: SyncTrigger.appLaunch));
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
  }

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Enqueues a user mutation for background upload.
  Future<void> enqueue({
    required SyncMutationType mutationType,
    required SyncEntityType entityType,
    required String entityId,
    required Map<String, dynamic> payload,
    DateTime? clientUpdatedAt,
  }) async {
    final item = SyncQueueItem(
      id: '${entityType.name}_${entityId}_${DateTime.now().microsecondsSinceEpoch}',
      mutationType: mutationType,
      entityType: entityType,
      entityId: entityId,
      payload: payload,
      retryCount: 0,
      status: SyncQueueStatus.pending,
      createdAt: DateTime.now().toUtc(),
      clientUpdatedAt: clientUpdatedAt ?? DateTime.now().toUtc(),
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

  /// Pull-to-refresh entry point.
  Future<SyncRunResult> syncPullToRefresh() {
    return syncNow(trigger: SyncTrigger.pullToRefresh);
  }

  /// Periodic / WorkManager / Background Fetch entry point.
  Future<SyncRunResult> runBackgroundSync() {
    return syncNow(trigger: SyncTrigger.background);
  }

  /// Immediate sync: delta pulls then queue processing by priority.
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
    var needsManualRetry = 0;

    try {
      await _executor.runDeltaPulls();

      final items = await _queueDao.getRunnableItems();
      for (final item in items) {
        processed++;
        final ok = await _processItem(item);
        if (ok) {
          succeeded++;
        } else {
          failed++;
        }
      }

      await _queueDao.deleteCompleted();

      final manual = await _queueDao.getManualRetryItems();
      needsManualRetry = manual.length;

      developer.log(
        'Sync finished ($trigger): processed=$processed succeeded=$succeeded '
        'failed=$failed manualRetry=$needsManualRetry',
        name: _logName,
      );

      return SyncRunResult(
        processed: processed,
        succeeded: succeeded,
        failed: failed,
        skippedOffline: false,
        needsManualRetry: needsManualRetry,
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
      );
    } finally {
      _syncInFlight = false;
    }
  }

  Future<List<SyncQueueItem>> pendingItems() => _queueDao.getRunnableItems();

  Future<List<SyncQueueItem>> manualRetryItems() =>
      _queueDao.getManualRetryItems();

  Future<int> pendingCount() => _queueDao.countPending();

  /// Re-queues all items flagged for manual retry.
  Future<SyncRunResult> retryManualItems() async {
    await _queueDao.resetManualRetryItems();
    return syncNow(trigger: SyncTrigger.manualRetry);
  }

  /// Legacy debounce helper — enqueues immediate one-shot sync work.
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

  Future<bool> _processItem(SyncQueueItem item) async {
    await _queueDao.markProcessing(item.id);

    try {
      await _executor.processQueueItem(item);
      await _queueDao.markCompleted(item.id);
      return true;
    } on NetworkException catch (error, stackTrace) {
      return _handleFailure(item, error.message, stackTrace);
    } on DioException catch (error, stackTrace) {
      final message = error.message ?? 'HTTP ${error.response?.statusCode}';
      return _handleFailure(item, message, stackTrace);
    } catch (error, stackTrace) {
      return _handleFailure(item, error.toString(), stackTrace);
    }
  }

  Future<bool> _handleFailure(
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
      return false;
    }

    await _queueDao.updateItem(
      item.copyWith(
        retryCount: nextRetry,
        status: SyncQueueStatus.failed,
        lastError: message,
        nextRetryAt: SyncBackoff.nextRetryTime(nextRetry),
      ),
    );
    return false;
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online && _wasOffline) {
      developer.log('Network restored — triggering sync', name: _logName);
      unawaited(syncNow(trigger: SyncTrigger.networkRestored));
    }
    _wasOffline = !online;
  }
}

/// What triggered a sync cycle.
enum SyncTrigger {
  appLaunch,
  pullToRefresh,
  background,
  networkRestored,
  queueMutation,
  manual,
  manualRetry,
}
