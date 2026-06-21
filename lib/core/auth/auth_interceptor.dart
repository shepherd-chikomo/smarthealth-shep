import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/auth/secure_storage.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._dio)
      : _refreshDio = createApiDio();

  final SecureStorage _storage;
  final Dio _dio;
  final Dio _refreshDio;
  Future<String?>? _refreshFuture;

  static bool _isTokenFreeRoute(String path) {
    return path.contains('/auth/refresh') || path.contains('/auth/logout');
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isTokenFreeRoute(options.path)) {
      options.headers.remove('Authorization');
      return handler.next(options);
    }

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
    if (err.response?.statusCode != 401 ||
        _isTokenFreeRoute(err.requestOptions.path)) {
      return handler.next(err);
    }

    try {
      final accessToken = await _refreshAccessToken();
      if (accessToken == null) {
        return handler.next(err);
      }
      err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';
      final retry = await _dio.fetch<dynamic>(err.requestOptions);
      return handler.resolve(retry);
    } catch (_) {
      return handler.next(err);
    }
  }

  Future<String?> _refreshAccessToken() async {
    if (_refreshFuture != null) {
      return _refreshFuture;
    }

    _refreshFuture = _performRefresh();
    try {
      return await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      await _storage.clearTokens();
      return null;
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final accessToken = response.data?['accessToken'] as String?;
      final newRefresh = response.data?['refreshToken'] as String?;
      if (accessToken == null || newRefresh == null) {
        await _storage.clearTokens();
        return null;
      }
      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefresh,
      );
      return accessToken;
    } catch (_) {
      await _storage.clearTokens();
      return null;
    }
  }
}
