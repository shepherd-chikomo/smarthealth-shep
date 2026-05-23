import 'dart:async';
import 'dart:developer' as developer;

import 'package:background_fetch/background_fetch.dart' as bg_fetch;
import 'package:flutter/foundation.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_background_entrypoint.dart';
import 'package:workmanager/workmanager.dart' as wm;

const _logName = 'BackgroundSyncScheduler';
const _androidTaskName = 'smarthealthBackgroundSync';
const _androidUniqueName = 'smarthealth_sync_periodic';

/// Registers WorkManager (Android) and Background Fetch (iOS) periodic sync.
abstract final class BackgroundSyncScheduler {
  static const periodicInterval = Duration(hours: 6);

  static Future<void> register() async {
    if (kIsWeb) return;

    await _registerWorkManager();
    await _registerBackgroundFetch();
  }

  static Future<void> _registerWorkManager() async {
    try {
      await wm.Workmanager().initialize(
        syncCallbackDispatcher,
      );

      await wm.Workmanager().registerPeriodicTask(
        _androidUniqueName,
        _androidTaskName,
        frequency: periodicInterval,
        existingWorkPolicy: wm.ExistingPeriodicWorkPolicy.keep,
        constraints: wm.Constraints(
          networkType: wm.NetworkType.connected,
        ),
      );

      developer.log(
        'WorkManager periodic sync registered (${periodicInterval.inHours}h)',
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
          minimumFetchInterval: periodicInterval.inMinutes,
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
        'Background Fetch registered (${periodicInterval.inHours}h)',
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
    developer.log('Background Fetch event: $taskId', name: _logName);
    unawaited(_runBackgroundSync(taskId));
  }

  static void _onBackgroundFetchTimeout(String taskId) {
    developer.log('Background Fetch timeout: $taskId', name: _logName);
    bg_fetch.BackgroundFetch.finish(taskId);
  }

  static Future<void> _runBackgroundSync(String taskId) async {
    try {
      await runBackgroundSyncEntrypoint();
    } finally {
      bg_fetch.BackgroundFetch.finish(taskId);
    }
  }
}
