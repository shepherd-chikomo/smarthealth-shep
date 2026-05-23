import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';

/// Opens Hive boxes required at startup.
Future<void> initHive() async {
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox(HiveBoxes.providers),
    Hive.openBox(HiveBoxes.categories),
    Hive.openBox(HiveBoxes.emergency),
    Hive.openBox(HiveBoxes.httpCache),
    Hive.openBox(HiveBoxes.homeDashboard),
  ]);
}
