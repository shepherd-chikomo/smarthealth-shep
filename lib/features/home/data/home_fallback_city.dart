import 'package:smarthealth_shep/core/location/data/zimbabwe_cities.dart';
import 'package:smarthealth_shep/core/location/models/location_models.dart';

/// Resolves the city name used for list fallback when geo nearby is empty.
String resolveFallbackCity({
  required AppPosition origin,
  required String headerCity,
  required bool headerCityManual,
}) {
  if (headerCityManual) {
    final headerMatch = ZimbabweCities.byName(headerCity);
    if (headerMatch != null) return headerMatch.name;
  }

  if (origin.source == LocationSource.manual && origin.cityName != null) {
    final manualMatch = ZimbabweCities.byName(origin.cityName!);
    if (manualMatch != null) return manualMatch.name;
  }

  return ZimbabweCities.nearestTo(origin.latitude, origin.longitude).name;
}
