import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/auth/patient_profile.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/location/location_providers.dart';
import 'package:smarthealth_shep/core/location/search_origin_resolver.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/features/family/data/family_repository.dart';
import 'package:smarthealth_shep/features/home/providers/home_medical_summary_provider.dart';
import 'package:smarthealth_shep/features/profile/utils/user_medical_aid_resolver.dart';
import 'package:smarthealth_shep/core/directory/directory_search_service.dart';
import 'package:smarthealth_shep/features/search/data/search_filter_engine.dart';
import 'package:smarthealth_shep/features/search/search_filter_options.dart';
import 'package:smarthealth_shep/shared/data/provider_repository.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/models/provider_search_filter.dart';
import 'package:smarthealth_shep/shared/models/specialty_model.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SearchRepository(
    providerRepository: ref.watch(providerRepositoryProvider),
    api: ApiService(dio),
    searchOrigin: ref.watch(searchOriginResolverProvider),
    familyRepository: ref.watch(familyRepositoryProvider),
    patientProfileLoader: () => ref.read(patientProfileProvider.future),
  );
});

class SearchDiscoveryResult {
  const SearchDiscoveryResult({
    required this.providers,
    required this.facilities,
    required this.specialtyFilters,
    required this.conditionFilters,
    required this.ageGroupFilters,
    this.isOffline = false,
  });

  final List<ProviderModel> providers;
  final List<FacilityModel> facilities;
  final List<SearchFilterOption> specialtyFilters;
  final List<SearchFilterOption> conditionFilters;
  final List<SearchFilterOption> ageGroupFilters;
  final bool isOffline;
}

class SearchQueryResult {
  const SearchQueryResult({
    required this.providers,
    required this.facilities,
    this.isOffline = false,
  });

  final List<ProviderModel> providers;
  final List<FacilityModel> facilities;
  final bool isOffline;
}

/// Ranked healthcare search — API-first with offline fallback.
class SearchRepository {
  SearchRepository({
    required ProviderRepository providerRepository,
    required ApiService api,
    required SearchOriginResolver searchOrigin,
    required FamilyRepository familyRepository,
    required Future<PatientProfile?> Function() patientProfileLoader,
    DirectorySearchService? directorySearch,
  })  : _providerRepository = providerRepository,
        _client = api,
        _searchOrigin = searchOrigin,
        _familyRepository = familyRepository,
        _patientProfileLoader = patientProfileLoader,
        _directorySearch = directorySearch ?? DirectorySearchService();

  final ProviderRepository _providerRepository;
  final ApiService _client;
  final SearchOriginResolver _searchOrigin;
  final FamilyRepository _familyRepository;
  final Future<PatientProfile?> Function() _patientProfileLoader;
  final DirectorySearchService _directorySearch;

  Future<String?> getUserMedicalAidSchemeKey() async {
    final members = await _familyRepository.loadMembers(syncRemote: false);
    final patient = await _patientProfileLoader();
    return resolveUserMedicalAidSchemeKey(members: members, patient: patient);
  }

  Set<String> _effectiveMedicalAidFilterKeys({
    required Set<String> medicalAidSchemes,
    required bool acceptsMyMedicalAid,
    String? userMedicalAidSchemeKey,
  }) {
    final keys = Set<String>.from(medicalAidSchemes);
    if (acceptsMyMedicalAid &&
        userMedicalAidSchemeKey != null &&
        userMedicalAidSchemeKey.isNotEmpty) {
      keys.add(userMedicalAidSchemeKey);
    }
    return keys;
  }

  ProviderSearchFilter _defaultGeoFilter(
    ProviderSearchFilter filter, {
    required double lat,
    required double lon,
  }) {
    return filter.copyWith(
      latitude: filter.latitude ?? lat,
      longitude: filter.longitude ?? lon,
      radiusKm: filter.radiusKm ?? AppConfig.defaultSearchRadiusKm,
    );
  }

  List<SearchFilterOption> _toFilterOptions(
    List<({String id, String label})> items,
  ) {
    return items
        .map((item) => SearchFilterOption(id: item.id, label: item.label))
        .toList();
  }

