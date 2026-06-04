/// Home dashboard category tile (from catalog API or local near-me).
class ServiceCategoryModel {
  const ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.iconAsset,
    this.count,
    this.isNearMe = false,
  });

  /// `near_me` or a [facilityType] value from the database.
  final String id;
  final String name;
  final String iconAsset;
  final int? count;
  final bool isNearMe;
}
