import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Applied search + filter criteria passed to directory results.
class SearchCriteria extends Equatable {
  const SearchCriteria({
    required this.query,
    required this.specialties,
    required this.conditions,
    required this.ageGroups,
    required this.results,
    this.isOffline = false,
  });

  final String query;
  final Set<String> specialties;
  final Set<String> conditions;
  final Set<String> ageGroups;
  final List<ProviderModel> results;
  final bool isOffline;

  bool get hasActiveFilters =>
      query.isNotEmpty ||
      specialties.isNotEmpty ||
      conditions.isNotEmpty ||
      ageGroups.isNotEmpty;

  @override
  List<Object?> get props =>
      [query, specialties, conditions, ageGroups, results, isOffline];
}
