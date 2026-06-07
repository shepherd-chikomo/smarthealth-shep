import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/profile/models/condition_selection_result.dart';
import 'package:smarthealth_shep/features/profile/utils/condition_slug.dart';
import 'package:smarthealth_shep/features/profile/utils/profile_none_sentinel.dart';
import 'package:smarthealth_shep/features/search/search_filter_options.dart';

const _pageSize = 10;

/// Multi-select bottom sheet for medical profile conditions.
class ConditionSelectionSheet extends StatefulWidget {
  const ConditionSelectionSheet({
    super.key,
    required this.selectedIds,
    this.customLabels = const {},
    this.apiService,
  });

  final Set<String> selectedIds;
  final Map<String, String> customLabels;
  final ApiService? apiService;

  static Future<ConditionSelectionResult?> show(
    BuildContext context, {
    required Set<String> selectedIds,
    Map<String, String> customLabels = const {},
    ApiService? apiService,
  }) {
    return showModalBottomSheet<ConditionSelectionResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConditionSelectionSheet(
          selectedIds: selectedIds,
          customLabels: customLabels,
          apiService: apiService,
        ),
      ),
    );
  }

  @override
  State<ConditionSelectionSheet> createState() =>
      _ConditionSelectionSheetState();
}

class _ConditionSelectionSheetState extends State<ConditionSelectionSheet> {
  late Set<String> _selected;
  late Map<String, String> _customLabels;
  final _searchController = TextEditingController();
  final _otherController = TextEditingController();
  Timer? _searchDebounce;
  Timer? _suggestDebounce;

