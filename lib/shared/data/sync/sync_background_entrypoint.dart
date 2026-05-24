import 'package:smarthealth_shep/core/storage/hive_init.dart';
import 'package:smarthealth_shep/core/storage/sqlite_init.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_service.dart';
import 'package:workmanager/workmanager.dart';

/// WorkManager callback dispatcher — must be a top-level function.
@pragma('vm:entry-point')
void syncCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await runBackgroundSyncEntrypoint();
    return true;
  });
}

/// Shared background sync body for WorkManager and Background Fetch.
Future<void> runBackgroundSyncEntrypoint() async {
  await initHive();
  await initSqlite();
  final service = SyncService.instance ?? SyncService.forBackground();
  await service.runBackgroundSync();
}
