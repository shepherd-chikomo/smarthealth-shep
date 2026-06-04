import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/shared/data/category_catalog_icons.dart';
import 'package:smarthealth_shep/shared/data/mock_data.dart';
import 'package:smarthealth_shep/shared/models/category_model.dart';
import 'package:smarthealth_shep/shared/models/service_category_model.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(api: ApiService(ref.watch(dioProvider))),
);

class CategoryRepository {
  CategoryRepository({required ApiService api}) : _api = api;

  final ApiService _api;

  static const _logName = 'CategoryRepository';

  /// Legacy category list (directory chips).
  Future<List<CategoryModel>> getCategories() async {
    if (AppConfig.allowMockFallbacks) {
      return MockData.categories;
    }
    return [];
  }

  /// Home dashboard tiles: near-me + facility types from the main database.
  Future<List<ServiceCategoryModel>> getHomeServiceCategories({
    String nearMeLabel = 'Near Me',
  }) async {
    final nearMe = ServiceCategoryModel(
      id: 'near_me',
      name: nearMeLabel,
      iconAsset: CategoryCatalogIcons.nearMe.iconAsset,
      isNearMe: true,
    );

    try {
      final types = await _api.fetchFacilityTypeCatalog();
      if (types.isNotEmpty) {
        return [
          nearMe,
          for (final type in types)
            ServiceCategoryModel(
              id: type.facilityType,
              name: type.label,
              iconAsset: CategoryCatalogIcons.iconAssetForFacilityType(
                type.facilityType,
              ),
              count: type.count,
            ),
        ];
      }
      if (kDebugMode) {
        developer.log(
          'Facility type catalog empty; using default tiles',
          name: _logName,
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Facility type catalog failed; using default tiles',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (AppConfig.allowMockFallbacks) {
      return _fallbackHomeCategories(nearMeLabel);
    }

    return [nearMe, ..._defaultFacilityTypeTiles()];
  }

  /// Bundled tiles when the catalog API is unavailable (main DB mode).
  static List<ServiceCategoryModel> _defaultFacilityTypeTiles() {
    const defaults = <(String id, String label, String icon)>[
      ('clinic', 'Clinics', AppAssets.categoryGp),
      ('pharmacy', 'Pharmacies', AppAssets.categoryPharmacy),
      ('dental', 'Dental', AppAssets.categoryDentist),
      ('laboratory', 'Laboratories', AppAssets.categoryLab),
      ('imaging', 'Imaging', AppAssets.categorySpecialist),
      ('hospital', 'Hospitals', AppAssets.categoryGp),
      ('optometry', 'Optometry', AppAssets.categorySpecialist),
    ];
    return [
      for (final d in defaults)
        ServiceCategoryModel(
          id: d.$1,
          name: d.$2,
          iconAsset: d.$3,
        ),
    ];
  }

  List<ServiceCategoryModel> _fallbackHomeCategories(String nearMeLabel) {
    return [
      ServiceCategoryModel(
        id: 'near_me',
        name: nearMeLabel,
        iconAsset: CategoryCatalogIcons.nearMe.iconAsset,
        isNearMe: true,
      ),
      ..._defaultFacilityTypeTiles(),
    ];
  }
}
