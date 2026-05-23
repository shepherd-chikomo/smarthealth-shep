import 'package:smarthealth_shep/features/home/data/home_repository.dart';
import 'package:smarthealth_shep/shared/data/provider_repository.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

class SearchProvidersResult {
  const SearchProvidersResult({
    required this.providers,
    required this.isOffline,
  });

  final List<ProviderModel> providers;
  final bool isOffline;
}

/// Loads provider directory from cache (offline-first) or network fallback.
class SearchRepository {
  SearchRepository({
    HomeRepository? homeRepository,
    ProviderRepository? providerRepository,
  })  : _homeRepository = homeRepository ?? HomeRepository(),
        _providerRepository = providerRepository ?? ProviderRepository();

  final HomeRepository _homeRepository;
  final ProviderRepository _providerRepository;

  Future<SearchProvidersResult> loadProviders() async {
    try {
      final sync = await _homeRepository.sync();
      return SearchProvidersResult(
        providers: sync.providers,
        isOffline: sync.isOffline,
      );
    } catch (_) {
      final cached = _homeRepository.readCachedProviders();
      if (cached != null && cached.isNotEmpty) {
        return SearchProvidersResult(
          providers: cached,
          isOffline: true,
        );
      }
      final fallback = await _providerRepository.getProviders();
      return SearchProvidersResult(
        providers: fallback,
        isOffline: true,
      );
    }
  }
}
