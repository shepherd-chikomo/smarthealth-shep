import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';
import 'package:smarthealth_shep/shared/data/provider_repository.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

class HomeSyncResult {
  const HomeSyncResult({
    required this.providers,
    required this.city,
    required this.lastUpdated,
    required this.isOffline,
  });

  final List<ProviderModel> providers;
  final String city;
  final DateTime lastUpdated;
  final bool isOffline;
}

/// Loads and caches home dashboard provider data (offline-first).
class HomeRepository {
  HomeRepository({
    ProviderRepository? providerRepository,
    Connectivity? connectivity,
  })  : _providers = providerRepository ?? ProviderRepository(),
        _connectivity = connectivity ?? Connectivity();

  final ProviderRepository _providers;
  final Connectivity _connectivity;

  static const _cacheProvidersKey = 'home_providers_json';
  static const _cacheCityKey = 'home_city';
  static const _cacheUpdatedKey = 'home_last_updated';

  Box get _box => Hive.box(HiveBoxes.homeDashboard);

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<HomeSyncResult> sync({bool forceRefresh = false}) async {
    final online = await _isOnline();
    final city = _box.get(_cacheCityKey, defaultValue: 'Harare') as String;

    if (online) {
      try {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        final providers = await _providers.getProviders();
        final now = DateTime.now();
        await _writeCache(providers, city, now);
        return HomeSyncResult(
          providers: providers,
          city: city,
          lastUpdated: now,
          isOffline: false,
        );
      } catch (_) {
        final cached = _readCache();
        if (cached != null) {
          return HomeSyncResult(
            providers: cached.providers,
            city: cached.city,
            lastUpdated: cached.lastUpdated,
            isOffline: true,
          );
        }
        rethrow;
      }
    }

    final cached = _readCache();
    if (cached != null) {
      return HomeSyncResult(
        providers: cached.providers,
        city: cached.city,
        lastUpdated: cached.lastUpdated,
        isOffline: true,
      );
    }

    throw Exception('No network and no cached providers available.');
  }

  Future<void> saveCity(String city) async {
    await _box.put(_cacheCityKey, city);
  }

  /// Returns cached providers without triggering a network sync.
  List<ProviderModel>? readCachedProviders() => _readCache()?.providers;

  Future<void> _writeCache(
    List<ProviderModel> providers,
    String city,
    DateTime updated,
  ) async {
    final jsonList = providers.map((p) => p.toJson()).toList();
    await _box.put(_cacheProvidersKey, jsonEncode(jsonList));
    await _box.put(_cacheCityKey, city);
    await _box.put(_cacheUpdatedKey, updated.toIso8601String());
  }

  ({List<ProviderModel> providers, String city, DateTime lastUpdated})?
      _readCache() {
    final raw = _box.get(_cacheProvidersKey);
    if (raw == null) return null;

    try {
      final list = (jsonDecode(raw as String) as List<dynamic>)
          .map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final city = _box.get(_cacheCityKey, defaultValue: 'Harare') as String;
      final updatedRaw = _box.get(_cacheUpdatedKey) as String?;
      final updated = updatedRaw != null
          ? DateTime.parse(updatedRaw)
          : DateTime.now();
      return (providers: list, city: city, lastUpdated: updated);
    } catch (_) {
      return null;
    }
  }
}
