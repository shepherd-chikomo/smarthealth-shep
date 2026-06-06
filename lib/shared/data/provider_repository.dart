import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/exceptions/network_exception.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/core/sync/sync_providers.dart';
import 'package:smarthealth_shep/core/utils/haversine.dart';
import 'package:smarthealth_shep/shared/data/local/provider_dao.dart';
import 'package:smarthealth_shep/shared/data/mock_data.dart';
import 'package:smarthealth_shep/shared/data/provider_detail_catalog.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_service.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/models/provider_query_result.dart';
import 'package:smarthealth_shep/shared/models/provider_search_filter.dart';

const _logName = 'ProviderRepository';

final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProviderRepository(
    dao: ProviderDao(),
    api: ApiService(dio),
    syncService: ref.watch(syncServiceProvider),
    seedMockDataOnEmpty: AppConfig.seedMockDataOnEmpty,
  );
});

/// Offline-first provider directory backed by SQLite and remote API.
class ProviderRepository {
  ProviderRepository({
    required ProviderDao dao,
    required ApiService api,
    required SyncService syncService,
    this.seedMockDataOnEmpty = false,
  })  : _dao = dao,
        _api = api,
        _syncService = syncService;

  /// Default wiring for callers outside Riverpod (e.g. legacy repositories).
  factory ProviderRepository.defaults({SyncService? syncService}) {
    return ProviderRepository(
      dao: ProviderDao(),
      api: ApiService(createApiDio()),
      syncService: syncService ?? SyncService.instance ?? SyncService.forBackground(),
      seedMockDataOnEmpty: AppConfig.seedMockDataOnEmpty,
    );
  }

  final ProviderDao _dao;
  final ApiService _api;
  final SyncService _syncService;

  /// Seeds mock catalog into SQLite when the local store is empty (dev fallback).
  final bool seedMockDataOnEmpty;

  // ---------------------------------------------------------------------------
  // Offline-first API
  // ---------------------------------------------------------------------------

  Future<ProvidersQueryResult> getNearbyProviders({
    required double lat,
    required double lon,
    required double radiusKm,
  }) async {
    await _ensureSeeded();

    try {
      final lastSync = await _dao.getLastSync();
      developer.log(
        'Fetching nearby providers from API (since=$lastSync)',
        name: _logName,
      );

      final remote = await _api.fetchNearbyProviders(
        lat: lat,
        lon: lon,
        radiusKm: radiusKm,
        since: lastSync,
      );

      await _dao.upsertProviders(remote);
      await _dao.setLastSync(DateTime.now().toUtc());

      final withDistance = remote
          .where((p) => p.latitude != null && p.longitude != null)
          .map((p) {
        final distance = p.distanceKm ??
            _distanceFrom(lat, lon, p.latitude!, p.longitude!);
        return p.copyWith(distanceKm: distance);
      }).where((p) => (p.distanceKm ?? double.infinity) <= radiusKm).toList()
        ..sort(
          (a, b) => (a.distanceKm ?? double.infinity)
              .compareTo(b.distanceKm ?? double.infinity),
        );

      return ProvidersQueryResult(providers: withDistance, isOffline: false);
    } on NetworkException catch (error, stackTrace) {
      developer.log(
        'Network unavailable — falling back to local nearby query',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );

      final local = await _dao.getNearby(lat, lon, radiusKm);
      if (local.isEmpty) {
        throw NetworkException(
          'No network and no cached providers available.',
          cause: error,
        );
      }
      return ProvidersQueryResult(providers: local, isOffline: true);
    }
  }

