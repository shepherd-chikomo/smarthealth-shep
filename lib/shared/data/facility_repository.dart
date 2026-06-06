import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/exceptions/network_exception.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/shared/data/local/facility_cache.dart';
import 'package:smarthealth_shep/shared/data/local/home_dashboard_facility_cache.dart';
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
    HomeDashboardFacilityCache? homeDashboardCache,
  })  : _api = api,
        _cache = cache ?? FacilityCache(),
        _homeDashboardCache = homeDashboardCache ?? HomeDashboardFacilityCache();

  factory FacilityRepository.defaults() {
    return FacilityRepository(api: ApiService(createApiDio()));
  }

  final ApiService _api;
  final FacilityCache _cache;
  final HomeDashboardFacilityCache _homeDashboardCache;

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

  Future<FacilitiesQueryResult> getFacilitiesByCity({
    required String city,
    String? facilityType,
    int limit = 50,
  }) async {
    try {
      developer.log(
        'GET /facilities (city=$city, type=$facilityType)',
        name: _logName,
      );
      final remote = await _api.fetchFacilitiesByCity(
        city: city,
        facilityType: facilityType,
        limit: limit,
      );
      if (remote.isNotEmpty) {
        await _cache.saveAll(
          remote.map((f) => f.toJson()).toList(),
        );
      }
      return FacilitiesQueryResult(facilities: remote, isOffline: false);
    } catch (error, stackTrace) {
      developer.log(
        'Facility city list failed: $error',
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
      final remote = await _api.getFacilityById(id);
      if (remote != null) {
        await _cache.upsertOne(remote.toJson());
      }
      return remote;
    } catch (error) {
      final cached = _cache.getById(id);
      if (cached == null) return null;
      return FacilityModel.fromJson(cached);
    }
  }

  Future<void> rememberCoordinates(
    String id,
    double lat,
    double lon,
  ) async {
    await _cache.patchCoordinates(id, lat, lon);
    await _homeDashboardCache.patchCoordinates(id, lat, lon);
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
