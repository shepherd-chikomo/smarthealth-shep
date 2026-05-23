import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/shared/data/mock_data.dart';
import 'package:smarthealth_shep/shared/models/category_model.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(),
);

class CategoryRepository {
  Future<List<CategoryModel>> getCategories() async => MockData.categories;
}
