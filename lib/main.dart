import 'dart:async';
import 'dart:developer' as developer;

import 'package:background_fetch/background_fetch.dart' as bg_fetch;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/app.dart';
import 'package:smarthealth_shep/core/directory/directory_search_service.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_repository.dart';
import 'package:smarthealth_shep/features/medications/services/medication_reminder_service.dart';
import 'package:smarthealth_shep/core/storage/hive_init.dart';
import 'package:smarthealth_shep/core/storage/sqlite_init.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_background_entrypoint.dart';

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(bg_fetch.HeadlessEvent event) async {
  if (event.timeout) {
    bg_fetch.BackgroundFetch.finish(event.taskId);
    return;
  }
  await runBackgroundSyncEntrypoint();
  bg_fetch.BackgroundFetch.finish(event.taskId);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    developer.log(
      details.exceptionAsString(),
      name: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log(
      error.toString(),
      name: 'UncaughtError',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  await initHive();
  await initSqlite();
  await MedicationReminderService.instance.initialize();
  await HealthVaultRepository().migrateLegacyFamilyPhiIfNeeded();
  await DirectorySearchService().rebuildIndex();
  bg_fetch.BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  runApp(
    const ProviderScope(
      child: SmartHealthApp(),
    ),
  );
}
