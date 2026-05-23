import 'package:smarthealth_shep/core/assets.dart';

/// Search/home category metadata aligned with bundled SVG icons.
class AppCategory {
  const AppCategory({
    required this.id,
    required this.labelKey,
    required this.iconAsset,
  });

  final String id;
  final String labelKey;
  final String iconAsset;
}

/// Category chips shown on Home and Search filters.
const categories = <AppCategory>[
  AppCategory(id: 'near_me', labelKey: 'nearMe', iconAsset: AppAssets.categoryGp),
  AppCategory(
    id: 'general',
    labelKey: 'generalPractice',
    iconAsset: AppAssets.categoryGp,
  ),
  AppCategory(
    id: 'pediatrics',
    labelKey: 'pediatrics',
    iconAsset: AppAssets.categoryPediatric,
  ),
  AppCategory(
    id: 'dental',
    labelKey: 'dental',
    iconAsset: AppAssets.categoryDentist,
  ),
  AppCategory(
    id: 'cardiology',
    labelKey: 'cardiology',
    iconAsset: AppAssets.categorySpecialist,
  ),
  AppCategory(id: 'more', labelKey: 'more', iconAsset: AppAssets.categoryLab),
];

/// Full directory taxonomy used in search/browse.
const directoryCategories = <AppCategory>[
  AppCategory(id: 'gp', labelKey: 'generalPractice', iconAsset: AppAssets.categoryGp),
  AppCategory(id: 'dentist', labelKey: 'dental', iconAsset: AppAssets.categoryDentist),
  AppCategory(
    id: 'pharmacy',
    labelKey: 'pharmacy',
    iconAsset: AppAssets.categoryPharmacy,
  ),
  AppCategory(id: 'lab', labelKey: 'lab', iconAsset: AppAssets.categoryLab),
  AppCategory(
    id: 'pediatric',
    labelKey: 'pediatrics',
    iconAsset: AppAssets.categoryPediatric,
  ),
  AppCategory(
    id: 'specialist',
    labelKey: 'specialist',
    iconAsset: AppAssets.categorySpecialist,
  ),
  AppCategory(
    id: 'emergency',
    labelKey: 'emergency',
    iconAsset: AppAssets.categoryEmergency,
  ),
];

AppCategory? categoryById(String id) {
  for (final category in [...categories, ...directoryCategories]) {
    if (category.id == id) return category;
  }
  return null;
}
