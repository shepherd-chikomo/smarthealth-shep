import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/features/search/search_filter_options.dart';
import 'package:smarthealth_shep/features/search/models/search_sort_option.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class FilterToggled extends SearchEvent {
  const FilterToggled({
    required this.group,
    required this.filterId,
  });

  final SearchFilterGroup group;
  final String filterId;

  @override
  List<Object?> get props => [group, filterId];
}

final class FiltersApplied extends SearchEvent {
  const FiltersApplied();
}

final class SearchReloadRequested extends SearchEvent {
  const SearchReloadRequested();
}

final class SearchDebounced extends SearchEvent {
  const SearchDebounced();
}

final class SortChanged extends SearchEvent {
  const SortChanged(this.sort);

  final SearchSortOption sort;

  @override
  List<Object?> get props => [sort];
}

final class RecentSearchesLoaded extends SearchEvent {
  const RecentSearchesLoaded(this.searches);

  final List<String> searches;

  @override
  List<Object?> get props => [searches];
}

final class AcceptsMyMedicalAidToggled extends SearchEvent {
  const AcceptsMyMedicalAidToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

final class RecentSearchRemoved extends SearchEvent {
  const RecentSearchRemoved(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
