import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';
import 'package:smarthealth_shep/shared/data/sync/cache_invalidation.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';

const _facilitiesKey = 'facilities_json';
const _lastSyncKey = 'facilities_last_sync';

/// Aggressively cached facility directory for offline discovery.
class FacilityCache {
  FacilityCache({Box? box}) : _box = box;

  Box? _box;

  Box get box => _box ?? Hive.box(HiveBoxes.facilities);

  Future<void> saveAll(List<Map<String, dynamic>> facilities) async {
    await box.put(_facilitiesKey, jsonEncode(facilities));
    await box.put(_lastSyncKey, DateTime.now().toUtc().toIso8601String());
  }

  List<Map<String, dynamic>> readAll() {
    final raw = box.get(_facilitiesKey);
    if (raw is! String) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic>? getById(String id) {
    for (final facility in readAll()) {
      if (facility['id'] == id) return facility;
    }
    return null;
  }

  DateTime? get lastSyncedAt {
    final raw = box.get(_lastSyncKey) as String?;
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  bool get isStale => CacheInvalidationPolicy.isStale(
        entity: SyncEntityType.facility,
        cachedAt: lastSyncedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      );
}
