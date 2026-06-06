import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';

const _profilePrefix = 'facility_public_profile_';
const _profileSyncedPrefix = 'facility_public_profile_synced_';
const profileCacheTtl = Duration(hours: 24);

class FacilityPublicProfileCache {
  FacilityPublicProfileCache({Box? box}) : _box = box;

  Box? _box;
  Box get box => _box ?? Hive.box(HiveBoxes.facilities);

  String _key(String id) => '$_profilePrefix$id';
  String _syncedKey(String id) => '$_profileSyncedPrefix$id';

  Future<void> save(String facilityId, Map<String, dynamic> profile) async {
    await box.put(_key(facilityId), jsonEncode(profile));
    await box.put(_syncedKey(facilityId), DateTime.now().toUtc().toIso8601String());
  }

  Map<String, dynamic>? read(String facilityId) {
    final raw = box.get(_key(facilityId));
    if (raw is! String) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  bool isStale(String facilityId) {
    final raw = box.get(_syncedKey(facilityId));
    if (raw is! String) return true;
    try {
      final synced = DateTime.parse(raw).toUtc();
      return DateTime.now().toUtc().difference(synced) > profileCacheTtl;
    } catch (_) {
      return true;
    }
  }
}
