import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/home/bloc/home_event.dart';
import 'package:smarthealth_shep/features/home/bloc/home_state.dart';
import 'package:smarthealth_shep/features/home/data/home_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({HomeRepository? repository})
      : _repository = repository ?? HomeRepository(),
        super(const HomeInitial()) {
    on<LoadHomeData>(_onLoad);
    on<RefreshHomeData>(_onRefresh);
    on<SelectHomeCategory>(_onSelectCategory);
    on<ChangeHomeCity>(_onChangeCity);
  }

  final HomeRepository _repository;

  Future<void> _onLoad(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _fetch(emit, isRefresh: false);
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
        providers: current.providers,
        lastUpdated: current.lastUpdated,
        selectedCategoryId: current.selectedCategoryId,
        isRefreshing: true,
      ));
    }
    await _fetch(emit, isRefresh: true);
  }

  Future<void> _fetch(Emitter<HomeState> emit, {required bool isRefresh}) async {
    try {
      final result = await _repository.sync(forceRefresh: isRefresh);
      final previous = state;
      String? categoryId;
      if (previous is HomeLoaded) {
        categoryId = previous.selectedCategoryId;
      } else if (previous is HomeOffline) {
        categoryId = previous.selectedCategoryId;
      }

      if (result.isOffline) {
        emit(HomeOffline(
          city: result.city,
          providers: result.providers,
          lastUpdated: result.lastUpdated,
          selectedCategoryId: categoryId,
        ));
      } else {
        emit(HomeLoaded(
          city: result.city,
          providers: result.providers,
          lastUpdated: result.lastUpdated,
          selectedCategoryId: categoryId,
        ));
      }
    } catch (error) {
      emit(HomeError(message: error.toString()));
    }
  }

  void _onSelectCategory(SelectHomeCategory event, Emitter<HomeState> emit) {
    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(
        selectedCategoryId: event.categoryId,
        clearCategory: event.categoryId == null,
      ));
    } else if (current is HomeOffline) {
      emit(current.copyWith(
        selectedCategoryId: event.categoryId,
        clearCategory: event.categoryId == null,
      ));
    }
  }

  Future<void> _onChangeCity(
    ChangeHomeCity event,
    Emitter<HomeState> emit,
  ) async {
    await _repository.saveCity(event.city);
    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(city: event.city));
    } else if (current is HomeOffline) {
      emit(current.copyWith(city: event.city));
    }
  }
}
