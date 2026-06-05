import 'dart:convert';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/location/models/location_models.dart';
import 'package:smarthealth_shep/core/location/search_origin_resolver.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';
import 'package:smarthealth_shep/features/queue/data/queue_repository.dart';
import 'package:smarthealth_shep/features/queue/models/queue_session.dart';
import 'package:smarthealth_shep/core/location/location_service.dart';
import 'package:smarthealth_shep/shared/data/facility_repository.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';

const _logName = 'HomeRepository';

class HomeSyncResult {
  const HomeSyncResult({
    required this.facilities,
    required this.city,
    required this.lastUpdated,
    required this.isOffline,
    this.activeQueue,
    this.loadError,
    this.searchOrigin,
  });

  final List<FacilityModel> facilities;
  final String city;
  final DateTime lastUpdated;
  final bool isOffline;
  final QueueSession? activeQueue;
  final String? loadError;
  final AppPosition? searchOrigin;
}

/// Loads and caches home dashboard facility data (offline-first).
class HomeRepository {
  HomeRepository({
    FacilityRepository? facilityRepository,
    Connectivity? connectivity,
    QueueRepository? queueRepository,
    SearchOriginResolver? searchOrigin,
  })  : _facilities = facilityRepository ?? FacilityRepository.defaults(),
        _connectivity = connectivity ?? Connectivity(),
        _queue = queueRepository ?? QueueRepository(),
        _searchOrigin = searchOrigin ?? SearchOriginResolver(
          locationService: LocationService(),
        );

  final FacilityRepository _facilities;
  final Connectivity _connectivity;
  final QueueRepository _queue;
  final SearchOriginResolver _searchOrigin;

  static const _cacheFacilitiesKey = 'home_facilities_json';
  static const _cacheCityKey = 'home_city';
  static const _cacheUpdatedKey = 'home_last_updated';
  static const _cacheSchemaKey = 'home_facilities_cache_schema';
  /// Bump when home facility API semantics change (e.g. after geocoding backfill).
  static const _cacheSchemaVersion = 5;

  Box get _box => Hive.box(HiveBoxes.homeDashboard);

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<HomeSyncResult> sync({
    bool forceRefresh = false,
    String? facilityType,
    bool refreshOrigin = false,
    String? manualCityName,
  }) async {
    final cacheSchema =
        _box.get(_cacheSchemaKey, defaultValue: 0) as int;
    if (cacheSchema < _cacheSchemaVersion) {
      await _box.delete(_cacheFacilitiesKey);
      await _box.put(_cacheSchemaKey, _cacheSchemaVersion);
      forceRefresh = true;
    }

    final city = _box.get(_cacheCityKey, defaultValue: 'Harare') as String;
    final online = await _isOnline();

    final origin = await _searchOrigin.resolve(
      refreshGps: refreshOrigin,
      manualCityName: manualCityName,
    );

    developer.log(
      'Syncing home facilities (online=$online, origin=${origin.source.name}, api=${AppConfig.apiBaseUrl})',
      name: _logName,
    );

    // Always attempt API when using main database — connectivity_plus can
    // report offline on Android while HTTP to adb-reverse localhost still works.
    try {
      final nearby = await _facilities.getNearbyFacilities(
        lat: origin.latitude,
        lon: origin.longitude,
        radiusKm: AppConfig.defaultSearchRadiusKm,
        facilityType: facilityType,
      );
      final facilities = nearby.facilities;
      final now = DateTime.now();

      developer.log(
        'Loaded ${facilities.length} facilities from API',
        name: _logName,
      );

      if (facilities.isNotEmpty) {
        await _writeCache(facilities, city, now);
      } else if (forceRefresh) {
        await _box.delete(_cacheFacilitiesKey);
      }

      return HomeSyncResult(
        facilities: facilities,
        city: city,
        lastUpdated: now,
        isOffline: nearby.isOffline || !online,
        activeQueue: _queue.getActiveSession(),
        searchOrigin: origin,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Home facility sync failed',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );

      final cached = _readCache();
      if (cached != null && cached.facilities.isNotEmpty) {
        return HomeSyncResult(
          facilities: cached.facilities,
          city: cached.city,
          lastUpdated: cached.lastUpdated,
          isOffline: true,
          activeQueue: _queue.getActiveSession(),
          loadError: error.toString(),
          searchOrigin: origin,
        );
      }

      return HomeSyncResult(
        facilities: const [],
        city: city,
        lastUpdated: DateTime.now(),
        isOffline: true,
        activeQueue: _queue.getActiveSession(),
        loadError: error.toString(),
        searchOrigin: origin,
      );
    }
  }

  Future<void> saveCity(String city) async {
    await _box.put(_cacheCityKey, city);
  }

  List<FacilityModel>? readCachedFacilities() => _readCache()?.facilities;

  Future<void> _writeCache(
    List<FacilityModel> facilities,
    String city,
    DateTime updated,
  ) async {
    final jsonList = facilities.map((f) => f.toJson()).toList();
    await _box.put(_cacheFacilitiesKey, jsonEncode(jsonList));
    await _box.put(_cacheCityKey, city);
    await _box.put(_cacheUpdatedKey, updated.toIso8601String());
  }

  ({List<FacilityModel> facilities, String city, DateTime lastUpdated})?
      _readCache() {
    final raw = _box.get(_cacheFacilitiesKey);
    if (raw == null) return null;

    try {
      final list = (jsonDecode(raw as String) as List<dynamic>)
          .map((e) => FacilityModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (list.isEmpty) return null;

      final city = _box.get(_cacheCityKey, defaultValue: 'Harare') as String;
      final updatedRaw = _box.get(_cacheUpdatedKey) as String?;
      final updated = updatedRaw != null
          ? DateTime.parse(updatedRaw)
          : DateTime.now();
      return (facilities: list, city: city, lastUpdated: updated);
    } catch (_) {
      return null;
    }
  }
}
