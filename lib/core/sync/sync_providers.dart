import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/shared/data/sync/optimistic_update_store.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_hive_dao.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_recovery_service.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_service.dart';

final syncQueueStorageProvider = Provider((ref) => SyncQueueHiveDao());

final optimisticUpdateStoreProvider =
    Provider((ref) => OptimisticUpdateStore());

final syncServiceProvider = Provider<SyncService>((ref) {
  final dio = ref.watch(dioProvider);
  return SyncService(
    dio: dio,
    queueStorage: ref.watch(syncQueueStorageProvider),
    optimisticStore: ref.watch(optimisticUpdateStoreProvider),
  );
});

final syncRecoveryServiceProvider = Provider<SyncRecoveryService>((ref) {
  return SyncRecoveryService(
    syncService: ref.watch(syncServiceProvider),
    queueStorage: ref.watch(syncQueueStorageProvider),
  );
});
