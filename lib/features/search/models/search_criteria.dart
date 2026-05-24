import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/features/search/models/search_sort_option.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
/// Applied search + filter criteria passed to directory results.
class SearchCriteria extends Equatable {
  const SearchCriteria({
    required this.query,
    required this.specialties,
    required this.conditions,
    required this.ageGroups,
    required this.operational,
    required this.results,
    this.isOffline = false,
    this.sortBy = SearchSortOption.distance,
  });
  final String query;
  final Set<String> specialties;
  final Set<String> conditions;
  final Set<String> ageGroups;
  final Set<String> operational;
  final List<ProviderModel> results;
  final bool isOffline;
  final SearchSortOption sortBy;
  bool get hasActiveFilters =>
      query.isNotEmpty ||
      specialties.isNotEmpty ||
      conditions.isNotEmpty ||
      ageGroups.isNotEmpty ||
      operational.isNotEmpty;

  @override
  List<Object?> get props => [
        query,
        specialties,
        conditions,
        ageGroups,
        operational,
        results,
        isOffline,
        sortBy,
      ];
}