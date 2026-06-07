import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/search/bloc/search_event.dart';
import 'package:smarthealth_shep/features/search/bloc/search_state.dart';
import 'package:smarthealth_shep/features/search/data/recent_search_store.dart';
import 'package:smarthealth_shep/features/search/data/search_repository.dart';
import 'package:smarthealth_shep/features/search/search_filter_options.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required SearchRepository repository,
    RecentSearchStore? recentSearchStore,
  })  : _repository = repository,
        _recentSearchStore = recentSearchStore ?? RecentSearchStore(),
        super(const SearchState()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<FilterToggled>(_onFilterToggled);
    on<FiltersApplied>(_onFiltersApplied);
    on<SearchReloadRequested>(_onReload);
    on<SortChanged>(_onSortChanged);
    on<AcceptsMyMedicalAidToggled>(_onAcceptsMyMedicalAidToggled);
    on<RecentSearchesLoaded>(_onRecentSearchesLoaded);
    on<RecentSearchRemoved>(_onRecentSearchRemoved);
    on<SearchDebounced>(_onDebouncedSearch);

    add(const SearchReloadRequested());
    _loadRecentSearches();
  }

  final SearchRepository _repository;
  final RecentSearchStore _recentSearchStore;
  Timer? _debounce;

  Future<void> _loadRecentSearches() async {
    final searches = await _recentSearchStore.load();
    add(RecentSearchesLoaded(searches));
  }

  Future<void> _onRecentSearchesLoaded(
    RecentSearchesLoaded event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(recentSearches: event.searches));
  }

  Future<void> _onRecentSearchRemoved(
    RecentSearchRemoved event,
    Emitter<SearchState> emit,
  ) async {
    await _recentSearchStore.remove(event.query);
    final searches = await _recentSearchStore.load();
    emit(state.copyWith(recentSearches: searches));
  }

  Future<void> _onSortChanged(
    SortChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(sortBy: event.sort, navigateToResults: false));
  }

  Future<void> _onAcceptsMyMedicalAidToggled(
    AcceptsMyMedicalAidToggled event,
    Emitter<SearchState> emit,
  ) async {
    emit(
      state.copyWith(
        acceptsMyMedicalAid: event.enabled,
        navigateToResults: false,
      ),
    );
    await _runSearch(emit);
  }

  Future<void> _onReload(
    SearchReloadRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(status: SearchStatus.loading, clearError: true));
    try {
      final userScheme = await _repository.getUserMedicalAidSchemeKey();
      final result = await _repository.loadDiscovery();
      emit(
        state.copyWith(
          status: SearchStatus.ready,
          allProviders: result.providers,
          filteredProviders: result.providers,
          allFacilities: result.facilities,
          filteredFacilities: result.facilities,
          specialtyFilterOptions: result.specialtyFilters,
          conditionFilterOptions: result.conditionFilters,
          ageGroupFilterOptions: result.ageGroupFilters,
          isOffline: result.isOffline,
          userMedicalAidSchemeKey: userScheme,
          acceptsMyMedicalAid: userScheme != null,
        ),
      );
      if (state.hasActiveCriteria) {
        await _runSearch(emit);
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(query: event.query, navigateToResults: false));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      add(const SearchDebounced());
    });
  }

  Future<void> _onDebouncedSearch(
    SearchDebounced event,
    Emitter<SearchState> emit,
  ) async {
    await _runSearch(emit);
  }

  Future<void> _onFilterToggled(
    FilterToggled event,
    Emitter<SearchState> emit,
  ) async {
    final specialties = Set<String>.from(state.specialties);
    final conditions = Set<String>.from(state.conditions);
    final ageGroups = Set<String>.from(state.ageGroups);
    final operational = Set<String>.from(state.operational);
    final medicalAidSchemes = Set<String>.from(state.medicalAidSchemes);

    final target = switch (event.group) {
      SearchFilterGroup.specialty => specialties,
      SearchFilterGroup.condition => conditions,
      SearchFilterGroup.ageGroup => ageGroups,
      SearchFilterGroup.operational => operational,
      SearchFilterGroup.medicalAid => medicalAidSchemes,
    };

    if (target.contains(event.filterId)) {
      target.remove(event.filterId);
    } else {
      target.add(event.filterId);
    }

    emit(
      state.copyWith(
        specialties: specialties,
        conditions: conditions,
        ageGroups: ageGroups,
        operational: operational,
        medicalAidSchemes: medicalAidSchemes,
        navigateToResults: false,
      ),
    );
    await _runSearch(emit);
  }

  Future<void> _onFiltersApplied(
    FiltersApplied event,
    Emitter<SearchState> emit,
  ) async {
    if (!state.hasActiveCriteria) return;

    await _runSearch(emit);
    if (state.status == SearchStatus.error) return;

    if (state.query.trim().isNotEmpty) {
      await _recentSearchStore.add(state.query);
      final searches = await _recentSearchStore.load();
      emit(state.copyWith(recentSearches: searches));
    }

    emit(state.copyWith(navigateToResults: true));
    emit(state.copyWith(navigateToResults: false));
  }

  Future<void> _runSearch(Emitter<SearchState> emit) async {
    if (!state.hasActiveCriteria) {
      emit(
        state.copyWith(
          filteredProviders: state.allProviders,
          filteredFacilities: state.allFacilities,
          status: SearchStatus.ready,
        ),
      );
      return;
    }

    emit(state.copyWith(status: SearchStatus.loading, clearError: true));
    try {
      final result = await _repository.search(
        query: state.query,
        specialties: state.specialties,
        conditions: state.conditions,
        ageGroups: state.ageGroups,
        operational: state.operational,
        medicalAidSchemes: state.medicalAidSchemes,
        acceptsMyMedicalAid: state.acceptsMyMedicalAid,
        userMedicalAidSchemeKey: state.userMedicalAidSchemeKey,
      );
      emit(
        state.copyWith(
          status: SearchStatus.ready,
          filteredProviders: result.providers,
          filteredFacilities: result.facilities,
          isOffline: result.isOffline,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
