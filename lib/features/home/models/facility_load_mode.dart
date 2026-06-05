/// How the home dashboard loaded its facility list.
enum FacilityLoadMode {
  /// Geo radius search via GET /facilities/nearby.
  geo,

  /// City + category list via GET /facilities (no coordinates required).
  cityFallback,
}
