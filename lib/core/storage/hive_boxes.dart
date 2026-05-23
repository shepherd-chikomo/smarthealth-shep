import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive box names used across the app.
abstract final class HiveBoxes {
  static const String providers = 'providers';
  static const String categories = 'categories';
  static const String emergency = 'emergency';
  static const String httpCache = 'http_cache';
}

final cacheStoreProvider = Provider<CacheStore>((ref) {
  return HiveCacheStore(Hive.box(HiveBoxes.httpCache).path);
});
