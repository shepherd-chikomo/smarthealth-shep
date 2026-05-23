import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Local filter + search matching for cached providers.
abstract final class SearchFilterEngine {
  static List<ProviderModel> apply({
    required List<ProviderModel> providers,
    required String query,
    required Set<String> specialties,
    required Set<String> conditions,
    required Set<String> ageGroups,
  }) {
    return providers.where((provider) {
      if (!_matchesQuery(provider, query)) return false;
      if (!_matchesGroup(
        provider.specialtyId,
        specialties,
      )) {
        return false;
      }
      if (!_matchesListGroup(provider.conditions, conditions)) return false;
      if (!_matchesListGroup(provider.ageGroups, ageGroups)) return false;
      return true;
    }).toList();
  }

  static bool _matchesQuery(ProviderModel provider, String query) {
    if (query.trim().isEmpty) return true;
    final q = query.trim().toLowerCase();
    final haystack = [
      provider.name,
      provider.specialty,
      provider.facilityName,
      provider.address,
    ].whereType<String>().join(' ').toLowerCase();
    return haystack.contains(q);
  }

  /// OR within group; empty set = no filter.
  static bool _matchesGroup(String? value, Set<String> selected) {
    if (selected.isEmpty) return true;
    if (value == null) return false;
    return selected.contains(value);
  }

  static bool _matchesListGroup(List<String> values, Set<String> selected) {
    if (selected.isEmpty) return true;
    return values.any(selected.contains);
  }
}
