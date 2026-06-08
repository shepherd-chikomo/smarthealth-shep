import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/location/location_exceptions.dart';
import 'package:smarthealth_shep/core/location/models/location_models.dart';
import 'package:smarthealth_shep/core/location/search_origin_resolver.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';
import 'package:smarthealth_shep/features/emergency/data/emergency_fallback_data.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_facility.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_hub_data.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_service.dart';

class EmergencyHubLoadResult {
  const EmergencyHubLoadResult({
    required this.data,
    this.searchOrigin,
  });

  final EmergencyHubData data;
  final AppPosition? searchOrigin;
}

/// Emergency hub — cached list from GET /emergency/hub with GPS when available.
class EmergencyHubRepository {
  EmergencyHubRepository({
    Connectivity? connectivity,
    Dio? dio,
    SearchOriginResolver? searchOrigin,
  })  : _connectivity = connectivity ?? Connectivity(),
        _dio = dio,
        _searchOrigin = searchOrigin;

  final Connectivity _connectivity;
  final Dio? _dio;
  final SearchOriginResolver? _searchOrigin;

  static const _hubCachePrefix = 'emergency_hub_data_v5';

  Box get _box => Hive.box(HiveBoxes.emergency);

  Dio get _client => _dio ?? createApiDio();

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  String _cacheKey(double lat, double lon) =>
      '${_hubCachePrefix}_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';

  Future<EmergencyHubLoadResult> loadHub({
    bool forceRefresh = false,
    bool refreshGps = false,
  }) async {
    final origin = await _resolveOrigin(refreshGps: refreshGps);
    final lat = origin?.latitude ?? AppConfig.defaultLatitude;
    final lon = origin?.longitude ?? AppConfig.defaultLongitude;
    final cacheKey = _cacheKey(lat, lon);

    if (!forceRefresh) {
      final cached = _readCache(cacheKey);
      if (cached != null && _hasContent(cached)) {
        if (await _isOnline()) {
          _refreshInBackground(refreshGps: false);
        }
        return EmergencyHubLoadResult(data: cached, searchOrigin: origin);
      }
    }

    if (await _isOnline()) {
      try {
        final remote = await _fetchFromApi(refreshGps: refreshGps);
        final enriched = _ensureNationalServices(remote.data);
        await _writeCache(cacheKey, enriched);
        return EmergencyHubLoadResult(
          data: enriched,
          searchOrigin: remote.searchOrigin,
        );
      } catch (_) {
        final cached = _readCache(cacheKey);
        if (cached != null && _hasContent(cached)) {
          return EmergencyHubLoadResult(data: cached, searchOrigin: origin);
        }
        final fallback = _ensureNationalServices(
          EmergencyHubData(
            services: const [],
            facilities: const [],
            cachedAt: DateTime.now(),
          ),
        );
        if (_hasContent(fallback)) {
          return EmergencyHubLoadResult(data: fallback, searchOrigin: origin);
        }
        if (AppConfig.allowMockFallbacks) {
          final mock = EmergencyFallbackData.hub();
          await _writeCache(cacheKey, mock);
          return EmergencyHubLoadResult(data: mock, searchOrigin: origin);
        }
        rethrow;
      }
    }

    final cached = _readCache(cacheKey);
    if (cached != null && _hasContent(cached)) {
      return EmergencyHubLoadResult(data: cached, searchOrigin: origin);
    }

    final offlineFallback = _ensureNationalServices(
      EmergencyHubData(
        services: const [],
        facilities: const [],
        cachedAt: DateTime.now(),
        locationRequired: true,
      ),
    );
    if (_hasContent(offlineFallback)) {
      return EmergencyHubLoadResult(data: offlineFallback, searchOrigin: origin);
    }

    if (AppConfig.allowMockFallbacks) {
      final fallback = EmergencyFallbackData.hub();
      await _writeCache(cacheKey, fallback);
      return EmergencyHubLoadResult(data: fallback, searchOrigin: origin);
    }
    throw StateError('No network and no cached emergency hub data.');
  }

