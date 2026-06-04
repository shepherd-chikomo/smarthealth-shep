import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/exceptions/network_exception.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/shared/data/local/facility_cache.dart';
import 'package:smarthealth_shep/shared/models/facilities_query_result.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';

const _logName = 'FacilityRepository';

final facilityRepositoryProvider = Provider<FacilityRepository>((ref) {
  return FacilityRepository(api: ApiService(ref.watch(dioProvider)));
});

/// Offline-first healthcare facility directory backed by Hive cache and API.
class FacilityRepository {
  FacilityRepository({
    required ApiService api,
    FacilityCache? cache,
  })  : _api = api,
        _cache = cache ?? FacilityCache();

  factory FacilityRepository.defaults() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    return FacilityRepository(api: ApiService(dio));
  }

  final ApiService _api;
  final FacilityCache _cache;

  Future<FacilitiesQueryResult> getNearbyFacilities({
    required double lat,
    required double lon,
    required double radiusKm,
    int limit = 50,
    String? facilityType,
  }) async {
    try {
      developer.log(
        'GET /facilities/nearby (base=${AppConfig.apiBaseUrl}, type=$facilityType)',
        name: _logName,
      );
      final remote = await _api.fetchNearbyFacilities(
        lat: lat,
        lon: lon,
        radiusKm: radiusKm,
        limit: limit,
        facilityType: facilityType,
      );
      if (remote.isNotEmpty) {
        await _cache.saveAll(
          remote.map((f) => f.toJson()).toList(),
        );
      }
      return FacilitiesQueryResult(facilities: remote, isOffline: false);
    } catch (error, stackTrace) {
      developer.log(
        'Facility API failed: $error',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );

      final local = _readCached();
      if (local.isNotEmpty) {
        return FacilitiesQueryResult(facilities: local, isOffline: true);
      }

      if (error is NetworkException) {
        throw error;
      }
      if (error is DioException) {
        throw NetworkException(
          error.message ?? 'Network request failed',
          cause: error,
        );
      }
      throw NetworkException(error.toString(), cause: error);
    }
  }

  Future<FacilityModel?> getById(String id) async {
    try {
      return await _api.getFacilityById(id);
    } catch (error) {
      final cached = _cache.getById(id);
      if (cached == null) return null;
      return FacilityModel.fromJson(cached);
    }
  }

  List<FacilityModel> _readCached() {
    final all = _cache.readAll().map(FacilityModel.fromJson).toList();
    all.sort(
      (a, b) => (a.distanceKm ?? double.infinity)
          .compareTo(b.distanceKm ?? double.infinity),
    );
    return all;
  }
}
