import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/shared/data/mock_data.dart';
import 'package:smarthealth_shep/shared/data/provider_detail_catalog.dart';
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

  /// Simulated API fetch returning full profile detail.
  Future<ProviderModel?> getDetailById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return getDetailByIdLocal(id);
  }

  /// Immediate local lookup (mock catalog / future SQLite).
  ProviderModel? getDetailByIdLocal(String id) {
    for (final provider in MockData.providers) {
      if (provider.id == id) {
        return ProviderDetailCatalog.enrich(provider);
      }
    }
    return null;
  }
}
