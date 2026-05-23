import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart' hide LocationServiceDisabledException;
import 'package:smarthealth_shep/core/location/location_exceptions.dart';

const _logName = 'LocationPermissionHandler';

/// Outcome of a location permission check or request.
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

/// Requests and validates location permissions with settings redirect helpers.
class LocationPermissionHandler {
  const LocationPermissionHandler();

  Future<LocationPermissionStatus> checkStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    return _mapPermission(permission);
  }

  /// Requests permission when needed; does not open settings automatically.
  Future<LocationPermissionStatus> request() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      developer.log('Location services disabled', name: _logName);
      return LocationPermissionStatus.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      developer.log('Permission request result: $permission', name: _logName);
    }

    return _mapPermission(permission);
  }

  /// Ensures permission is granted or throws a typed [LocationException].
  Future<void> ensureGranted() async {
    final status = await request();

    switch (status) {
      case LocationPermissionStatus.granted:
        return;
      case LocationPermissionStatus.serviceDisabled:
        throw const LocationServiceDisabledException();
      case LocationPermissionStatus.denied:
        throw const LocationPermissionDeniedException(isPermanent: false);
      case LocationPermissionStatus.deniedForever:
        throw const LocationPermissionDeniedException(isPermanent: true);
    }
  }

  /// Opens the app settings page so the user can grant location permission.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Opens the device location settings (GPS toggle).
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  /// Shows a dialog and optionally redirects to settings when denied forever.
  Future<void> handlePermissionDenied({
    required LocationPermissionDeniedException error,
    required Future<bool?> Function({
      required String title,
      required String message,
      required String confirmLabel,
      String? cancelLabel,
    }) showDialog,
  }) async {
    if (!error.shouldOpenSettings) return;

    final open = await showDialog(
      title: 'Location permission required',
      message:
          'SmartHealth needs location access to find nearby providers. '
          'Please enable location permission in Settings.',
      confirmLabel: 'Open Settings',
      cancelLabel: 'Not now',
    );

    if (open == true) {
      await openAppSettings();
    }
  }

  LocationPermissionStatus _mapPermission(LocationPermission permission) {
    return switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse =>
        LocationPermissionStatus.granted,
      LocationPermission.denied => LocationPermissionStatus.denied,
      LocationPermission.deniedForever =>
        LocationPermissionStatus.deniedForever,
      LocationPermission.unableToDetermine =>
        LocationPermissionStatus.denied,
    };
  }
}
