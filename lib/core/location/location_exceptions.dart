/// Location-related failures surfaced to UI and repositories.
sealed class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// User denied location permission or it is permanently denied.
final class LocationPermissionDeniedException extends LocationException {
  const LocationPermissionDeniedException({
    required this.isPermanent,
    String message = 'Location permission denied',
  }) : super(message);

  final bool isPermanent;

  bool get shouldOpenSettings => isPermanent;
}

/// Device location services (GPS) are disabled system-wide.
final class LocationServiceDisabledException extends LocationException {
  const LocationServiceDisabledException([
    super.message = 'Location services are disabled',
  ]);
}

/// No GPS fix and no last-known position available.
final class LocationUnavailableException extends LocationException {
  const LocationUnavailableException([
    super.message = 'Unable to determine your location',
  ]);
}
