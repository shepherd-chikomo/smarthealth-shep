/// Normalizes free-text to stable condition slug IDs (e.g. "HIV/AIDS" → "hiv_aids").
String toConditionSlug(String raw) {
  return raw
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}
