import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/features/search/models/search_criteria.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

enum SearchStatus { initial, loading, ready, error }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.specialties = const {},
    this.conditions = const {},
    this.ageGroups = const {},
    this.allProviders = const [],
    this.filteredProviders = const [],
    this.isOffline = false,
    this.errorMessage,
    this.navigateToResults = false,
  });

  final SearchStatus status;
  final String query;
  final Set<String> specialties;
  final Set<String> conditions;
  final Set<String> ageGroups;
  final List<ProviderModel> allProviders;
  final List<ProviderModel> filteredProviders;
  final bool isOffline;
  final String? errorMessage;
  final bool navigateToResults;

  int get resultsCount => filteredProviders.length;

  SearchCriteria get criteria => SearchCriteria(
        query: query,
        specialties: specialties,
        conditions: conditions,
        ageGroups: ageGroups,
        results: filteredProviders,
        isOffline: isOffline,
      );

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    Set<String>? specialties,
    Set<String>? conditions,
    Set<String>? ageGroups,
    List<ProviderModel>? allProviders,
    List<ProviderModel>? filteredProviders,
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
      allProviders: allProviders ?? this.allProviders,
      filteredProviders: filteredProviders ?? this.filteredProviders,
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
        allProviders,
        filteredProviders,
        isOffline,
        errorMessage,
        navigateToResults,
      ];
}
