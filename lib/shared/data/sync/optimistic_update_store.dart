import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';

const _actionsKey = 'pending_actions';

/// Tracks optimistic local mutations before server confirmation.
class OptimisticUpdateStore {
  OptimisticUpdateStore({Box? box}) : _box = box;

  Box? _box;

  Box get box => _box ?? Hive.box(HiveBoxes.syncQueue);

  Map<String, dynamic> _readActions() {
    final raw = box.get(_actionsKey);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  Future<void> _writeActions(Map<String, dynamic> actions) async {
    await box.put(_actionsKey, actions);
  }

  String _key(SyncEntityType type, String entityId) =>
      '${type.name}_$entityId';

  Future<void> record({
    required SyncEntityType entityType,
    required String entityId,
    required Map<String, dynamic> payload,
    required DateTime clientUpdatedAt,
  }) async {
    final actions = _readActions();
    actions[_key(entityType, entityId)] = {
      'entity_type': entityType.name,
      'entity_id': entityId,
      'payload_json': jsonEncode(payload),
      'client_updated_at': clientUpdatedAt.toUtc().toIso8601String(),
      'recorded_at': DateTime.now().toUtc().toIso8601String(),
    };
    await _writeActions(actions);
  }

  Future<Map<String, dynamic>?> get({
    required SyncEntityType entityType,
    required String entityId,
  }) async {
    final actions = _readActions();
    final raw = actions[_key(entityType, entityId)];
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(raw as Map);
    return {
      ...map,
      'payload': jsonDecode(map['payload_json'] as String) as Map<String, dynamic>,
    };
  }

  Future<void> clear({
    required SyncEntityType entityType,
    required String entityId,
  }) async {
    final actions = _readActions();
    actions.remove(_key(entityType, entityId));
    await _writeActions(actions);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final actions = _readActions();
    return actions.values.map((raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      return {
        ...map,
        'payload': jsonDecode(map['payload_json'] as String) as Map<String, dynamic>,
      };
    }).toList();
  }
}
