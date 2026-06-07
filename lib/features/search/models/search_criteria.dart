import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/features/search/models/search_sort_option.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Applied search + filter criteria passed to directory results.
class SearchCriteria extends Equatable {
  const SearchCriteria({
    required this.query,
    required this.specialties,
    required this.conditions,
    required this.ageGroups,
    required this.operational,
    required this.providers,
    required this.facilities,
    this.medicalAidSchemes = const {},
    this.acceptsMyMedicalAid = false,
    this.userMedicalAidSchemeKey,
    this.isOffline = false,
    this.sortBy = SearchSortOption.distance,
  });

  final String query;
  final Set<String> specialties;
  final Set<String> conditions;
  final Set<String> ageGroups;
  final Set<String> operational;
  final Set<String> medicalAidSchemes;
  final bool acceptsMyMedicalAid;
  final String? userMedicalAidSchemeKey;
  final List<ProviderModel> providers;
  final List<FacilityModel> facilities;
  final bool isOffline;
  final SearchSortOption sortBy;

  int get totalCount => providers.length + facilities.length;

  bool get hasActiveCriteria =>
      query.isNotEmpty ||
      specialties.isNotEmpty ||
      conditions.isNotEmpty ||
      ageGroups.isNotEmpty ||
      operational.isNotEmpty ||
      medicalAidSchemes.isNotEmpty ||
      acceptsMyMedicalAid;

  @override
  List<Object?> get props => [
        query,
        specialties,
        conditions,
        ageGroups,
        operational,
        medicalAidSchemes,
        acceptsMyMedicalAid,
        userMedicalAidSchemeKey,
        providers,
        facilities,
        isOffline,
        sortBy,
      ];
}
