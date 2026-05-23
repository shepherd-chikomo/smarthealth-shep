import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/search/bloc/search_event.dart';
import 'package:smarthealth_shep/features/search/bloc/search_state.dart';
import 'package:smarthealth_shep/features/search/data/search_filter_engine.dart';
import 'package:smarthealth_shep/features/search/data/search_repository.dart';
import 'package:smarthealth_shep/features/search/search_filter_options.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({SearchRepository? repository})
      : _repository = repository ?? SearchRepository(),
        super(const SearchState()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<FilterToggled>(_onFilterToggled);
    on<FiltersApplied>(_onFiltersApplied);
    on<SearchReloadRequested>(_onReload);

    add(const SearchReloadRequested());
  }

  final SearchRepository _repository;

  Future<void> _onReload(
    SearchReloadRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(status: SearchStatus.loading, clearError: true));
    try {
      final result = await _repository.loadProviders();
      final filtered = _filter(
        providers: result.providers,
        query: state.query,
        specialties: state.specialties,
        conditions: state.conditions,
        ageGroups: state.ageGroups,
      );
      emit(
        state.copyWith(
          status: SearchStatus.ready,
          allProviders: result.providers,
          filteredProviders: filtered,
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

  void _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) {
    final filtered = _filter(
      providers: state.allProviders,
      query: event.query,
      specialties: state.specialties,
      conditions: state.conditions,
      ageGroups: state.ageGroups,
    );
    emit(
      state.copyWith(
        query: event.query,
        filteredProviders: filtered,
        navigateToResults: false,
      ),
    );
  }

  void _onFilterToggled(FilterToggled event, Emitter<SearchState> emit) {
    final specialties = Set<String>.from(state.specialties);
    final conditions = Set<String>.from(state.conditions);
    final ageGroups = Set<String>.from(state.ageGroups);

    final target = switch (event.group) {
      SearchFilterGroup.specialty => specialties,
      SearchFilterGroup.condition => conditions,
      SearchFilterGroup.ageGroup => ageGroups,
    };

    if (target.contains(event.filterId)) {
      target.remove(event.filterId);
    } else {
      target.add(event.filterId);
    }

    final filtered = _filter(
      providers: state.allProviders,
      query: state.query,
      specialties: specialties,
      conditions: conditions,
      ageGroups: ageGroups,
    );

    emit(
      state.copyWith(
        specialties: specialties,
        conditions: conditions,
        ageGroups: ageGroups,
        filteredProviders: filtered,
        navigateToResults: false,
      ),
    );
  }

  void _onFiltersApplied(FiltersApplied event, Emitter<SearchState> emit) {
    emit(state.copyWith(navigateToResults: true));
    emit(state.copyWith(navigateToResults: false));
  }

  List<ProviderModel> _filter({
    required List<ProviderModel> providers,
    required String query,
    required Set<String> specialties,
    required Set<String> conditions,
    required Set<String> ageGroups,
  }) {
    return SearchFilterEngine.apply(
      providers: providers,
      query: query,
      specialties: specialties,
      conditions: conditions,
      ageGroups: ageGroups,
    );
  }
}
