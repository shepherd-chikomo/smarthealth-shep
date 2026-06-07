/// Result from the medical conditions picker sheet.
class ConditionSelectionResult {
  const ConditionSelectionResult({
    required this.selectedIds,
    this.customLabels = const {},
  });

  final Set<String> selectedIds;

  /// User-typed labels keyed by slug (for conditions not yet in the catalog).
  final Map<String, String> customLabels;
}