  /// Initial search screen data: catalog filters, nearby facilities, providers.
  Future<SearchDiscoveryResult> loadDiscovery({bool refreshOrigin = true}) async {
    var isOffline = false;
    Object? lastError;

    final origin = await _searchOrigin.resolve(refreshGps: refreshOrigin);

    List<SpecialtyModel> specialtyModels = const [];
    try {
      specialtyModels = await _client.fetchCatalogSpecialties(limit: 30);
    } catch (error) {
      isOffline = true;
      lastError = error;
    }

    List<({String id, String label})> conditions = const [];
    try {
      conditions = await _client.fetchCatalogConditions();
    } catch (error) {
      isOffline = true;
      lastError = error;
    }

    List<({String id, String label})> ageGroups = const [];
    try {
      ageGroups = await _client.fetchCatalogAgeGroups();
    } catch (error) {
      isOffline = true;
      lastError = error;
    }

    List<FacilityModel> facilities = const [];
    try {
      facilities = await _client.fetchNearbyFacilities(
        lat: origin.latitude,
        lon: origin.longitude,
        radiusKm: AppConfig.defaultSearchRadiusKm,
        limit: 50,
      );
    } catch (error) {
      isOffline = true;
      lastError = error;
    }

    List<ProviderModel> providers = const [];
    try {
      final filter = _defaultGeoFilter(
        const ProviderSearchFilter(),
        lat: origin.latitude,
        lon: origin.longitude,
      );
      final providerResult = await _providerRepository.searchProviders(filter);
      providers = providerResult.providers;
      isOffline = isOffline || providerResult.isOffline;
    } catch (error) {
      isOffline = true;
      lastError = error;
      try {
        providers = await _providerRepository.getProviders();
      } catch (_) {
        // No local cache — providers stay empty.
      }
    }

    if (facilities.isEmpty &&
        providers.isEmpty &&
        specialtyModels.isEmpty) {
      if (AppConfig.allowMockFallbacks) {
        final all = await _providerRepository.getProviders();
        return SearchDiscoveryResult(
          providers: all,
          facilities: const [],
          specialtyFilters: SearchFilterOptions.specialties,
          conditionFilters: SearchFilterOptions.conditions,
          ageGroupFilters: SearchFilterOptions.ageGroups,
          isOffline: true,
        );
      }
      Error.throwWithStackTrace(
        lastError ?? Exception('Search discovery failed'),
        StackTrace.current,
      );
    }

    return SearchDiscoveryResult(
      providers: providers,
      facilities: facilities,
      specialtyFilters: specialtyModels.isNotEmpty
          ? specialtyModels
              .map((s) => SearchFilterOption(id: s.slug, label: s.name))
              .toList()
          : SearchFilterOptions.specialties,
      conditionFilters: conditions.isNotEmpty
          ? _toFilterOptions(conditions)
          : SearchFilterOptions.conditions,
      ageGroupFilters: ageGroups.isNotEmpty
          ? _toFilterOptions(ageGroups)
          : SearchFilterOptions.ageGroups,
      isOffline: isOffline,
    );
  }

  /// Executes ranked search against providers and facilities APIs.
  Future<SearchQueryResult> search({
    required String query,
    Set<String> specialties = const {},
    Set<String> conditions = const {},
    Set<String> ageGroups = const {},
    Set<String> operational = const {},
    Set<String> medicalAidSchemes = const {},
    bool acceptsMyMedicalAid = false,
    String? userMedicalAidSchemeKey,
    String? facilityType,
    bool refreshOrigin = false,
  }) async {
    final origin = await _searchOrigin.resolve(refreshGps: refreshOrigin);

    final medicalAidKeys = _effectiveMedicalAidFilterKeys(
      medicalAidSchemes: medicalAidSchemes,
      acceptsMyMedicalAid: acceptsMyMedicalAid,
      userMedicalAidSchemeKey: userMedicalAidSchemeKey,
    );

    var filter = ProviderSearchFilter(
      query: query,
      specialties: specialties,
      conditions: conditions,
      ageGroups: ageGroups,
      facilityType: facilityType,
      latitude: origin.latitude,
      longitude: origin.longitude,
      radiusKm: AppConfig.defaultSearchRadiusKm,
      isVerified: operational.contains('verified_only') ? true : null,
      openNow: operational.contains('open_now') ? true : null,
      queueUnder30: operational.contains('queue_under_30') ? true : null,
      availableToday:
          operational.contains('available_today') ? true : null,
      acceptsWalkIns: operational.contains('walk_ins') ? true : null,
      emergencyAvailable: operational.contains('emergency') ? true : null,
      medicalAidSchemeKeys: medicalAidKeys,
      userMedicalAidSchemeKey: userMedicalAidSchemeKey,
    );

    filter = _defaultGeoFilter(
      filter,
      lat: origin.latitude,
      lon: origin.longitude,
    );

    if (filter.isEmpty) {
      final discovery = await loadDiscovery(refreshOrigin: false);
      return SearchQueryResult(
        providers: discovery.providers,
        facilities: discovery.facilities,
        isOffline: discovery.isOffline,
      );
    }

    if (query.trim().isNotEmpty) {
      final local = await _directorySearch.searchLocal(query: query);
      if (local.facilities.isNotEmpty || local.providers.isNotEmpty) {
        final filteredProviders = SearchFilterEngine.apply(
          providers: local.providers,
          query: query,
          specialties: specialties,
          conditions: conditions,
          ageGroups: ageGroups,
          operational: operational,
        );
        final filteredFacilities = SearchFilterEngine.applyFacilities(
          facilities: local.facilities,
          query: query,
          facilityType: facilityType,
          medicalAidSchemeKeys: medicalAidKeys,
        );
        if (filteredProviders.isNotEmpty || filteredFacilities.isNotEmpty) {
          return SearchQueryResult(
            providers: filteredProviders,
            facilities: filteredFacilities,
            isOffline: false,
          );
        }
      }
    }

    try {
      final providerResult = await _providerRepository.searchProviders(filter);
      final facilities = await _client.searchFacilities(filter);
      return SearchQueryResult(
        providers: providerResult.providers,
        facilities: facilities,
        isOffline: providerResult.isOffline,
      );
    } catch (_) {
      final cached = await loadDiscovery(refreshOrigin: false);
      final filteredProviders = SearchFilterEngine.apply(
        providers: cached.providers,
        query: query,
        specialties: specialties,
        conditions: conditions,
        ageGroups: ageGroups,
        operational: operational,
      );
      final filteredFacilities = SearchFilterEngine.applyFacilities(
        facilities: cached.facilities,
        query: query,
        facilityType: facilityType,
        medicalAidSchemeKeys: medicalAidKeys,
      );
      return SearchQueryResult(
        providers: filteredProviders,
        facilities: filteredFacilities,
        isOffline: true,
      );
    }
  }
}
