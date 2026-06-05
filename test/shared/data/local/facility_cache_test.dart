import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:smarthealth_shep/shared/data/local/facility_cache.dart';

void main() {
  late FacilityCache cache;
  late Box box;

  setUp(() async {
    Hive.init('./.dart_tool/test_hive');
    box = await Hive.openBox('test_facilities');
    await box.clear();
    cache = FacilityCache(box: box);
  });

  tearDown(() async {
    await box.clear();
    await box.close();
  });

  test('upsertOne merges by id without dropping other facilities', () async {
    await cache.saveAll([
      {
        'id': 'a',
        'name': 'Alpha',
        'city': 'Harare',
      },
      {
        'id': 'b',
        'name': 'Beta',
        'city': 'Bulawayo',
      },
    ]);

    await cache.upsertOne({
      'id': 'a',
      'name': 'Alpha Updated',
      'phone': '123',
    });

    final all = cache.readAll();
    expect(all.length, 2);
    expect(all.firstWhere((f) => f['id'] == 'a')['name'], 'Alpha Updated');
    expect(all.firstWhere((f) => f['id'] == 'a')['city'], 'Harare');
    expect(all.firstWhere((f) => f['id'] == 'b')['name'], 'Beta');
  });

  test('patchCoordinates updates only latitude and longitude', () async {
    await cache.saveAll([
      {
        'id': 'a',
        'name': 'Alpha',
        'city': 'Harare',
      },
    ]);

    await cache.patchCoordinates('a', -17.8, 31.05);

    final updated = cache.getById('a');
    expect(updated?['latitude'], -17.8);
    expect(updated?['longitude'], 31.05);
    expect(updated?['name'], 'Alpha');
  });
}
