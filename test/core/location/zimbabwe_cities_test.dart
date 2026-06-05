import 'package:flutter_test/flutter_test.dart';
import 'package:smarthealth_shep/core/location/data/zimbabwe_cities.dart';

void main() {
  group('ZimbabweCities.nearestTo', () {
    test('returns Harare for coordinates in Harare', () {
      final city = ZimbabweCities.nearestTo(-17.8252, 31.0335);
      expect(city.name, 'Harare');
    });

    test('returns Bulawayo for coordinates in Bulawayo', () {
      final city = ZimbabweCities.nearestTo(-20.1556, 28.5847);
      expect(city.name, 'Bulawayo');
    });
  });
}
