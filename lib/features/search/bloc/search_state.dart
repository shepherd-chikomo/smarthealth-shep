import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/features/search/models/search_criteria.dart';
import 'package:smarthealth_shep/features/search/models/search_sort_option.dart';
import 'package:smarthealth_shep/features/search/search_filter_options.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

enum SearchStatus { initial, loading, ready, error }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.specialties = const {},
    this.conditions = const {},
    this.ageGroups = const {},
    this.operational = const {},
    this.medicalAidSchemes = const {},
    this.acceptsMyMedicalAid = false,
    this.userMedicalAidSchemeKey,
    this.sortBy = SearchSortOption.distance,
    this.allProviders = const [],
    this.filteredProviders = const [],
    this.allFacilities = const [],
    this.filteredFacilities = const [],
    this.specialtyFilterOptions = const [],
    this.conditionFilterOptions = const [],
    this.ageGroupFilterOptions = const [],
    this.recentSearches = const [],
    this.isOffline = false,
    this.errorMessage,
    this.navigateToResults = false,
  });

  final SearchStatus status;
  final String query;
  final Set<String> specialties;
  final Set<String> conditions;
  final Set<String> ageGroups;
  final Set<String> operational;
  final Set<String> medicalAidSchemes;
  final bool acceptsMyMedicalAid;
  final String? userMedicalAidSchemeKey;
  final SearchSortOption sortBy;
  final List<ProviderModel> allProviders;
  final List<ProviderModel> filteredProviders;
  final List<FacilityModel> allFacilities;
  final List<FacilityModel> filteredFacilities;
  final List<SearchFilterOption> specialtyFilterOptions;
  final List<SearchFilterOption> conditionFilterOptions;
  final List<SearchFilterOption> ageGroupFilterOptions;
  final List<String> recentSearches;
  final bool isOffline;
  final String? errorMessage;
  final bool navigateToResults;

  int get resultsCount => filteredProviders.length + filteredFacilities.length;

  bool get hasActiveCriteria =>
      query.trim().isNotEmpty ||
      specialties.isNotEmpty ||
      conditions.isNotEmpty ||
      ageGroups.isNotEmpty ||
      operational.isNotEmpty ||
      medicalAidSchemes.isNotEmpty ||
      acceptsMyMedicalAid;

  SearchCriteria get criteria => SearchCriteria(
        query: query,
        specialties: specialties,
        conditions: conditions,
        ageGroups: ageGroups,
        operational: operational,
        medicalAidSchemes: medicalAidSchemes,
        acceptsMyMedicalAid: acceptsMyMedicalAid,
        userMedicalAidSchemeKey: userMedicalAidSchemeKey,
        providers: filteredProviders,
        facilities: filteredFacilities,
        isOffline: isOffline,
        sortBy: sortBy,
      );

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    Set<String>? specialties,
    Set<String>? conditions,
    Set<String>? ageGroups,
    Set<String>? operational,
    Set<String>? medicalAidSchemes,
    bool? acceptsMyMedicalAid,
    String? userMedicalAidSchemeKey,
    SearchSortOption? sortBy,
    List<ProviderModel>? allProviders,
    List<ProviderModel>? filteredProviders,
    List<FacilityModel>? allFacilities,
    List<FacilityModel>? filteredFacilities,
    List<SearchFilterOption>? specialtyFilterOptions,
    List<SearchFilterOption>? conditionFilterOptions,
    List<SearchFilterOption>? ageGroupFilterOptions,
    List<String>? recentSearches,
    bool? isOffline,
    String? errorMessage,
    bool? navigateToResults,
    bool clearError = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      specialties: specialties ?? this.specialties,
      conditions: conditions ?? this.conditions,
      ageGroups: ageGroups ?? this.ageGroups,
      operational: operational ?? this.operational,
      medicalAidSchemes: medicalAidSchemes ?? this.medicalAidSchemes,
      acceptsMyMedicalAid: acceptsMyMedicalAid ?? this.acceptsMyMedicalAid,
      userMedicalAidSchemeKey:
          userMedicalAidSchemeKey ?? this.userMedicalAidSchemeKey,
      sortBy: sortBy ?? this.sortBy,
      allProviders: allProviders ?? this.allProviders,
      filteredProviders: filteredProviders ?? this.filteredProviders,
      allFacilities: allFacilities ?? this.allFacilities,
      filteredFacilities: filteredFacilities ?? this.filteredFacilities,
      specialtyFilterOptions:
          specialtyFilterOptions ?? this.specialtyFilterOptions,
      conditionFilterOptions:
          conditionFilterOptions ?? this.conditionFilterOptions,
      ageGroupFilterOptions:
          ageGroupFilterOptions ?? this.ageGroupFilterOptions,
      recentSearches: recentSearches ?? this.recentSearches,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      navigateToResults: navigateToResults ?? this.navigateToResults,
    );
  }

  @override
  List<Object?> get props => [
        status,
        query,
        specialties,
        conditions,
        ageGroups,
        operational,
        medicalAidSchemes,
        acceptsMyMedicalAid,
        userMedicalAidSchemeKey,
        sortBy,
        allProviders,
        filteredProviders,
        allFacilities,
        filteredFacilities,
        specialtyFilterOptions,
        conditionFilterOptions,
        ageGroupFilterOptions,
        recentSearches,
        isOffline,
        errorMessage,
        navigateToResults,
      ];
}
