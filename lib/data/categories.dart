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

/// Service-type tiles on the home dashboard.
const homeServiceCategories = <AppCategory>[
  AppCategory(
    id: 'near_me',
    labelKey: 'nearMe',
    iconAsset: AppAssets.categoryNearMe,
  ),
  AppCategory(
    id: 'general',
    labelKey: 'general',
    iconAsset: AppAssets.categoryGp,
  ),
  AppCategory(
    id: 'dental',
    labelKey: 'dental',
    iconAsset: AppAssets.categoryDentist,
  ),
  AppCategory(
    id: 'pharmacy',
    labelKey: 'pharmacy',
    iconAsset: AppAssets.categoryPharmacy,
  ),
  AppCategory(
    id: 'lab',
    labelKey: 'lab',
    iconAsset: AppAssets.categoryLab,
  ),
  AppCategory(
    id: 'pediatrics',
    labelKey: 'pediatrics',
    iconAsset: AppAssets.categoryPediatric,
  ),
  AppCategory(
    id: 'specialist',
    labelKey: 'specialist',
    iconAsset: AppAssets.categorySpecialist,
  ),
];

/// Legacy horizontal chips (search filters).
const categories = homeServiceCategories;

/// Full directory taxonomy used in search/browse.
const directoryCategories = <AppCategory>[
  AppCategory(id: 'gp', labelKey: 'general', iconAsset: AppAssets.categoryGp),
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
