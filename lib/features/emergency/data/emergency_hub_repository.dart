import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/location/location_exceptions.dart';
import 'package:smarthealth_shep/core/location/search_origin_resolver.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';
import 'package:smarthealth_shep/features/emergency/data/emergency_fallback_data.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_facility.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_hub_data.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_service.dart';

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

  static const _hubCacheKey = 'emergency_hub_data_v2';

  Box get _box => Hive.box(HiveBoxes.emergency);

  Dio get _client => _dio ?? createApiDio();

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<EmergencyHubData> loadHub({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _readCache();
      if (cached != null) {
        if (await _isOnline()) {
          _refreshInBackground();
        }
        return cached;
      }
    }

    if (await _isOnline()) {
      try {
        final remote = await _fetchFromApi();
        await _writeCache(remote);
        return remote;
      } catch (_) {
        final cached = _readCache();
        if (cached != null) return cached;
        if (AppConfig.allowMockFallbacks) {
          final fallback = EmergencyFallbackData.hub();
          await _writeCache(fallback);
          return fallback;
        }
        rethrow;
      }
    }

    final cached = _readCache();
    if (cached != null) return cached;

    if (AppConfig.allowMockFallbacks) {
      final fallback = EmergencyFallbackData.hub();
      await _writeCache(fallback);
      return fallback;
    }
    throw StateError('No network and no cached emergency hub data.');
  }

  Future<EmergencyHubData> _fetchFromApi() async {
    double? lat;
    double? lon;

    final origin = _searchOrigin;
    if (origin != null) {
      try {
        final position = await origin.resolve(refreshGps: true);
        lat = position.latitude;
        lon = position.longitude;
      } on LocationPermissionDeniedException {
        final cached = origin.readCached();
        if (cached != null) {
          lat = cached.latitude;
          lon = cached.longitude;
        }
      } catch (_) {
        final cached = origin.readCached();
        if (cached != null) {
          lat = cached.latitude;
          lon = cached.longitude;
        }
      }
    }

    final response = await _client.get<Map<String, dynamic>>(
      '/emergency/hub',
      queryParameters: {
        if (lat != null) 'lat': lat,
        if (lon != null) 'lon': lon,
        'radiusKm': 50,
        'limit': 100,
        'page': 1,
      },
    );
    final data = response.data ?? {};
    final apiLocationRequired = data['locationRequired'] as bool? ?? true;

    if (apiLocationRequired && lat == null) {
      // Fall back to national directory when GPS unavailable.
      return EmergencyHubData(
        cachedAt: DateTime.now(),
        services: const [],
        facilities: const [],
        locationRequired: true,
      );
    }

    // When grid services are empty but facilities exist, surface ER facilities as services.
    var mapped = _mapHubResponse(data, locationRequired: apiLocationRequired);
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
    return mapped;
  }

  EmergencyHubData _mapHubResponse(
    Map<String, dynamic> data, {
    required bool locationRequired,
  }) {
    final serviceList = data['services'] as List<dynamic>? ?? [];
    final facilityList = data['facilities'] as List<dynamic>? ?? [];

    final services = <EmergencyService>[];
    final facilities = <EmergencyFacility>[];

    for (final raw in serviceList) {
      final map = raw as Map<String, dynamic>;
      final serviceType = map['serviceType'] as String? ?? 'other';
      final kind = _kindFromType(serviceType);
      if (kind == null) continue;

      services.add(
        EmergencyService(
          id: map['id'] as String,
          name: map['name'] as String,
          kind: kind,
          phone: map['phone'] as String? ?? '',
          nearestDistanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
          nearestProviderName: map['city'] as String?,
          nearestLatitude: (map['latitude'] as num?)?.toDouble(),
          nearestLongitude: (map['longitude'] as num?)?.toDouble(),
        ),
      );
    }

    for (final raw in facilityList) {
      final map = raw as Map<String, dynamic>;
      facilities.add(
        EmergencyFacility(
          id: map['id'] as String,
          name: map['name'] as String,
          type: _facilityTypeLabel(
            serviceType: map['serviceType'] as String? ?? 'hospital_er',
            source: map['source'] as String?,
            referralLabel: map['referralLabel'] as String?,
          ),
          distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
          phone: map['phone'] as String? ?? '',
          latitude: (map['latitude'] as num?)?.toDouble(),
          longitude: (map['longitude'] as num?)?.toDouble(),
          is24Hours: map['is24Hours'] as bool? ?? false,
          source: _parseSource(map['source'] as String?),
          referralLabel: map['referralLabel'] as String?,
        ),
      );
    }

    if (services.isEmpty && facilities.isEmpty && AppConfig.allowMockFallbacks) {
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
      locationRequired: locationRequired,
    );
  }

  String _facilityTypeLabel({
    required String serviceType,
    String? source,
    String? referralLabel,
  }) {
    return switch (source) {
      'government_hospital' => referralLabel?.isNotEmpty == true
          ? referralLabel!
          : 'Government hospital',
      'profile_emergency' => 'Emergency department',
      'emergency_directory' => 'ER directory',
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
      _ => null,
    };
  }

  EmergencyService? findService(EmergencyHubData data, String id) {
    for (final service in data.services) {
      if (service.id == id) return service;
    }
    return null;
  }

  void _refreshInBackground() {
    _fetchFromApi().then(_writeCache).ignore();
  }

  EmergencyHubData? _readCache() {
    final raw = _box.get(_hubCacheKey);
    if (raw == null) return null;
    try {
      return EmergencyHubData.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(EmergencyHubData data) async {
    await _box.put(_hubCacheKey, jsonEncode(data.toJson()));
  }
}
