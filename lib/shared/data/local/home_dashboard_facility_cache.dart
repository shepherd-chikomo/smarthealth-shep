import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';

const _cacheFacilitiesKey = 'home_facilities_json';

/// Patches facility coordinates in the home dashboard Hive cache.
class HomeDashboardFacilityCache {
  HomeDashboardFacilityCache({Box? box}) : _box = box;

  Box? _box;

  Box get box => _box ?? Hive.box(HiveBoxes.homeDashboard);

  Future<void> patchCoordinates(String id, double lat, double lon) async {
    final raw = box.get(_cacheFacilitiesKey);
    if (raw is! String) return;

    try {
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final index = list.indexWhere((entry) => entry['id'] == id);
      if (index < 0) return;

      list[index] = {
        ...list[index],
        'latitude': lat,
        'longitude': lon,
      };
      await box.put(_cacheFacilitiesKey, jsonEncode(list));
    } catch (_) {
      // Ignore corrupt cache payloads.
    }
  }
}
