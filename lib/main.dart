import 'package:background_fetch/background_fetch.dart' as bg_fetch;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/app.dart';
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
  await initHive();
  await initSqlite();
  bg_fetch.BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  runApp(
    const ProviderScope(
      child: SmartHealthApp(),
    ),
  );
}
