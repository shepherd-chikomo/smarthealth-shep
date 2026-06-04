import 'package:smarthealth_shep/features/search/models/search_sort_option.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/utils/provider_operational_utils.dart';

/// Applies client-side sort to search result lists.
abstract final class SearchSortEngine {
  static List<ProviderModel> apply(
    List<ProviderModel> providers,
    SearchSortOption sort,
  ) {
    final sorted = List<ProviderModel>.from(providers);
    sorted.sort((a, b) => _compare(a, b, sort));
    return sorted;
  }

  static int _compare(
    ProviderModel a,
    ProviderModel b,
    SearchSortOption sort,
  ) {
    return switch (sort) {
      SearchSortOption.distance => _compareNullableDouble(
          a.distanceKm,
          b.distanceKm,
        ),
      SearchSortOption.availability => _compareAvailability(a, b),
      SearchSortOption.queueTime => _compareNullableInt(
          ProviderOperationalUtils.estimatedWaitMinutes(a),
          ProviderOperationalUtils.estimatedWaitMinutes(b),
        ),
      SearchSortOption.rating => _compareNullableDouble(
          b.rating,
          a.rating,
        ),
      SearchSortOption.mostReviewed => _compareNullableInt(
          b.reviewCount,
          a.reviewCount,
        ),
    };
  }

  static int _compareAvailability(ProviderModel a, ProviderModel b) {
    final scoreA = _availabilityScore(a);
    final scoreB = _availabilityScore(b);
    if (scoreA != scoreB) return scoreB.compareTo(scoreA);
    return _compareNullableDateTime(a.nextAvailableSlot, b.nextAvailableSlot);
  }

  static int _availabilityScore(ProviderModel provider) {
    var score = 0;
    if (provider.availableToday == true) score += 4;
    if (provider.isOpenNow == true) score += 3;
    if (provider.acceptsWalkIns == true) score += 2;
    if (provider.nextAvailableSlot != null) score += 1;
    return score;
  }

  static int _compareNullableDouble(double? a, double? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  static int _compareNullableInt(int? a, int? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  static int _compareNullableDateTime(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  static List<FacilityModel> applyFacilities(
    List<FacilityModel> facilities,
    SearchSortOption sort,
  ) {
    final sorted = List<FacilityModel>.from(facilities);
    if (sort == SearchSortOption.distance) {
      sorted.sort(
        (a, b) => _compareNullableDouble(a.distanceKm, b.distanceKm),
      );
    }
    return sorted;
  }
}
