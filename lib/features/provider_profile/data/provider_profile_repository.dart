import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:smarthealth_shep/shared/data/provider_detail_catalog.dart';
import 'package:smarthealth_shep/shared/data/provider_repository.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

class ProviderProfileResult {
  const ProviderProfileResult({
    required this.provider,
    required this.fromCache,
    required this.isOffline,
  });

  final ProviderModel provider;
  final bool fromCache;
  final bool isOffline;
}

/// Local-first provider profile: SQLite cache → API.
class ProviderProfileRepository {
  ProviderProfileRepository({
    ProviderRepository? providerRepository,
    Connectivity? connectivity,
  })  : _providerRepository = providerRepository ?? ProviderRepository.defaults(),
        _connectivity = connectivity ?? Connectivity();

  final ProviderRepository _providerRepository;
  final Connectivity _connectivity;

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<ProviderModel?> _fromLocalCache(String id) =>
      _providerRepository.getById(id);

  Future<ProviderProfileResult?> fetchProfile(String id) async {
    final online = await _isOnline();
    final cached = await _fromLocalCache(id);

    if (online) {
      try {
        final remote = await _providerRepository.getDetailById(id);
        if (remote != null) {
          return ProviderProfileResult(
            provider: remote,
            fromCache: false,
            isOffline: false,
          );
        }
      } catch (_) {
        if (cached != null) {
          return ProviderProfileResult(
            provider: ProviderDetailCatalog.enrich(cached),
            fromCache: true,
            isOffline: true,
          );
        }
        rethrow;
      }
    }

    if (cached != null) {
      return ProviderProfileResult(
        provider: ProviderDetailCatalog.enrich(cached),
        fromCache: true,
        isOffline: !online,
      );
    }

    final local = _providerRepository.getDetailByIdLocal(id);
    if (local != null) {
      return ProviderProfileResult(
        provider: local,
        fromCache: true,
        isOffline: !online,
      );
    }

    return null;
  }
}
