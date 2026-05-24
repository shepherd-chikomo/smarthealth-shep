import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/utils/provider_operational_utils.dart';

/// Local filter + search matching for cached providers.
abstract final class SearchFilterEngine {
  static List<ProviderModel> apply({
    required List<ProviderModel> providers,
    required String query,
    required Set<String> specialties,
    required Set<String> conditions,
    required Set<String> ageGroups,
    Set<String> operational = const {},
  }) {
    return providers.where((provider) {
      if (!_matchesQuery(provider, query)) return false;
      if (!_matchesGroup(provider.specialtyId, specialties)) return false;
      if (!_matchesListGroup(provider.conditions, conditions)) return false;
      if (!_matchesListGroup(provider.ageGroups, ageGroups)) return false;
      if (!_matchesOperational(provider, operational)) return false;
      return true;
    }).toList();
  }

  static bool _matchesOperational(
    ProviderModel provider,
    Set<String> operational,
  ) {
    if (operational.isEmpty) return true;

    if (operational.contains('open_now') && provider.isOpenNow != true) {
      return false;
    }
    if (operational.contains('available_today') &&
        provider.availableToday != true) {
      return false;
    }
    if (operational.contains('walk_ins') && provider.acceptsWalkIns != true) {
      return false;
    }
    if (operational.contains('queue_under_30') &&
        !ProviderOperationalUtils.isQueueUnder30Minutes(provider)) {
      return false;
    }
    if (operational.contains('verified_only') && !provider.isVerified) {
      return false;
    }
    if (operational.contains('emergency') &&
        provider.emergencyAvailable != true) {
      return false;
    }
    return true;
  }

  static bool _matchesQuery(ProviderModel provider, String query) {
    if (query.trim().isEmpty) return true;

    final q = query.trim().toLowerCase();
    final fields = [
      provider.name,
      provider.specialty,
      provider.facilityName,
      provider.address,
    ].whereType<String>();

    for (final field in fields) {
      final lower = field.toLowerCase();
      if (lower.contains(q)) return true;
      if (_typoSimilarity(lower, q) >= 0.25) return true;
    }
    return false;
  }

  /// Approximates PostgreSQL pg_trgm similarity for offline fallback.
  static double _typoSimilarity(String a, String b) {
    if (a == b) return 1;
    if (a.contains(b) || b.contains(a)) return 0.8;

    final shorter = a.length <= b.length ? a : b;
    final longer = a.length <= b.length ? b : a;

    var matches = 0;
    for (var i = 0; i < shorter.length; i++) {
      if (longer.contains(shorter[i])) matches++;
    }
    return matches / longer.length;
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
