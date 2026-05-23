import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthealth_shep/core/exceptions/network_exception.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/shared/data/provider_repository.dart';
import 'package:smarthealth_shep/shared/models/provider_search_filter.dart';

import '../../fixtures/provider_fixtures.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  late MockProviderDao mockDao;
  late MockApiService mockApi;
  late MockSyncService mockSync;
  late ProviderRepository repository;

  setUp(() {
    mockDao = MockProviderDao();
    mockApi = MockApiService();
    mockSync = MockSyncService();
    repository = ProviderRepository(
      dao: mockDao,
      api: mockApi,
      syncService: mockSync,
      seedMockDataOnEmpty: false,
    );
  });

  group('getNearbyProviders', () {
    test('online success: fetches from API, caches locally, returns data', () async {
      when(mockDao.getLastSync()).thenAnswer((_) async => null);
      when(
        mockApi.fetchNearbyProviders(
          lat: ProviderFixtures.harareLat,
          lon: ProviderFixtures.harareLon,
          radiusKm: ProviderFixtures.searchRadiusKm,
          since: null,
        ),
      ).thenAnswer((_) async => ProviderFixtures.nearbyRemote);
      when(mockDao.upsertProviders(any)).thenAnswer((_) async {});
      when(mockDao.setLastSync(any)).thenAnswer((_) async {});

      final result = await repository.getNearbyProviders(
        lat: ProviderFixtures.harareLat,
        lon: ProviderFixtures.harareLon,
        radiusKm: ProviderFixtures.searchRadiusKm,
      );

      expect(result.isOffline, isFalse);
      expect(result.providers, hasLength(2));
      expect(result.providers.first.id, 'p1');
      expect(result.providers.every((p) => p.distanceKm != null), isTrue);

      verify(mockDao.getLastSync()).called(1);
      verify(
        mockApi.fetchNearbyProviders(
          lat: ProviderFixtures.harareLat,
          lon: ProviderFixtures.harareLon,
          radiusKm: ProviderFixtures.searchRadiusKm,
          since: null,
        ),
      ).called(1);
      verify(mockDao.upsertProviders(ProviderFixtures.nearbyRemote)).called(1);
      verify(mockDao.setLastSync(any)).called(1);
      verifyNever(mockDao.getNearby(any, any, any));
    });

    test('offline fallback: API fails, returns cached data with isOffline=true', () async {
      when(mockDao.getLastSync()).thenAnswer((_) async => ProviderFixtures.lastSyncDate);
      when(
        mockApi.fetchNearbyProviders(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          radiusKm: anyNamed('radiusKm'),
          since: anyNamed('since'),
        ),
      ).thenThrow(const NetworkException('Network unavailable'));
      when(
        mockDao.getNearby(
          ProviderFixtures.harareLat,
          ProviderFixtures.harareLon,
          ProviderFixtures.searchRadiusKm,
        ),
      ).thenAnswer((_) async => ProviderFixtures.cachedNearby);

      final result = await repository.getNearbyProviders(
        lat: ProviderFixtures.harareLat,
        lon: ProviderFixtures.harareLon,
        radiusKm: ProviderFixtures.searchRadiusKm,
      );

      expect(result.isOffline, isTrue);
      expect(result.providers, ProviderFixtures.cachedNearby);
      verify(mockDao.getNearby(
        ProviderFixtures.harareLat,
        ProviderFixtures.harareLon,
        ProviderFixtures.searchRadiusKm,
      )).called(1);
      verifyNever(mockDao.upsertProviders(any));
    });

    test('no cache: API fails, no cache, throws NetworkException', () async {
      when(mockDao.getLastSync()).thenAnswer((_) async => null);
      when(
        mockApi.fetchNearbyProviders(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          radiusKm: anyNamed('radiusKm'),
          since: anyNamed('since'),
        ),
      ).thenThrow(const NetworkException('Network unavailable'));
      when(
        mockDao.getNearby(
          ProviderFixtures.harareLat,
          ProviderFixtures.harareLon,
          ProviderFixtures.searchRadiusKm,
        ),
      ).thenAnswer((_) async => []);

      await expectLater(
        repository.getNearbyProviders(
          lat: ProviderFixtures.harareLat,
          lon: ProviderFixtures.harareLon,
          radiusKm: ProviderFixtures.searchRadiusKm,
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            contains('No network and no cached providers'),
          ),
        ),
      );
    });
  });

  group('searchProviders', () {
    test('local search: searches SQLite and schedules background sync', () async {
      const filter = ProviderSearchFilter(query: 'cardio');
      Future<void> Function()? scheduledTask;

      when(mockDao.search(filter))
          .thenAnswer((_) async => ProviderFixtures.searchLocalResults);
      when(mockDao.getLastSync()).thenAnswer((_) async => ProviderFixtures.lastSyncDate);
      when(
        mockApi.searchProviders(filter, since: ProviderFixtures.lastSyncDate),
      ).thenAnswer((_) async => ProviderFixtures.searchRemoteResults);
      when(mockDao.upsertProviders(any)).thenAnswer((_) async {});
      when(mockDao.setLastSync(any)).thenAnswer((_) async {});
      when(mockSync.schedule(any, any)).thenAnswer((invocation) {
        scheduledTask = invocation.positionalArguments[1] as Future<void> Function();
      });

      final result = await repository.searchProviders(filter);

      expect(result.isOffline, isTrue);
      expect(result.providers, ProviderFixtures.searchLocalResults);
      verify(mockDao.search(filter)).called(1);
      verify(mockSync.schedule('provider-search:${filter.hashCode}', any)).called(1);

      await scheduledTask?.call();

      verify(mockApi.searchProviders(filter, since: ProviderFixtures.lastSyncDate))
          .called(1);
      verify(mockDao.upsertProviders(ProviderFixtures.searchRemoteResults)).called(1);
      verify(mockDao.setLastSync(any)).called(1);
    });
  });

  group('syncProviders', () {
    test('delta sync: sends last_sync, applies changes, updates local DB', () async {
      when(mockDao.getLastSync()).thenAnswer((_) async => ProviderFixtures.lastSyncDate);
      when(mockApi.syncProviders(since: ProviderFixtures.lastSyncDate))
          .thenAnswer((_) async => ProviderFixtures.deltaPayload);
      when(mockDao.upsertProviders(any)).thenAnswer((_) async {});
      when(mockDao.deleteProviders(any)).thenAnswer((_) async {});
      when(mockDao.setLastSync(any)).thenAnswer((_) async {});

      await repository.syncProviders();

      verify(mockDao.getLastSync()).called(1);
      verify(mockApi.syncProviders(since: ProviderFixtures.lastSyncDate)).called(1);
      verify(mockDao.upsertProviders(ProviderFixtures.deltaPayload.updated)).called(1);
      verify(mockDao.deleteProviders(ProviderFixtures.deltaPayload.deletedIds)).called(1);
      verify(mockDao.setLastSync(ProviderFixtures.syncedAt)).called(1);
    });

    test('delta sync: rethrows when API fails', () async {
      when(mockDao.getLastSync()).thenAnswer((_) async => ProviderFixtures.lastSyncDate);
      when(mockApi.syncProviders(since: anyNamed('since')))
          .thenThrow(const NetworkException('Sync failed'));

      await expectLater(
        repository.syncProviders(),
        throwsA(isA<NetworkException>()),
      );

      verifyNever(mockDao.upsertProviders(any));
      verifyNever(mockDao.deleteProviders(any));
      verifyNever(mockDao.setLastSync(any));
    });
  });
}