  Future<ProvidersQueryResult> searchProviders(
    ProviderSearchFilter filter,
  ) async {
    await _ensureSeeded();

    try {
      developer.log('Searching providers via ranked search API', name: _logName);
      final remote = await _api.searchProviders(filter);
      await _dao.upsertProviders(remote);
      await _dao.setLastSync(DateTime.now().toUtc());
      return ProvidersQueryResult(providers: remote, isOffline: false);
    } on NetworkException catch (error, stackTrace) {
      developer.log(
        'Search API unavailable — falling back to local cache',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      final local = await _dao.search(filter);
      if (local.isEmpty) {
        throw NetworkException(
          'No network and no cached providers for this search.',
          cause: error,
        );
      }
      return ProvidersQueryResult(providers: local, isOffline: true);
    }
  }

  Future<ProviderDetailQueryResult?> getProviderById(String id) async {
    await _ensureSeeded();

    final local = await _dao.getById(id);
    final stale = await _dao.isStale(id);

    if (local != null && !stale) {
      return ProviderDetailQueryResult(
        provider: local,
        isOffline: true,
        fromCache: true,
      );
    }

    try {
      developer.log('Fetching provider $id from API', name: _logName);
      final remote = await _api.getProviderById(id);
      if (remote == null) {
        return local != null
            ? ProviderDetailQueryResult(
                provider: local,
                isOffline: true,
                fromCache: true,
              )
            : null;
      }

      await _dao.upsertProvider(remote);
      return ProviderDetailQueryResult(
        provider: remote,
        isOffline: false,
        fromCache: false,
      );
    } on NetworkException catch (error, stackTrace) {
      developer.log(
        'Network unavailable — returning cached provider $id',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );

      if (local != null) {
        return ProviderDetailQueryResult(
          provider: local,
          isOffline: true,
          fromCache: true,
        );
      }
      return null;
    }
  }

  /// Delta sync against the remote API; safe to call from background jobs.
  Future<void> syncProviders() => _performDeltaSync();

  void scheduleBackgroundSync() {
    _syncService.schedule('provider-sync', syncProviders);
  }

  /// Triggers a full delta sync cycle (pull-to-refresh).
  Future<void> refreshFromServer() => _syncService.syncPullToRefresh();

  // ---------------------------------------------------------------------------
  // Legacy helpers (mock / Hive callers)
  // ---------------------------------------------------------------------------

  Future<List<ProviderModel>> getProviders({String? categoryId}) async {
    await _ensureSeeded();
    final local = await _dao.getAll(categoryId: categoryId);
    if (local.isNotEmpty) return local;
    if (seedMockDataOnEmpty) {
      return _mockProviders(categoryId: categoryId);
    }
    return [];
  }

  Future<ProviderModel?> getById(String id) async {
    final result = await getProviderById(id);
    return result?.provider;
  }

  Future<ProviderModel?> getDetailById(String id) async {
    final result = await getProviderById(id);
    if (result == null) return null;
    return ProviderDetailCatalog.enrich(result.provider);
  }

  ProviderModel? getDetailByIdLocal(String id) {
    if (!seedMockDataOnEmpty) return null;
    for (final provider in MockData.providers) {
      if (provider.id == id) {
        return ProviderDetailCatalog.enrich(provider);
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<void> _performDeltaSync() async {
    await _ensureSeeded();

    final since = await _dao.getLastSync();
    developer.log(
      'Starting provider delta sync (since=$since)',
      name: _logName,
    );

    try {
      final payload = await _api.syncProviders(since: since);
      await _dao.upsertProviders(payload.updated);
      await _dao.deleteProviders(payload.deletedIds);
      await _dao.setLastSync(payload.syncedAt);

      developer.log(
        'Provider sync complete: ${payload.updated.length} updated, '
        '${payload.deletedIds.length} deleted',
        name: _logName,
      );
    } on NetworkException catch (error, stackTrace) {
      developer.log(
        'Provider sync failed',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _ensureSeeded() async {
    if (!seedMockDataOnEmpty) return;

    final existing = await _dao.getAll();
    if (existing.isNotEmpty) return;

    developer.log('Seeding local provider cache from mock data', name: _logName);
    await _dao.upsertProviders(MockData.providers);
  }

  List<ProviderModel> _mockProviders({String? categoryId}) {
    final all = MockData.providers;
    if (categoryId == null) return all;
    return all.where((p) => p.categoryId == categoryId).toList();
  }

  double _distanceFrom(double lat, double lon, double pLat, double pLon) {
    return haversineDistanceKm(lat, lon, pLat, pLon);
  }
}
