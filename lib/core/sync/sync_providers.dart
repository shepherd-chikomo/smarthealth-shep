import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final dio = ref.watch(dioProvider);
  return SyncService(dio: dio);
});
