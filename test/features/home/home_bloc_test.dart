import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthealth_shep/features/home/bloc/home_bloc.dart';import 'package:smarthealth_shep/features/home/bloc/home_event.dart';
import 'package:smarthealth_shep/features/home/bloc/home_state.dart';
import 'package:smarthealth_shep/features/home/data/home_repository.dart';
import 'package:smarthealth_shep/features/home/models/facility_load_mode.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';import 'package:smarthealth_shep/shared/models/service_category_model.dart';

import '../../mocks/mocks.mocks.dart';

void main() {
  late MockHomeRepository repository;
  late MockCategoryRepository categories;

  const dentalCategory = ServiceCategoryModel(
    id: 'dental',
    name: 'Dental',
    iconAsset: 'assets/category_dentist.svg',
  );

  const sampleFacility = FacilityModel(
    id: '11111111-1111-1111-1111-111111111111',
    name: 'Test Dental',
    slug: 'test-dental',
    facilityType: 'dental',
    facilityTypes: ['dental'],
    city: 'Harare',
    province: 'Harare',
  );

  setUp(() {
    repository = MockHomeRepository();
    categories = MockCategoryRepository();
    when(categories.getHomeServiceCategories()).thenAnswer(
      (_) async => [dentalCategory],
    );
  });

  blocTest<HomeBloc, HomeState>(
    'LoadHomeCityFallback loads city list and keeps category',
    build: () => HomeBloc(
      repository: repository,
      categoryRepository: categories,
    ),
    seed: () => HomeLoaded(
      city: 'Harare',
      facilities: const [],
      lastUpdated: DateTime(2026, 6, 5),
      categories: const [dentalCategory],
      selectedCategoryId: 'dental',
      fallbackCity: 'Harare',
    ),
    act: (bloc) => bloc.add(const LoadHomeCityFallback()),
    setUp: () {
      when(
        repository.syncCityFallback(city: 'Harare', facilityType: 'dental'),
      ).thenAnswer(
        (_) async => HomeSyncResult(
          facilities: const [sampleFacility],
          city: 'Harare',
          lastUpdated: DateTime(2026, 6, 5),
          isOffline: false,
          loadMode: FacilityLoadMode.cityFallback,
          fallbackCity: 'Harare',
        ),
      );
    },
    expect: () => [
      isA<HomeLoaded>()
          .having((s) => s.isRefreshing, 'refreshing', true)
          .having((s) => s.selectedCategoryId, 'category', 'dental'),
      isA<HomeLoaded>()
          .having((s) => s.facilities.length, 'count', 1)
          .having((s) => s.loadMode, 'mode', FacilityLoadMode.cityFallback)
          .having((s) => s.selectedCategoryId, 'category', 'dental'),
    ],
  );
}
