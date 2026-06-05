import 'package:flutter_test/flutter_test.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/utils/maps_launcher.dart';

void main() {
  group('FacilityMapsX.mapsQuery', () {
    const withCoords = FacilityModel(
      id: '1',
      name: 'Test',
      slug: 'test',
      facilityType: 'pharmacy',
      city: 'Harare',
      province: 'Harare',
      latitude: -17.8,
      longitude: 31.0,
      addressLine1: '1 Main St',
    );

    const addressOnly = FacilityModel(
      id: '2',
      name: 'Test',
      slug: 'test',
      facilityType: 'pharmacy',
      city: 'Harare',
      province: 'Harare',
      addressLine1: '2 A Fairways Building, Belgravia',
    );

    test('returns lat,lng when coordinates present', () {
      expect(withCoords.mapsQuery, '-17.8,31.0');
    });

    test('returns joined address when coordinates absent', () {
      expect(
        addressOnly.mapsQuery,
        '2 A Fairways Building, Belgravia, Harare, Harare',
      );
    });
  });
}
