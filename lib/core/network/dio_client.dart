import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/auth/auth_interceptor.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/network/cache_config.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';

final dioProvider = Provider<Dio>((ref) {
  final store = ref.watch(cacheStoreProvider);
  final storage = ref.watch(secureStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(AuthInterceptor(storage, dio));
  dio.interceptors.add(
    DioCacheInterceptor(options: defaultCacheOptions(store: store)),
  );
  return dio;
});
