import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Sample provider data for unit tests.
abstract final class ProviderFixtures {
  static const harareLat = -17.8252;
  static const harareLon = 31.0335;
  static const searchRadiusKm = 10.0;

  static const lastSync = '2026-05-01T08:00:00.000Z';
  static final lastSyncDate = DateTime.parse(lastSync).toUtc();
  static final syncedAt = DateTime.utc(2026, 5, 23, 12, 0);

  static ProviderModel provider({
    String id = 'p1',
    String name = 'Dr. Tafadzwa Moyo',
    String categoryId = 'general',
    String? specialty = 'General Practice',
    String? facilityName = 'Parirenyatwa Hospital',
    double? latitude = harareLat,
    double? longitude = harareLon,
    double? distanceKm,
    bool isVerified = true,
  }) {
    return ProviderModel(
      id: id,
      name: name,
      categoryId: categoryId,
      specialty: specialty,
      facilityName: facilityName,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
      isVerified: isVerified,
    );
  }

  static List<ProviderModel> get nearbyRemote => [
        provider(id: 'p1', distanceKm: 1.2),
        provider(
          id: 'p2',
          name: 'Dr. Rudo Chikwanha',
          categoryId: 'pediatrics',
          specialty: 'Pediatrics',
          facilityName: 'Avenues Clinic',
          latitude: -17.8194,
          longitude: 31.0522,
          distanceKm: 2.8,
        ),
      ];

  static List<ProviderModel> get cachedNearby => [
        provider(
          id: 'cached-1',
          name: 'Cached Dr. Moyo',
          distanceKm: 0.8,
        ),
      ];

  static List<ProviderModel> get searchLocalResults => [
        provider(id: 'search-1', name: 'Dr. Cardio'),
      ];

  static List<ProviderModel> get searchRemoteResults => [
        provider(id: 'remote-search-1', name: 'Dr. Remote Cardio'),
      ];

  static ProviderSyncPayload get deltaPayload => ProviderSyncPayload(
        updated: [
          provider(id: 'delta-1', name: 'Dr. Updated'),
        ],
        deletedIds: const ['deleted-1'],
        syncedAt: syncedAt,
      );
}
