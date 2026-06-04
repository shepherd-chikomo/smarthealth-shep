import 'dart:developer' as developer;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/location/data/zimbabwe_cities.dart';
import 'package:smarthealth_shep/core/location/location_exceptions.dart';
import 'package:smarthealth_shep/core/location/location_service.dart';
import 'package:smarthealth_shep/core/location/models/location_models.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';

const _logName = 'SearchOriginResolver';

/// Resolves and caches the lat/lon used for nearby facility and provider APIs.
class SearchOriginResolver {
  SearchOriginResolver({
    required LocationService locationService,
    Box? box,
  })  : _location = locationService,
        _box = box ?? Hive.box(HiveBoxes.homeDashboard);

  final LocationService _location;
  final Box _box;

  static const _latKey = 'search_origin_lat';
  static const _lonKey = 'search_origin_lon';
  static const _sourceKey = 'search_origin_source';
  static const _cityKey = 'search_origin_city';

  AppPosition? readCached() {
    final lat = _box.get(_latKey);
    final lon = _box.get(_lonKey);
    if (lat is! num || lon is! num) return null;

    final sourceName = _box.get(_sourceKey, defaultValue: 'manual') as String;
    final source = LocationSource.values.firstWhere(
      (s) => s.name == sourceName,
      orElse: () => LocationSource.manual,
    );

    return AppPosition(
      latitude: lat.toDouble(),
      longitude: lon.toDouble(),
      source: source,
      cityName: _box.get(_cityKey) as String?,
    );
  }

  /// [refreshGps] requests a new GPS fix when true; otherwise uses cache first.
  /// [manualCityName] forces the selected Zimbabwe city as the origin.
  Future<AppPosition> resolve({
    bool refreshGps = false,
    String? manualCityName,
  }) async {
    if (manualCityName != null) {
      final city = ZimbabweCities.byName(manualCityName);
      if (city != null) {
        final position = _location.setManualCity(city);
        await _persist(position);
        developer.log(
          'Search origin: manual city ${city.name}',
          name: _logName,
        );
        return position;
      }
    }

    if (!refreshGps) {
      final cached = readCached();
      if (cached != null) {
        developer.log(
          'Search origin: cache (${cached.source.name})',
          name: _logName,
        );
        return cached;
      }
    }

    final harare = ZimbabweCities.byName('Harare')!;

    try {
      final position = await _location.resolvePosition(
        fallbackCity: harare,
        requestPermission: refreshGps,
      );
      await _persist(position);
      developer.log(
        'Search origin: ${position.source.name} ${position.latitude}, ${position.longitude}',
        name: _logName,
      );
      return position;
    } on LocationException catch (error) {
      developer.log(
        'Search origin fallback to Harare: $error',
        name: _logName,
      );
      final fallback = harare.toPosition();
      await _persist(fallback);
      return fallback;
    }
  }

  Future<void> _persist(AppPosition position) async {
    await _box.put(_latKey, position.latitude);
    await _box.put(_lonKey, position.longitude);
    await _box.put(_sourceKey, position.source.name);
    if (position.cityName != null) {
      await _box.put(_cityKey, position.cityName);
    }
  }
}
