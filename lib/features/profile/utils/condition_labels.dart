import 'package:smarthealth_shep/features/search/search_filter_options.dart';

/// Resolves condition slug IDs to human-readable labels.
abstract final class ConditionLabels {
  static final Map<String, String> _remoteLabels = {};
  static final Map<String, String> _customLabels = {};

  static const _extraLabels = <String, String>{
    'diabetes_type_2': 'Diabetes Type 2',
  };

  static void setRemoteCatalog(Iterable<({String id, String label})> items) {
    _remoteLabels.clear();
    for (final item in items) {
      _remoteLabels[item.id] = item.label;
    }
  }

  static void setCustomLabels(Map<String, String> labels) {
    _customLabels
      ..clear()
      ..addAll(labels);
  }

  static String labelFor(String id) {
    final custom = _customLabels[id];
    if (custom != null && custom.isNotEmpty) return custom;

    final remote = _remoteLabels[id];
    if (remote != null && remote.isNotEmpty) return remote;

    final extra = _extraLabels[id];
    if (extra != null) return extra;

    for (final option in SearchFilterOptions.conditions) {
      if (option.id == id) return option.label;
    }
    return id.replaceAll('_', ' ');
  }

  static String joinLabels(Iterable<String> ids, {Map<String, String>? customLabels}) {
    if (customLabels != null && customLabels.isNotEmpty) {
      return ids
          .map((id) => customLabels[id] ?? labelFor(id))
          .join(' • ');
    }
    return ids.map(labelFor).join(' • ');
  }

  static List<SearchFilterOption> allOptions() {
    final seen = <String>{};
    final merged = <SearchFilterOption>[];

    for (final entry in _remoteLabels.entries) {
      if (seen.add(entry.key)) {
        merged.add(SearchFilterOption(id: entry.key, label: entry.value));
      }
    }
    for (final option in SearchFilterOptions.conditions) {
      if (seen.add(option.id)) merged.add(option);
    }
    for (final entry in _extraLabels.entries) {
      if (seen.add(entry.key)) {
        merged.add(SearchFilterOption(id: entry.key, label: entry.value));
      }
    }
    return merged;
  }
}
