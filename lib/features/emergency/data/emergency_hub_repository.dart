import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';
import 'package:smarthealth_shep/features/emergency/data/emergency_fallback_data.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_hub_data.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_service.dart';

/// Emergency hub data — aggressively cached, never expires.
class EmergencyHubRepository {
  EmergencyHubRepository({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static const _hubCacheKey = 'emergency_hub_data_v1';

  Box get _box => Hive.box(HiveBoxes.emergency);

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Loads hub data: cache first (never expires), then API merge, then hardcoded.
  Future<EmergencyHubData> loadHub({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _readCache();
      if (cached != null) {
        if (await _isOnline()) {
          _refreshInBackground();
        }
        return cached;
      }
    }

    final fallback = EmergencyFallbackData.hub();
    await _writeCache(fallback);

    if (await _isOnline()) {
      try {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final remote = EmergencyApiMock.fetchUpdate();
        if (remote != null) {
          final merged = _merge(fallback, remote);
          await _writeCache(merged);
          return merged;
        }
      } catch (_) {
        return fallback;
      }
    }

    return fallback;
  }

  EmergencyService? findService(EmergencyHubData data, String id) {
    for (final service in data.services) {
      if (service.id == id) return service;
    }
    return null;
  }

  Future<void> _refreshInBackground() async {
    try {
      final remote = EmergencyApiMock.fetchUpdate();
      if (remote == null) return;
      final cached = _readCache() ?? EmergencyFallbackData.hub();
      await _writeCache(_merge(cached, remote));
    } catch (_) {}
  }

  EmergencyHubData _merge(EmergencyHubData base, EmergencyHubData remote) {
    return remote.copyWith(cachedAt: DateTime.now());
  }

  EmergencyHubData? _readCache() {
    final raw = _box.get(_hubCacheKey);
    if (raw == null) return null;
    try {
      return EmergencyHubData.fromJson(
        jsonDecode(raw as String) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(EmergencyHubData data) async {
    await _box.put(_hubCacheKey, jsonEncode(data.toJson()));
  }
}
