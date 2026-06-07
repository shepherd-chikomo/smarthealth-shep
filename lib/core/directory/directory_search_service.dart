import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/directory/directory_index_dao.dart';
import 'package:smarthealth_shep/shared/data/local/facility_cache.dart';
import 'package:smarthealth_shep/shared/data/local/provider_dao.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

final directorySearchServiceProvider = Provider<DirectorySearchService>((ref) {
  return DirectorySearchService();
});

/// Indexed local directory search — no network required.
class DirectorySearchService {
  DirectorySearchService({
    DirectoryIndexDao? indexDao,
    ProviderDao? providerDao,
    FacilityCache? facilityCache,
  })  : _indexDao = indexDao ?? DirectoryIndexDao(),
        _providerDao = providerDao ?? ProviderDao(),
        _facilityCache = facilityCache ?? FacilityCache();

  final DirectoryIndexDao _indexDao;
  final ProviderDao _providerDao;
  final FacilityCache _facilityCache;

  Future<void> rebuildIndex() async {
    final providers = await _providerDao.getAll();
    for (final provider in providers) {
      await _indexDao.upsertProvider(provider);
    }

    final facilities = _facilityCache
        .readAll()
        .map((json) => FacilityModel.fromJson(json))
        .toList();
    for (final facility in facilities) {
      await _indexDao.upsertFacility(facility);
    }
  }

  Future<({List<FacilityModel> facilities, List<ProviderModel> providers})>
      searchLocal({
    required String query,
    int limit = 50,
  }) async {
    final hits = await _indexDao.search(query: query, limit: limit);
    final facilities = <FacilityModel>[];
    final providers = <ProviderModel>[];

    for (final hit in hits) {
      final payload = jsonDecode(hit.payloadJson) as Map<String, dynamic>;
      if (hit.entityType == 'facility') {
        facilities.add(FacilityModel.fromJson(payload));
      } else if (hit.entityType == 'provider') {
        providers.add(ProviderModel.fromJson(payload));
      }
    }

    return (facilities: facilities, providers: providers);
  }
}
