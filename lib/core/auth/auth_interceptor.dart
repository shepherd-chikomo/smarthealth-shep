import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/auth/secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._dio);

  final SecureStorage _storage;
  final Dio _dio;
  bool _refreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 || _refreshing) {
      return handler.next(err);
    }

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      await _storage.clearTokens();
      return handler.next(err);
    }

    _refreshing = true;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );
      final accessToken = response.data?['accessToken'] as String?;
      final newRefresh = response.data?['refreshToken'] as String?;
      if (accessToken == null || newRefresh == null) {
        await _storage.clearTokens();
        return handler.next(err);
      }
      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefresh,
      );
      err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';
      final retry = await _dio.fetch<dynamic>(err.requestOptions);
      return handler.resolve(retry);
    } catch (_) {
      await _storage.clearTokens();
      return handler.next(err);
    } finally {
      _refreshing = false;
    }
  }
}
