/// Normalizes catalog values to stable filter IDs (matches backend catalog-slug).
String normalizeCatalogSlug(String raw) {
  return raw
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

bool catalogSlugMatches(String value, String slug) {
  return normalizeCatalogSlug(value) == slug;
}
