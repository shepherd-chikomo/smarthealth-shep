import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:smarthealth_shep/shared/data/local/home_dashboard_facility_cache.dart';

void main() {
  late HomeDashboardFacilityCache cache;
  late Box box;

  setUp(() async {
    Hive.init('./.dart_tool/test_hive_home');
    box = await Hive.openBox('test_home_dashboard');
    await box.clear();
    cache = HomeDashboardFacilityCache(box: box);
  });

  tearDown(() async {
    await box.clear();
    await box.close();
  });

  test('patchCoordinates updates matching facility in home cache', () async {
    await box.put(
      'home_facilities_json',
      '[{"id":"a","name":"Alpha","city":"Harare"}]',
    );

    await cache.patchCoordinates('a', -17.8, 31.05);

    final raw = box.get('home_facilities_json') as String;
    expect(raw, contains('"latitude":-17.8'));
    expect(raw, contains('"longitude":31.05'));
    expect(raw, contains('"name":"Alpha"'));
  });
}
