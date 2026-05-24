import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_facility.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_hub_data.dart';
import 'package:smarthealth_shep/features/emergency/data/emergency_fallback_data.dart';
import 'package:smarthealth_shep/shared/data/sync/cache_invalidation.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';

const _hubKey = 'emergency_hub';
const _lastSyncKey = 'emergency_last_sync';

/// Always-available local emergency cache (mission-critical offline access).
class EmergencyCache {
  EmergencyCache({Box? box}) : _box = box;

  Box? _box;

  Box get box => _box ?? Hive.box(HiveBoxes.emergency);

  Future<void> saveHub(EmergencyHubData hub) async {
    await box.put(_hubKey, jsonEncode({
      'cachedAt': hub.cachedAt.toIso8601String(),
      'services': hub.services.map((s) => s.toJson()).toList(),
      'facilities': hub.facilities.map((f) => f.toJson()).toList(),
    }));
    await box.put(_lastSyncKey, DateTime.now().toUtc().toIso8601String());
  }

  EmergencyHubData readHub() {
    final raw = box.get(_hubKey);
    if (raw is String) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return EmergencyHubData.fromJson(map);
      } catch (_) {
        // fall through to hardcoded fallback
      }
    }
    return EmergencyFallbackData.hub();
  }

  List<EmergencyFacility> readFacilities() => readHub().facilities;

  DateTime? get lastSyncedAt {
    final raw = box.get(_lastSyncKey) as String?;
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  bool get isStale => CacheInvalidationPolicy.isStale(
        entity: SyncEntityType.emergency,
        cachedAt: lastSyncedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      );
}
