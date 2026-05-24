import 'dart:async';
import 'dart:developer' as developer;

import 'package:background_fetch/background_fetch.dart' as bg_fetch;
import 'package:flutter/foundation.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_backoff.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_background_entrypoint.dart';
import 'package:workmanager/workmanager.dart' as wm;

const _logName = 'BackgroundSyncService';
const _androidTaskName = 'smarthealthBackgroundSync';
const _androidUniqueName = 'smarthealth_sync_periodic';

/// Registers platform background sync and exposes retry interval policy.
abstract final class BackgroundSyncService {
  static Duration get retryInterval => SyncBackoff.retryInterval;

  static Future<void> register() async {
    if (kIsWeb) return;

    await _registerWorkManager();
    await _registerBackgroundFetch();
  }

  static Future<void> _registerWorkManager() async {
    try {
      await wm.Workmanager().initialize(syncCallbackDispatcher);

      await wm.Workmanager().registerPeriodicTask(
        _androidUniqueName,
        _androidTaskName,
        frequency: retryInterval,
        existingWorkPolicy: wm.ExistingPeriodicWorkPolicy.update,
        constraints: wm.Constraints(
          networkType: wm.NetworkType.connected,
        ),
      );

      developer.log(
        'WorkManager sync registered (${retryInterval.inMinutes}m)',
        name: _logName,
      );
    } catch (error, stackTrace) {
      developer.log(
        'WorkManager registration failed',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> _registerBackgroundFetch() async {
    try {
      await bg_fetch.BackgroundFetch.configure(
        bg_fetch.BackgroundFetchConfig(
          minimumFetchInterval: retryInterval.inMinutes,
          stopOnTerminate: false,
          enableHeadless: true,
          startOnBoot: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
          requiredNetworkType: bg_fetch.NetworkType.ANY,
        ),
        _onBackgroundFetch,
        _onBackgroundFetchTimeout,
      );

      developer.log(
        'Background Fetch registered (${retryInterval.inMinutes}m)',
        name: _logName,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Background Fetch registration failed',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void _onBackgroundFetch(String taskId) {
    developer.log('Background Fetch: $taskId', name: _logName);
    unawaited(_run(taskId));
  }

  static void _onBackgroundFetchTimeout(String taskId) {
    bg_fetch.BackgroundFetch.finish(taskId);
  }

  static Future<void> _run(String taskId) async {
    try {
      await runBackgroundSyncEntrypoint();
    } finally {
      bg_fetch.BackgroundFetch.finish(taskId);
    }
  }
}
