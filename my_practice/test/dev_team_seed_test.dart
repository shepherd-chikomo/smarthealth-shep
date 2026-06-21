import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/seed/dev_team_seed.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('DevTeamSeed.ensure inserts 4 practitioners', () async {
    await DevTeamSeed.ensure(db, DevTeamSeed.seedFacilityId);

    final rows = await (db.select(db.practitioners)
          ..where((t) => t.facilityId.equals(DevTeamSeed.seedFacilityId)))
        .get();

    expect(rows.length, 4);
    expect(rows.map((r) => r.name), contains('Dr. Seed Practitioner'));
  });

  test('DevTeamSeed.ensure is idempotent', () async {
    await DevTeamSeed.ensure(db, DevTeamSeed.seedFacilityId);
    await DevTeamSeed.ensure(db, DevTeamSeed.seedFacilityId);

    final rows = await db.select(db.practitioners).get();
    expect(rows.length, 4);
  });

  test('watch emits after ensure', () async {
    await DevTeamSeed.ensure(db, DevTeamSeed.seedFacilityId);

    final stream = (db.select(db.practitioners)
          ..where((t) => t.facilityId.equals(DevTeamSeed.seedFacilityId)))
        .watch();

    final first = await stream.first;
    expect(first.length, 4);
  });
}