  Future<AppPosition?> _resolveOrigin({required bool refreshGps}) async {
    final origin = _searchOrigin;
    if (origin == null) return null;

    try {
      if (refreshGps) {
        return await origin.resolve(refreshGps: true);
      }
      final cached = origin.readCached();
      if (cached != null) return cached;
      return await origin.resolve(refreshGps: false);
    } on LocationPermissionDeniedException {
      return origin.readCached();
    } catch (_) {
      return origin.readCached();
    }
  }

  bool _hasContent(EmergencyHubData data) =>
      data.services.isNotEmpty ||
      data.facilities.isNotEmpty ||
      data.ambulanceServices.isNotEmpty;

  EmergencyHubData _ensureNationalServices(EmergencyHubData data) {
    if (data.services.isNotEmpty) return data;
    return data.copyWith(services: EmergencyFallbackData.hub().services);
  }

  Future<EmergencyHubLoadResult> _fetchFromApi({
    required bool refreshGps,
  }) async {
    final position = await _resolveOrigin(refreshGps: refreshGps);
    final lat = position?.latitude ?? AppConfig.defaultLatitude;
    final lon = position?.longitude ?? AppConfig.defaultLongitude;

    final response = await _client.get<Map<String, dynamic>>(
      '/emergency/hub',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'radiusKm': 50,
        'limit': 100,
        'page': 1,
      },
    );
    final data = response.data ?? {};
    final apiLocationRequired = data['locationRequired'] as bool? ?? true;
    final expandedSearch = data['expandedSearch'] as bool? ?? false;

