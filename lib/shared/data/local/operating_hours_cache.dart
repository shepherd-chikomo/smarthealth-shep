import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';
import 'package:smarthealth_shep/shared/data/sync/cache_invalidation.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';
import 'package:smarthealth_shep/shared/models/working_hours_entry.dart';

const _prefix = 'hours_';
const _lastSyncPrefix = 'hours_sync_';

/// Operating hours cached locally per provider/facility.
class OperatingHoursCache {
  OperatingHoursCache({Box? box}) : _box = box;

  Box? _box;

  Box get box => _box ?? Hive.box(HiveBoxes.operatingHours);

  Future<void> save({
    required String providerId,
    required List<WorkingHoursEntry> hours,
  }) async {
    await box.put(
      '$_prefix$providerId',
      jsonEncode(hours.map((h) => h.toJson()).toList()),
    );
    await box.put(
      '$_lastSyncPrefix$providerId',
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  List<WorkingHoursEntry> read(String providerId) {
    final raw = box.get('$_prefix$providerId');
    if (raw is! String) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map(
            (e) => WorkingHoursEntry.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  DateTime? lastSyncedAt(String providerId) {
    final raw = box.get('$_lastSyncPrefix$providerId') as String?;
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  bool isStale(String providerId) => CacheInvalidationPolicy.isStale(
        entity: SyncEntityType.operatingHours,
        cachedAt:
            lastSyncedAt(providerId) ?? DateTime.fromMillisecondsSinceEpoch(0),
      );
}
