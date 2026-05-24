import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;

/// Hive box names used across the app.
abstract final class HiveBoxes {
  static const String providers = 'providers';
  static const String categories = 'categories';
  static const String emergency = 'emergency';
  static const String homeDashboard = 'home_dashboard';
  static const String syncQueue = 'sync_queue';
  static const String facilities = 'facilities';
  static const String operatingHours = 'operating_hours';

  /// Directory name for Dio HTTP cache (managed by [HiveCacheStore], not a Hive box).
  static const String httpCacheDir = 'dio_http_cache';
}

final cacheStoreProvider = Provider<CacheStore>((ref) {
  // Hive boxes live under the app documents directory set by initFlutter().
  final boxPath = Hive.box(HiveBoxes.providers).path ?? '';
  final baseDir = p.dirname(boxPath);
  return HiveCacheStore(p.join(baseDir, HiveBoxes.httpCacheDir));
});
