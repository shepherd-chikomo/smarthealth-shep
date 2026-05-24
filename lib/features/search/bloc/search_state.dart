import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/features/search/models/search_criteria.dart';
import 'package:smarthealth_shep/features/search/models/search_sort_option.dart';
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
    this.sortBy = SearchSortOption.distance,
    this.allProviders = const [],
    this.filteredProviders = const [],
    this.recentSearches = const [],
    this.isOffline = false,    this.errorMessage,
    this.navigateToResults = false,
  });

  final SearchStatus status;
  final String query;
  final Set<String> specialties;
  final Set<String> conditions;
  final Set<String> ageGroups;
  final Set<String> operational;
  final SearchSortOption sortBy;
  final List<ProviderModel> allProviders;
  final List<ProviderModel> filteredProviders;
  final List<String> recentSearches;
  final bool isOffline;  final String? errorMessage;
  final bool navigateToResults;

  int get resultsCount => filteredProviders.length;

  bool get hasActiveCriteria =>
      query.trim().isNotEmpty ||
      specialties.isNotEmpty ||
      conditions.isNotEmpty ||
      ageGroups.isNotEmpty ||
      operational.isNotEmpty;

  SearchCriteria get criteria => SearchCriteria(
        query: query,
        specialties: specialties,
        conditions: conditions,
        ageGroups: ageGroups,
        results: filteredProviders,
        isOffline: isOffline,
        operational: operational,
        sortBy: sortBy,
      );
  SearchState copyWith({
    SearchStatus? status,
    String? query,
    Set<String>? specialties,
    Set<String>? conditions,
    Set<String>? ageGroups,
    Set<String>? operational,
    SearchSortOption? sortBy,
    List<ProviderModel>? allProviders,
    List<ProviderModel>? filteredProviders,
    List<String>? recentSearches,
    bool? isOffline,    String? errorMessage,
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
      sortBy: sortBy ?? this.sortBy,
      allProviders: allProviders ?? this.allProviders,
      filteredProviders: filteredProviders ?? this.filteredProviders,
      recentSearches: recentSearches ?? this.recentSearches,
      isOffline: isOffline ?? this.isOffline,      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
        sortBy,
        allProviders,
        filteredProviders,
        recentSearches,
        isOffline,        errorMessage,
        navigateToResults,
      ];
}
