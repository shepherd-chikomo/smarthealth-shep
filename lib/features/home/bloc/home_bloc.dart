import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/home/bloc/home_event.dart';
import 'package:smarthealth_shep/features/home/bloc/home_state.dart';
import 'package:smarthealth_shep/features/home/data/home_repository.dart';
import 'package:smarthealth_shep/shared/data/category_repository.dart';
import 'package:smarthealth_shep/shared/models/service_category_model.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    HomeRepository? repository,
    required CategoryRepository categoryRepository,
  })  : _repository = repository ?? HomeRepository(),
        _categories = categoryRepository,
        super(const HomeInitial()) {
    on<LoadHomeData>(_onLoad);
    on<RefreshHomeData>(_onRefresh);
    on<SelectHomeCategory>(_onSelectCategory);
    on<ChangeHomeCity>(_onChangeCity);
  }

  final HomeRepository _repository;
  final CategoryRepository _categories;

  List<ServiceCategoryModel> _cachedCategories = const [];

  Future<void> _onLoad(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading(categories: _cachedCategories));
    _cachedCategories = await _categories.getHomeServiceCategories(
      nearMeLabel: event.nearMeLabel,
    );
    await _fetch(emit, isRefresh: false, categoryId: null, refreshOrigin: true);
  }

  Future<void> _onRefresh(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else if (current is HomeOffline) {
      emit(HomeLoaded(
        city: current.city,
        facilities: current.facilities,
        lastUpdated: current.lastUpdated,
        categories: current.categories,
        selectedCategoryId: current.selectedCategoryId,
        isRefreshing: true,
        activeQueue: current.activeQueue,
      ));
    }
    _cachedCategories = await _categories.getHomeServiceCategories();
    final categoryId = current is HomeLoaded
        ? current.selectedCategoryId
        : current is HomeOffline
            ? current.selectedCategoryId
            : null;
    await _fetch(
      emit,
      isRefresh: true,
      categoryId: categoryId,
      refreshOrigin: true,
    );
  }

  Future<void> _fetch(
    Emitter<HomeState> emit, {
    required bool isRefresh,
    String? categoryId,
    bool refreshOrigin = false,
    String? manualCityName,
  }) async {
    try {
      final previous = state;
      final selectedCategoryId = categoryId ??
          (previous is HomeLoaded
              ? previous.selectedCategoryId
              : previous is HomeOffline
                  ? previous.selectedCategoryId
                  : null);

      final facilityType = _facilityTypeForCategory(selectedCategoryId);

      final result = await _repository.sync(
        forceRefresh: isRefresh,
        facilityType: facilityType,
        refreshOrigin: refreshOrigin,
        manualCityName: manualCityName,
      );

      if (result.isOffline) {
        emit(HomeOffline(
          city: result.city,
          facilities: result.facilities,
          lastUpdated: result.lastUpdated,
          categories: _cachedCategories,
          selectedCategoryId: selectedCategoryId,
          activeQueue: result.activeQueue,
        ));
      } else {
        emit(HomeLoaded(
          city: result.city,
          facilities: result.facilities,
          lastUpdated: result.lastUpdated,
          categories: _cachedCategories,
          selectedCategoryId: selectedCategoryId,
          activeQueue: result.activeQueue,
          loadError: result.loadError,
        ));
      }
    } catch (error) {
      emit(HomeError(
        message: error.toString(),
        categories: _cachedCategories,
      ));
    }
  }

  Future<void> _onSelectCategory(
    SelectHomeCategory event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(
        selectedCategoryId: event.categoryId,
        clearCategory: event.categoryId == null,
        isRefreshing: true,
      ));
    } else if (current is HomeOffline) {
      emit(HomeLoaded(
        city: current.city,
        facilities: current.facilities,
        lastUpdated: current.lastUpdated,
        categories: current.categories,
        selectedCategoryId: event.categoryId,
        isRefreshing: true,
        activeQueue: current.activeQueue,
      ));
    } else {
      return;
    }

    await _fetch(emit, isRefresh: true, categoryId: event.categoryId);
  }

  String? _facilityTypeForCategory(String? categoryId) {
    if (categoryId == null || categoryId == 'near_me') return null;
    return categoryId;
  }

  Future<void> _onChangeCity(
    ChangeHomeCity event,
    Emitter<HomeState> emit,
  ) async {
    await _repository.saveCity(event.city);
    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(city: event.city, isRefreshing: true));
    } else if (current is HomeOffline) {
      emit(HomeLoaded(
        city: event.city,
        facilities: current.facilities,
        lastUpdated: current.lastUpdated,
        categories: current.categories,
        selectedCategoryId: current.selectedCategoryId,
        isRefreshing: true,
        activeQueue: current.activeQueue,
      ));
    }

    final categoryId = current is HomeLoaded
        ? current.selectedCategoryId
        : current is HomeOffline
            ? current.selectedCategoryId
            : null;

    await _fetch(
      emit,
      isRefresh: true,
      categoryId: categoryId,
      refreshOrigin: false,
      manualCityName: event.city,
    );
  }
}