    var mapped = _mapHubResponse(
      data,
      locationRequired: apiLocationRequired,
      expandedSearch: expandedSearch,
    );
    mapped = _ensureNationalServices(mapped);
    if (mapped.services.isEmpty && mapped.facilities.isNotEmpty) {
      mapped = mapped.copyWith(
        services: mapped.facilities
            .where((f) => f.phone.isNotEmpty)
            .take(4)
            .map(
              (f) => EmergencyService(
                id: f.id,
                name: f.name,
                kind: EmergencyServiceKind.rescueTeam,
                phone: f.phone,
                nearestDistanceKm: f.distanceKm,
                nearestProviderName: f.type,
                nearestLatitude: f.latitude,
                nearestLongitude: f.longitude,
              ),
            )
            .toList(),
      );
    }
    return EmergencyHubLoadResult(data: mapped, searchOrigin: position);
  }

  EmergencyHubData _mapHubResponse(
    Map<String, dynamic> data, {
    required bool locationRequired,
    required bool expandedSearch,
  }) {
    final serviceList = data['services'] as List<dynamic>? ?? [];
    final facilityList = data['facilities'] as List<dynamic>? ?? [];
    final ambulanceList = data['ambulanceServices'] as List<dynamic>? ?? [];

    final services = <EmergencyService>[];
    final facilities = <EmergencyFacility>[];
    final ambulanceServices = <EmergencyService>[];

    for (final raw in serviceList) {
      final map = raw as Map<String, dynamic>;
      final serviceType = map['serviceType'] as String? ?? 'other';
      final kind = _kindFromType(serviceType);
      if (kind == null) continue;

      services.add(_mapService(map, kind));
    }

    for (final raw in ambulanceList) {
      final map = raw as Map<String, dynamic>;
      ambulanceServices.add(
        _mapService(map, EmergencyServiceKind.ambulance),
      );
    }

    for (final raw in facilityList) {
      final map = raw as Map<String, dynamic>;
      final referralLabel = map['referralLabel'] as String?;
      facilities.add(
        EmergencyFacility(
          id: map['id'] as String,
          name: map['name'] as String,
          type: _facilityTypeLabel(
            serviceType: map['serviceType'] as String? ?? 'hospital_er',
            source: map['source'] as String?,
            referralLabel: referralLabel,
          ),
          distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
          phone: map['phone'] as String? ?? '',
          latitude: (map['latitude'] as num?)?.toDouble(),
          longitude: (map['longitude'] as num?)?.toDouble(),
          is24Hours: map['is24Hours'] as bool? ?? false,
          source: _parseSource(map['source'] as String?),
          referralLabel: referralLabel,
          pendingVerification: map['pendingVerification'] as bool? ?? false,
        ),
      );
    }

    if (services.isEmpty &&
        facilities.isEmpty &&
        ambulanceServices.isEmpty &&
        AppConfig.allowMockFallbacks) {
      return EmergencyFallbackData.hub();
    }

    return EmergencyHubData(
      cachedAt: DateTime.now(),
      services: services.isNotEmpty
          ? services
          : (AppConfig.allowMockFallbacks
              ? EmergencyFallbackData.hub().services
              : const []),
      facilities: facilities,
      ambulanceServices: ambulanceServices,
      locationRequired: locationRequired,
      expandedSearch: expandedSearch,
    );
  }

  EmergencyService _mapService(
    Map<String, dynamic> map,
    EmergencyServiceKind kind,
  ) {
    return EmergencyService(
      id: map['id'] as String,
      name: map['name'] as String,
      kind: kind,
      phone: map['phone'] as String? ?? '',
      nearestDistanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
      nearestProviderName: map['city'] as String?,
      nearestLatitude: (map['latitude'] as num?)?.toDouble(),
      nearestLongitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  String _facilityTypeLabel({
    required String serviceType,
    String? source,
    String? referralLabel,
  }) {
    if (referralLabel?.isNotEmpty == true) return referralLabel!;
    return switch (source) {
      'profile_emergency' => 'Emergency department',
      'emergency_directory' => 'Emergency directory',
      _ => serviceType == 'hospital_er'
          ? 'Hospital Emergency'
          : serviceType.replaceAll('_', ' '),
    };
  }

  EmergencyFacilitySource? _parseSource(String? raw) {
    return switch (raw) {
      'emergency_directory' => EmergencyFacilitySource.emergencyDirectory,
      'government_hospital' => EmergencyFacilitySource.governmentHospital,
      'profile_emergency' => EmergencyFacilitySource.profileEmergency,
      _ => null,
    };
  }

  EmergencyServiceKind? _kindFromType(String type) {
    return switch (type) {
      'ambulance' => EmergencyServiceKind.ambulance,
      'police' => EmergencyServiceKind.police,
      'fire' => EmergencyServiceKind.fireRescue,
      'disaster_response' => EmergencyServiceKind.rescueTeam,
      'hospital_er' => EmergencyServiceKind.rescueTeam,
      'mental_health_crisis' => EmergencyServiceKind.rescueTeam,
      _ => null,
    };
  }

  EmergencyService? findService(EmergencyHubData data, String id) {
    for (final service in [...data.services, ...data.ambulanceServices]) {
      if (service.id == id) return service;
    }
    return null;
  }

  void _refreshInBackground({required bool refreshGps}) {
    _fetchFromApi(refreshGps: refreshGps)
        .then((result) {
          final origin = result.searchOrigin;
          final lat = origin?.latitude ?? AppConfig.defaultLatitude;
          final lon = origin?.longitude ?? AppConfig.defaultLongitude;
          return _writeCache(
            _cacheKey(lat, lon),
            _ensureNationalServices(result.data),
          );
        })
        .ignore();
  }

  EmergencyHubData? _readCache(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      return EmergencyHubData.fromJson(
        jsonDecode(raw as String) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(String key, EmergencyHubData data) async {
    await _box.put(
      key,
      jsonEncode({
        'services': data.services.map((s) => s.toJson()).toList(),
        'facilities': data.facilities.map((f) => f.toJson()).toList(),
        'ambulanceServices': data.ambulanceServices.map((s) => s.toJson()).toList(),
        'cachedAt': data.cachedAt.toIso8601String(),
        'locationRequired': data.locationRequired,
        'expandedSearch': data.expandedSearch,
      }),
    );
  }
}
