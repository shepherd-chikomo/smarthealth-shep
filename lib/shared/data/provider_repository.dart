import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/shared/data/mock_data.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

final providerRepositoryProvider = Provider<ProviderRepository>(
  (ref) => ProviderRepository(),
);

/// Local-first provider directory (mock-backed until API is wired).
class ProviderRepository {
  Future<List<ProviderModel>> getProviders({String? categoryId}) async {
    final all = MockData.providers;
    if (categoryId == null) return all;
    return all.where((p) => p.categoryId == categoryId).toList();
  }

  Future<ProviderModel?> getById(String id) async {
    for (final provider in MockData.providers) {
      if (provider.id == id) return provider;
    }
    return null;
  }
}
