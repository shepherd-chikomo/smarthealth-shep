import 'dart:async';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart' hide LocationServiceDisabledException;
import 'package:smarthealth_shep/core/location/data/zimbabwe_cities.dart';
import 'package:smarthealth_shep/core/location/location_exceptions.dart';
import 'package:smarthealth_shep/core/location/location_permission_handler.dart';
import 'package:smarthealth_shep/core/location/models/location_models.dart';
import 'package:smarthealth_shep/core/utils/haversine.dart';

const _logName = 'LocationService';

/// GPS, manual city, and distance utilities for the healthcare directory.
class LocationService {
  LocationService({
    LocationPermissionHandler? permissionHandler,
    this.positionTimeout = const Duration(seconds: 12),
    this.watchDistanceFilterMeters = 100,
  }) : _permissions = permissionHandler ?? const LocationPermissionHandler();

  final LocationPermissionHandler _permissions;
  final Duration positionTimeout;
  final int watchDistanceFilterMeters;

  StreamSubscription<Position>? _watchSubscription;
  final StreamController<AppPosition> _watchController =
      StreamController<AppPosition>.broadcast();

  AppPosition? _manualPosition;

  /// Most recently selected manual city position, if any.
  AppPosition? get manualPosition => _manualPosition;

  /// Requests GPS permission and returns the current fix, falling back to
  /// last-known position when a fresh fix is unavailable.
  Future<AppPosition> getCurrentPosition({bool requestPermission = true}) async {
    if (requestPermission) {
      await _permissions.ensureGranted();
    } else {
      final status = await _permissions.checkStatus();
      if (status != LocationPermissionStatus.granted) {
        throw _exceptionForStatus(status);
      }
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: positionTimeout,
        ),
      );
      developer.log(
        'GPS fix: ${position.latitude}, ${position.longitude}',
        name: _logName,
      );
      return _fromGeolocator(position, LocationSource.gps);
    } on LocationPermissionDeniedException {
      rethrow;
    } on LocationServiceDisabledException {
      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        'GPS fix failed — trying last known position',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );

      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        developer.log('Using last known position', name: _logName);
        return _fromGeolocator(lastKnown, LocationSource.lastKnown);
      }

      throw LocationUnavailableException(
        error is TimeoutException
            ? 'Location request timed out'
            : 'Unable to determine your location',
      );
    }
  }

  /// Returns last known device position without requesting a fresh GPS fix.
  Future<AppPosition?> getLastKnownPosition() async {
    final status = await _permissions.checkStatus();
    if (status != LocationPermissionStatus.granted) return null;

    final position = await Geolocator.getLastKnownPosition();
    if (position == null) return null;
    return _fromGeolocator(position, LocationSource.lastKnown);
  }

  /// Sets location from a manually selected Zimbabwe city.
  AppPosition setManualCity(ZimbabweCity city) {
    _manualPosition = city.toPosition();
    developer.log('Manual city set: ${city.name}', name: _logName);
    return _manualPosition!;
  }

  /// Sets location from a city name if it exists in the catalog.
  AppPosition? setManualCityByName(String cityName) {
    final city = ZimbabweCities.byName(cityName);
    if (city == null) return null;
    return setManualCity(city);
  }

  /// Searchable list of Zimbabwe cities for manual entry UI.
  List<ZimbabweCity> searchCities(String query) => ZimbabweCities.search(query);

  /// Resolves the best available position: GPS → last known → manual → [fallbackCity].
  Future<AppPosition> resolvePosition({
    ZimbabweCity? fallbackCity,
    bool requestPermission = true,
  }) async {
    try {
      return await getCurrentPosition(requestPermission: requestPermission);
    } on LocationException {
      final lastKnown = await getLastKnownPosition();
      if (lastKnown != null) return lastKnown;
      if (_manualPosition != null) return _manualPosition!;
      if (fallbackCity != null) return setManualCity(fallbackCity);
      rethrow;
    }
  }

  /// Great-circle distance in kilometres (Haversine).
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return haversineDistanceKm(lat1, lon1, lat2, lon2);
  }

  /// Formats [distanceKm] as `"450 m"` or `"2.5 km"`.
  static String formatDistance(double distanceKm) {
    if (distanceKm.isNaN || distanceKm.isInfinite || distanceKm < 0) {
      return '—';
    }

    if (distanceKm < 1) {
      final meters = (distanceKm * 1000).round();
      return '$meters m';
    }

    if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km';
    }

    return '${distanceKm.round()} km';
  }

  /// Battery-aware stream of position updates.
  ///
  /// Uses medium accuracy and a distance filter so updates are only emitted
  /// after meaningful movement.
  Stream<AppPosition> watchPositionChanges({
    LocationAccuracy accuracy = LocationAccuracy.medium,
  }) {
    if (_watchController.hasListener && _watchSubscription != null) {
      return _watchController.stream;
    }

    unawaited(_startWatch(accuracy));
    return _watchController.stream;
  }

  Future<void> _startWatch(LocationAccuracy accuracy) async {
    await _permissions.ensureGranted();

    await _watchSubscription?.cancel();
    _watchSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: watchDistanceFilterMeters,
      ),
    ).listen(
      (position) {
        if (!_watchController.isClosed) {
          _watchController.add(_fromGeolocator(position, LocationSource.gps));
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        developer.log(
          'Position stream error',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
        );
        if (!_watchController.isClosed) {
          _watchController.addError(error, stackTrace);
        }
      },
    );
  }

  /// Stops the active position watch to save battery.
  Future<void> stopWatching() async {
    await _watchSubscription?.cancel();
    _watchSubscription = null;
  }

  void dispose() {
    unawaited(stopWatching());
    _watchController.close();
  }

  AppPosition _fromGeolocator(Position position, LocationSource source) {
    return AppPosition(
      latitude: position.latitude,
      longitude: position.longitude,
      source: source,
      timestamp: position.timestamp,
      accuracyMeters: position.accuracy,
    );
  }

  LocationException _exceptionForStatus(LocationPermissionStatus status) {
    return switch (status) {
      LocationPermissionStatus.granted =>
        const LocationUnavailableException(),
      LocationPermissionStatus.serviceDisabled =>
        const LocationServiceDisabledException(),
      LocationPermissionStatus.denied =>
        const LocationPermissionDeniedException(isPermanent: false),
      LocationPermissionStatus.deniedForever =>
        const LocationPermissionDeniedException(isPermanent: true),
    };
  }
}
