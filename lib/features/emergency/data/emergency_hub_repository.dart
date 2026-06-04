import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';
import 'package:smarthealth_shep/features/emergency/data/emergency_fallback_data.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_facility.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_hub_data.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_service.dart';

/// Emergency hub — cached list from GET /emergency/services (same data as admin CRUD).
class EmergencyHubRepository {
  EmergencyHubRepository({Connectivity? connectivity, Dio? dio})
      : _connectivity = connectivity ?? Connectivity(),
        _dio = dio;

  final Connectivity _connectivity;
  final Dio? _dio;

  static const _hubCacheKey = 'emergency_hub_data_v1';

  Box get _box => Hive.box(HiveBoxes.emergency);

  Dio get _client => _dio ??
      Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ));

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
        if (AppConfig.allowMockFallbacks) {
          final fallback = EmergencyFallbackData.hub();
          await _writeCache(fallback);
          return fallback;
        }
        rethrow;
      }
    }

    if (AppConfig.allowMockFallbacks) {
      final fallback = EmergencyFallbackData.hub();
      await _writeCache(fallback);
      return fallback;
    }
    throw StateError('No network and no cached emergency hub data.');
  }

  Future<EmergencyHubData> _fetchFromApi() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/emergency/services',
      queryParameters: {'limit': 100, 'page': 1},
    );
    final list = response.data?['services'] as List<dynamic>? ?? [];
    return _mapApiToHub(list);
  }

  EmergencyHubData _mapApiToHub(List<dynamic> list) {
    final services = <EmergencyService>[];
    final facilities = <EmergencyFacility>[];

    for (final raw in list) {
      final map = raw as Map<String, dynamic>;
      final id = map['id'] as String;
      final name = map['name'] as String;
      final phone = map['phone'] as String;
      final serviceType = map['serviceType'] as String? ?? 'other';
      final city = map['city'] as String? ?? '';
      final lat = (map['latitude'] as num?)?.toDouble();
      final lng = (map['longitude'] as num?)?.toDouble();
      final distance = (map['distanceKm'] as num?)?.toDouble() ?? 0;

      if (serviceType == 'hospital_er') {
        facilities.add(
          EmergencyFacility(
            id: id,
            name: name,
            type: 'Hospital Emergency',
            distanceKm: distance,
            phone: phone,
            latitude: lat,
            longitude: lng,
          ),
        );
        continue;
      }

      final kind = _kindFromType(serviceType);
      if (kind != null) {
        services.add(
          EmergencyService(
            id: id,
            name: name,
            kind: kind,
            phone: phone,
            nearestDistanceKm: distance,
            nearestProviderName: city.isNotEmpty ? city : name,
            nearestLatitude: lat,
            nearestLongitude: lng,
          ),
        );
      } else {
        facilities.add(
          EmergencyFacility(
            id: id,
            name: name,
            type: serviceType.replaceAll('_', ' '),
            distanceKm: distance,
            phone: phone,
            latitude: lat,
            longitude: lng,
          ),
        );
      }
    }

    if (services.isEmpty && facilities.isEmpty) {
      if (AppConfig.allowMockFallbacks) {
        return EmergencyFallbackData.hub();
      }
      return EmergencyHubData(
        services: const [],
        facilities: const [],
        cachedAt: DateTime.now(),
      );
    }

    return EmergencyHubData(
      cachedAt: DateTime.now(),
      services: services.isNotEmpty
          ? services
          : (AppConfig.allowMockFallbacks
              ? EmergencyFallbackData.hub().services
              : const []),
      facilities: facilities,
    );
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
