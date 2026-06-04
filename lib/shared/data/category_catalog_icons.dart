import 'package:smarthealth_shep/core/assets.dart';

/// Maps database facility_type values to bundled category artwork.
abstract final class CategoryCatalogIcons {
  static const nearMe = ServiceCategoryIcon(
    id: 'near_me',
    iconAsset: AppAssets.categoryNearMe,
  );

  static String iconAssetForFacilityType(String facilityType) {
    return switch (facilityType) {
      'hospital' => AppAssets.categoryGp,
      'clinic' => AppAssets.categoryGp,
      'pharmacy' => AppAssets.categoryPharmacy,
      'laboratory' => AppAssets.categoryLab,
      'dental' => AppAssets.categoryDentist,
      'optometry' => AppAssets.categorySpecialist,
      'imaging' => AppAssets.categorySpecialist,
      _ => AppAssets.categorySpecialist,
    };
  }
}

class ServiceCategoryIcon {
  const ServiceCategoryIcon({required this.id, required this.iconAsset});

  final String id;
  final String iconAsset;
}
