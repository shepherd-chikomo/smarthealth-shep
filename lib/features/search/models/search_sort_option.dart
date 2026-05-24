/// Client-side sort options for directory search results.
enum SearchSortOption {
  distance,
  availability,
  queueTime,
  rating,
  mostReviewed,
}

extension SearchSortOptionLabels on SearchSortOption {
  String get label => switch (this) {
        SearchSortOption.distance => 'Distance',
        SearchSortOption.availability => 'Availability',
        SearchSortOption.queueTime => 'Queue Time',
        SearchSortOption.rating => 'Rating',
        SearchSortOption.mostReviewed => 'Most Reviewed',
      };
}
