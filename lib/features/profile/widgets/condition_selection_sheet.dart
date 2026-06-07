import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/profile/models/condition_selection_result.dart';
import 'package:smarthealth_shep/features/profile/utils/condition_slug.dart';
import 'package:smarthealth_shep/features/search/search_filter_options.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';

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
  final _otherController = TextEditingController();
  Timer? _suggestDebounce;

  List<SearchFilterOption> _common = [];
  List<SearchFilterOption> _other = [];
  final Set<String> _catalogSlugs = {};
  List<SearchFilterOption> _suggestions = [];
  bool _loading = true;
  bool _showMore = false;
  bool _suggestLoading = false;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selectedIds);
    _customLabels = Map<String, String>.from(widget.customLabels);
    _loadOptions();
    _otherController.addListener(_onOtherChanged);
  }

  @override
  void dispose() {
    _suggestDebounce?.cancel();
    _otherController.removeListener(_onOtherChanged);
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      final api = widget.apiService ?? ApiService(createApiDio());
      final remote = await api.fetchProfileConditions();
      if (!mounted) return;
      _applyCatalog(remote.common, remote.other);
      return;
    } catch (_) {
      // fall through to static list
    }
    if (mounted) {
      final fallback = SearchFilterOptions.conditions
          .map((e) => (id: e.id, label: e.label))
          .toList();
      _applyCatalog(fallback, const []);
    }
  }

  void _applyCatalog(
    List<({String id, String label})> common,
    List<({String id, String label})> other,
  ) {
    _catalogSlugs.clear();
    _common = common
        .map((e) => SearchFilterOption(id: e.id, label: e.label))
        .toList();
    _other = other
        .map((e) => SearchFilterOption(id: e.id, label: e.label))
        .toList();
    for (final option in [..._common, ..._other]) {
      _catalogSlugs.add(option.id);
    }
    setState(() => _loading = false);
  }

  void _onOtherChanged() {
    _suggestDebounce?.cancel();
    _suggestDebounce = Timer(const Duration(milliseconds: 250), () async {
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
              .toList();
          _suggestLoading = false;
        });
      } catch (_) {
        if (!mounted) return;
        final local = [..._common, ..._other]
            .where(
              (o) =>
                  o.label.toLowerCase().contains(query.toLowerCase()) ||
                  o.id.toLowerCase().contains(query.toLowerCase()),
            )
            .take(8)
            .toList();
        setState(() {
          _suggestions = local;
          _suggestLoading = false;
        });
      }
    });
  }

  void _toggle(String id) {
    setState(() {
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
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
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
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'Common conditions',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    ..._common.map(_buildOptionTile),
                    if (_other.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: TextButton(
                          onPressed: () => setState(() => _showMore = !_showMore),
                          child: Text(
                            _showMore ? l10n.profileShowLess : l10n.profileShowMore,
                          ),
                        ),
                      ),
                      if (_showMore) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text(
                            'More conditions',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                        ..._other.map(_buildOptionTile),
                      ],
                    ],
                    const Divider(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Other condition',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
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
                    ),
                    if (_suggestLoading)
                      const Padding(
                        padding: EdgeInsets.all(12),
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
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                    if (_customLabels.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Custom (pending review)',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      ..._customLabels.entries.map((entry) {
                        final checked = _selected.contains(entry.key);
                        return CheckboxListTile(
                          value: checked,
                          title: Text(entry.value),
                          subtitle: const Text('Submitted for admin review'),
                          onChanged: (_) => _toggle(entry.key),
                        );
                      }),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
