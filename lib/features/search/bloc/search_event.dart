import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/features/search/search_filter_options.dart';

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
