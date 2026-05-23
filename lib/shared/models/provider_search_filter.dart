import 'package:equatable/equatable.dart';

/// Local and remote provider search criteria.
class ProviderSearchFilter extends Equatable {
  const ProviderSearchFilter({
    this.query = '',
    this.categoryId,
    this.specialtyId,
    this.specialties = const {},
    this.conditions = const {},
    this.ageGroups = const {},
    this.latitude,
    this.longitude,
    this.radiusKm,
  });

  final String query;
  final String? categoryId;
  final String? specialtyId;
  final Set<String> specialties;
  final Set<String> conditions;
  final Set<String> ageGroups;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;

  bool get isEmpty =>
      query.trim().isEmpty &&
      categoryId == null &&
      specialtyId == null &&
      specialties.isEmpty &&
      conditions.isEmpty &&
      ageGroups.isEmpty &&
      latitude == null &&
      longitude == null &&
      radiusKm == null;

  ProviderSearchFilter copyWith({
    String? query,
    String? categoryId,
    String? specialtyId,
    Set<String>? specialties,
    Set<String>? conditions,
    Set<String>? ageGroups,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) {
    return ProviderSearchFilter(
      query: query ?? this.query,
      categoryId: categoryId ?? this.categoryId,
      specialtyId: specialtyId ?? this.specialtyId,
      specialties: specialties ?? this.specialties,
      conditions: conditions ?? this.conditions,
      ageGroups: ageGroups ?? this.ageGroups,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }

  @override
  List<Object?> get props => [
        query,
        categoryId,
        specialtyId,
        specialties,
        conditions,
        ageGroups,
        latitude,
        longitude,
        radiusKm,
      ];
}
