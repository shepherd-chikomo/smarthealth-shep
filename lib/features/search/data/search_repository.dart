import 'package:smarthealth_shep/features/search/data/search_filter_engine.dart';
import 'package:smarthealth_shep/shared/data/provider_repository.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/models/provider_search_filter.dart';

class SearchProvidersResult {
  const SearchProvidersResult({
    required this.providers,
    this.isOffline = false,
  });

  final List<ProviderModel> providers;
  final bool isOffline;
}

/// Ranked healthcare search — API-first with offline fallback.
class SearchRepository {
  SearchRepository({
    ProviderRepository? providerRepository,
  }) : _providerRepository = providerRepository ?? ProviderRepository.defaults();

  final ProviderRepository _providerRepository;

  /// Loads the full provider directory (for filter chip options).
  Future<SearchProvidersResult> loadProviders() async {
    final result = await _providerRepository.getProviders();
    return SearchProvidersResult(
      providers: result,
      isOffline: false,
    );
  }

  /// Executes ranked search against the healthcare search engine.
  Future<SearchProvidersResult> search({
    required String query,
    Set<String> specialties = const {},
    Set<String> conditions = const {},
    Set<String> ageGroups = const {},
    Set<String> operational = const {},
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? city,
    String? province,
  }) async {
    final filter = ProviderSearchFilter(
      query: query,
      specialties: specialties,
      conditions: conditions,
      ageGroups: ageGroups,
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      isVerified: operational.contains('verified_only') ? true : null,
      openNow: operational.contains('open_now') ? true : null,
      queueUnder30: operational.contains('queue_under_30') ? true : null,
      availableToday:
          operational.contains('available_today') ? true : null,
      acceptsWalkIns: operational.contains('walk_ins') ? true : null,
      emergencyAvailable: operational.contains('emergency') ? true : null,
      city: city,
      province: province,
    );

    if (filter.isEmpty) {
      final all = await loadProviders();
      return all;
    }

    try {
      final result = await _providerRepository.searchProviders(filter);
      return SearchProvidersResult(
        providers: result.providers,
        isOffline: result.isOffline,
      );
    } catch (_) {
      final cached = await loadProviders();
      final filtered = SearchFilterEngine.apply(
        providers: cached.providers,
        query: query,
        specialties: specialties,
        conditions: conditions,
        ageGroups: ageGroups,
        operational: operational,
      );
      return SearchProvidersResult(
        providers: filtered,
        isOffline: true,
      );
    }
  }
}
