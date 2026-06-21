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
    return id.replaceAll('_', ' ').replaceAll('-', ' ');
  }

  static String _titleCaseWords(String value) {
    return value
        .split(RegExp(r'[\s\-_]+'))
        .where((part) => part.isNotEmpty)
        .map((part) {
          if (part.length <= 4 && part.toUpperCase() == part) return part;
          return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  static String displayLabelFor(String id, {Map<String, String>? customLabels}) {
    final custom = customLabels?[id];
    if (custom != null && custom.isNotEmpty) return custom;

    final resolved = labelFor(id);
    if (resolved != id.replaceAll('_', ' ').replaceAll('-', ' ')) {
      return resolved;
    }
    return _titleCaseWords(resolved);
  }

  static String joinLabels(Iterable<String> ids, {Map<String, String>? customLabels}) {
    if (customLabels != null && customLabels.isNotEmpty) {
      return ids
          .map((id) => displayLabelFor(id, customLabels: customLabels))
          .join(' • ');
    }
    return ids.map((id) => displayLabelFor(id)).join(' • ');
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
