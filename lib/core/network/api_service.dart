import 'package:dio/dio.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/exceptions/network_exception.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/models/provider_search_filter.dart';

/// Delta sync payload from the providers API.
class ProviderSyncPayload {
  const ProviderSyncPayload({
    required this.updated,
    required this.deletedIds,
    required this.syncedAt,
  });

  final List<ProviderModel> updated;
  final List<String> deletedIds;
  final DateTime syncedAt;
}

/// Remote provider API backed by Dio.
class ApiService {
  ApiService(this._dio, {String? baseUrl})
      : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final Dio _dio;
  final String baseUrl;

  Future<List<ProviderModel>> fetchNearbyProviders({
    required double lat,
    required double lon,
    required double radiusKm,
    DateTime? since,
  }) async {
    final response = await _get<Map<String, dynamic>>(
      '/providers/nearby',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'radiusKm': radiusKm,
        if (since != null) 'since': since.toUtc().toIso8601String(),
      },
    );

    return _parseProviderList(response.data?['providers']);
  }

  Future<List<ProviderModel>> searchProviders(
    ProviderSearchFilter filter,
  ) async {
    final response = await _get<Map<String, dynamic>>(
      '/search/providers',
      queryParameters: {
        if (filter.query.isNotEmpty) 'q': filter.query,
        if (filter.categoryId != null) 'categoryId': filter.categoryId,
        if (filter.specialtyId != null) 'specialtyId': filter.specialtyId,
        if (filter.specialties.isNotEmpty)
          'specialties': filter.specialties.join(','),
        if (filter.conditions.isNotEmpty)
          'conditions': filter.conditions.join(','),
        if (filter.ageGroups.isNotEmpty)
          'ageGroups': filter.ageGroups.join(','),
        if (filter.latitude != null) 'lat': filter.latitude,
        if (filter.longitude != null) 'lon': filter.longitude,
        if (filter.radiusKm != null) 'radiusKm': filter.radiusKm,
        if (filter.isVerified == true) 'isVerified': true,
        if (filter.openNow == true) 'openNow': true,
        if (filter.queueUnder30 == true) 'queueUnder30': true,
        if (filter.availableToday == true) 'availableToday': true,
        if (filter.acceptsWalkIns == true) 'acceptsWalkIns': true,
        if (filter.emergencyAvailable == true) 'emergencyAvailable': true,
        if (filter.city != null) 'city': filter.city,
        if (filter.province != null) 'province': filter.province,
        if (filter.facilityId != null) 'facilityId': filter.facilityId,
        'limit': 50,
      },
    );

    return _parseProviderList(response.data?['providers']);
  }

  Future<ProviderModel?> getProviderById(String id) async {
    final response = await _get<Map<String, dynamic>>(
      '/providers/$id',
    );

    final data = response.data?['provider'];
    if (data is! Map<String, dynamic>) return null;
    return ProviderModel.fromJson(data);
  }

  Future<ProviderSyncPayload> syncProviders({DateTime? since}) async {
    final response = await _get<Map<String, dynamic>>(
      '/providers/sync',
      queryParameters: {
        if (since != null) 'since': since.toUtc().toIso8601String(),
      },
    );

    final data = response.data ?? const <String, dynamic>{};
    final syncedAtRaw = data['syncedAt'] as String?;
    final syncedAt = syncedAtRaw != null
        ? DateTime.parse(syncedAtRaw).toUtc()
        : DateTime.now().toUtc();

    return ProviderSyncPayload(
      updated: _parseProviderList(data['updated']),
      deletedIds: (data['deletedIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      syncedAt: syncedAt,
    );
  }

  Future<Response<T>> _get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Exception _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(
          error.message ?? 'Network request failed',
          cause: error,
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        if (status != null && status >= 500) {
          return NetworkException(
            'Server unavailable ($status)',
            cause: error,
          );
        }
        return error;
      default:
        if (error.error is NetworkException) {
          return error.error as NetworkException;
        }
        return error;
    }
  }

  List<ProviderModel> _parseProviderList(Object? raw) {
    if (raw is! List<dynamic>) return const [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(ProviderModel.fromJson)
        .toList();
  }
}
