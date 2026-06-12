import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_core/src/auth/auth_interceptor.dart';
import 'package:smarthealth_core/src/auth/secure_storage.dart';
import 'package:smarthealth_core/src/network/dio_factory.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final dioProvider = Provider<Dio>((ref) {
  final dio = createApiDio();
  dio.interceptors.add(
    AuthInterceptor(ref.watch(secureStorageProvider), dio),
  );
  return dio;
});
