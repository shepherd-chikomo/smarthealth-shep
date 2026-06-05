import 'package:flutter_test/flutter_test.dart';
import 'package:smarthealth_shep/core/location/models/location_models.dart';
import 'package:smarthealth_shep/features/home/data/home_fallback_city.dart';

void main() {
  group('resolveFallbackCity', () {
    final gpsHarare = AppPosition(
      latitude: -17.8119,
      longitude: 31.0766,
      source: LocationSource.gps,
    );

    test('uses manually selected header city over nearest GPS city', () {
      expect(
        resolveFallbackCity(
          origin: gpsHarare,
          headerCity: 'Bulawayo',
          headerCityManual: true,
        ),
        'Bulawayo',
      );
    });

    test('uses manual search origin city when header was not manually set', () {
      expect(
        resolveFallbackCity(
          origin: AppPosition(
            latitude: -17.8119,
            longitude: 31.0766,
            source: LocationSource.manual,
            cityName: 'Mutare',
          ),
          headerCity: 'Harare',
          headerCityManual: false,
        ),
        'Mutare',
      );
    });

    test('falls back to nearest catalog city from GPS', () {
      expect(
        resolveFallbackCity(
          origin: gpsHarare,
          headerCity: 'Harare',
          headerCityManual: false,
        ),
        'Harare',
      );
    });
  });
}