  List<SearchFilterOption> _catalog = [];
  final Set<String> _catalogSlugs = {};
  List<SearchFilterOption> _searchResults = [];
  List<SearchFilterOption> _suggestions = [];
  int _visibleCount = _pageSize;
  bool _loading = true;
  bool _searching = false;
  bool _suggestLoading = false;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selectedIds);
    _customLabels = Map<String, String>.from(widget.customLabels);
    _loadOptions();
    _searchController.addListener(_onSearchChanged);
    _otherController.addListener(_onOtherChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _suggestDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _otherController.removeListener(_onOtherChanged);
    _searchController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      final api = widget.apiService ?? ApiService(createApiDio());
      final remote = await api.fetchProfileConditions();
      if (!mounted) return;
      _applyCatalog([
        ...remote.common.map((e) => SearchFilterOption(id: e.id, label: e.label)),
        ...remote.other.map((e) => SearchFilterOption(id: e.id, label: e.label)),
      ]);
      return;
    } catch (_) {
      // fall through to static list
    }
    if (mounted) {
      _applyCatalog(SearchFilterOptions.conditions);
    }
  }

  void _applyCatalog(List<SearchFilterOption> options) {
    _catalogSlugs.clear();
    _catalog = options;
    for (final option in options) {
      _catalogSlugs.add(option.id);
    }
    setState(() => _loading = false);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), () async {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        if (mounted) {
          setState(() {
            _searchResults = [];
            _searching = false;
            _visibleCount = _pageSize;
          });
        }
        return;
      }

      setState(() => _searching = true);

      final local = _catalog
          .where(
            (o) =>
                o.label.toLowerCase().contains(query.toLowerCase()) ||
                o.id.toLowerCase().contains(query.toLowerCase()),
          )
          .take(20)
          .toList();

      try {
        final api = widget.apiService ?? ApiService(createApiDio());
        final remote = await api.suggestProfileConditions(query);
        if (!mounted) return;
        final merged = <String, SearchFilterOption>{};
        for (final option in remote) {
          merged[option.id] = SearchFilterOption(id: option.id, label: option.label);
        }
        for (final option in local) {
          merged.putIfAbsent(option.id, () => option);
        }
        setState(() {
          _searchResults = merged.values.take(20).toList();
          _searching = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _searchResults = local;
          _searching = false;
        });
      }
    });
  }

  void _onOtherChanged() {
    _suggestDebounce?.cancel();
    _suggestDebounce = Timer(const Duration(milliseconds: 300), () async {
      final query = _otherController.text.trim();
      if (query.isEmpty) {
        if (mounted) setState(() => _suggestions = []);
        return;
      }
      setState(() => _suggestLoading = true);
      try {
        final api = widget.apiService ?? ApiService(createApiDio());
        final remote = await api.suggestProfileConditions(query);
        if (!mounted) return;
        setState(() {
          _suggestions = remote
              .map((e) => SearchFilterOption(id: e.id, label: e.label))
              .take(8)
              .toList();
          _suggestLoading = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _suggestions = _catalog
              .where(
                (o) => o.label.toLowerCase().contains(query.toLowerCase()),
              )
              .take(8)
              .toList();
          _suggestLoading = false;
        });
      }
    });
  }

  void _toggle(String id) {
    setState(() {
      if (id == profileConditionsNoneSlug) {
        if (_selected.contains(profileConditionsNoneSlug)) {
          _selected.remove(profileConditionsNoneSlug);
        } else {
          _selected
            ..clear()
            ..add(profileConditionsNoneSlug);
          _customLabels.clear();
        }
        return;
      }

      _selected.remove(profileConditionsNoneSlug);

      if (_selected.contains(id)) {
        _selected.remove(id);
        _customLabels.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _selectSuggestion(SearchFilterOption option) {
    setState(() {
      _selected.remove(profileConditionsNoneSlug);
      _selected.add(option.id);
      _customLabels.remove(option.id);
      _otherController.clear();
      _suggestions = [];
    });
  }

  void _addCustomOther() {
    final label = _otherController.text.trim();
    if (label.isEmpty) return;
    final slug = toConditionSlug(label);
    if (slug.isEmpty) return;

    setState(() {
      _selected.remove(profileConditionsNoneSlug);
      _selected.add(slug);
      if (!_catalogSlugs.contains(slug)) {
        _customLabels[slug] = label;
      } else {
        _customLabels.remove(slug);
      }
      _otherController.clear();
      _suggestions = [];
    });
  }

  void _done() {
    final pending = _otherController.text.trim();
    if (pending.isNotEmpty) {
      final slug = toConditionSlug(pending);
      if (slug.isNotEmpty) {
        _selected.remove(profileConditionsNoneSlug);
        _selected.add(slug);
        if (!_catalogSlugs.contains(slug)) {
          _customLabels[slug] = pending;
        }
      }
    }
    Navigator.pop(
      context,
      ConditionSelectionResult(
        selectedIds: _selected,
        customLabels: Map<String, String>.from(_customLabels),
      ),
    );
  }

  List<SearchFilterOption> get _visibleCatalog {
    if (_searchController.text.trim().isNotEmpty) return _searchResults;
    return _catalog.take(_visibleCount).toList();
  }

  Widget _buildOptionTile(SearchFilterOption option) {
    final checked = _selected.contains(option.id);
    final label = _customLabels[option.id] ?? option.label;
    return CheckboxListTile(
      value: checked,
      title: Text(label),
      onChanged: (_) => _toggle(option.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);
    final isSearching = _searchController.text.trim().isNotEmpty;
    final visible = _visibleCatalog;

    return FractionallySizedBox(
      heightFactor: 0.88,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select conditions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: _done,
                  child: Text('Done (${_selected.length})'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conditions…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else ...[
            Expanded(
              child: ListView.builder(
                itemCount: 1 +
                    visible.length +
                    (_customLabels.length) +
                    (isSearching ? 0 : (_visibleCount < _catalog.length ? 1 : 0)),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return CheckboxListTile(
                      value: _selected.contains(profileConditionsNoneSlug),
                      title: const Text('No known conditions'),
                      onChanged: (_) => _toggle(profileConditionsNoneSlug),
                    );
                  }

                  final listIndex = index - 1;

                  if (listIndex < visible.length) {
                    if (!isSearching && listIndex == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Text(
                              isSearching ? 'Matches' : 'Conditions',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          _buildOptionTile(visible[listIndex]),
                        ],
                      );
                    }
                    return _buildOptionTile(visible[listIndex]);
                  }

                  var cursor = visible.length;
                  if (!isSearching && _visibleCount < _catalog.length) {
                    if (listIndex == cursor) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextButton(
                          onPressed: () => setState(
                            () => _visibleCount += _pageSize,
                          ),
                          child: Text(
                            'Load ${_pageSize} more (${_catalog.length - _visibleCount} remaining)',
                          ),
                        ),
                      );
                    }
                    cursor += 1;
                  }

                  final customIndex = listIndex - cursor;
                  final entry = _customLabels.entries.elementAt(customIndex);
                  return CheckboxListTile(
                    value: _selected.contains(entry.key),
                    title: Text(entry.value),
                    subtitle: const Text('Submitted for admin review'),
                    onChanged: (_) => _toggle(entry.key),
                  );
                },
              ),
            ),
            if (_searching)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Other condition',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _otherController,
                          decoration: InputDecoration(
                            hintText: 'Type your condition',
                            filled: true,
                            fillColor: colors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addCustomOther(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _addCustomOther,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  if (_suggestLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (_suggestions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _suggestions.map((option) {
                          return ActionChip(
                            label: Text(option.label),
                            onPressed: () => _selectSuggestion(option),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
