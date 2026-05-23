import 'package:equatable/equatable.dart';

/// A resolved geographic point from GPS, cache, or manual city selection.
class AppPosition extends Equatable {
  const AppPosition({
    required this.latitude,
    required this.longitude,
    required this.source,
    this.cityName,
    this.timestamp,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final LocationSource source;
  final String? cityName;
  final DateTime? timestamp;
  final double? accuracyMeters;

  @override
  List<Object?> get props =>
      [latitude, longitude, source, cityName, timestamp, accuracyMeters];
}

/// How an [AppPosition] was obtained.
enum LocationSource {
  gps,
  lastKnown,
  manual,
}

/// A Zimbabwe city available for manual location selection.
class ZimbabweCity extends Equatable {
  const ZimbabweCity({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.province,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String? province;

  AppPosition toPosition() => AppPosition(
        latitude: latitude,
        longitude: longitude,
        source: LocationSource.manual,
        cityName: name,
        timestamp: DateTime.now().toUtc(),
      );

  @override
  List<Object?> get props => [name, latitude, longitude, province];
}
