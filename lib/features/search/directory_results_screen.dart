import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/search/data/search_sort_engine.dart';
import 'package:smarthealth_shep/features/search/models/search_criteria.dart';
import 'package:smarthealth_shep/features/search/models/search_sort_option.dart';
import 'package:smarthealth_shep/features/search/widgets/search_operational_empty_state.dart';
import 'package:smarthealth_shep/features/search/widgets/search_sort_bar.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/facility_card.dart';
import 'package:smarthealth_shep/shared/widgets/provider_card.dart';

/// Directory listing for applied search filters.
class DirectoryResultsScreen extends StatefulWidget {
  const DirectoryResultsScreen({super.key, required this.criteria});

  final SearchCriteria criteria;

  @override
  State<DirectoryResultsScreen> createState() => _DirectoryResultsScreenState();
}

class _DirectoryResultsScreenState extends State<DirectoryResultsScreen> {
  late SearchSortOption _sortBy;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.criteria.sortBy;
  }

  List<FacilityModel> get _sortedFacilities =>
      SearchSortEngine.applyFacilities(widget.criteria.facilities, _sortBy);

  List<ProviderModel> get _sortedProviders =>
      SearchSortEngine.apply(widget.criteria.providers, _sortBy);

  int get _totalResults =>
      _sortedFacilities.length + _sortedProviders.length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final operationalEmpty = buildOperationalEmptyState(
      operational: widget.criteria.operational,
      resultCount: _totalResults,
      onClearFilters: () => context.pop(),
    );

    return AppShellScaffold(
      backgroundColor: HomeDashboardColors.background,
      appBar: AppBar(
        title: Text(l10n.searchResultsTitle),
        backgroundColor: HomeDashboardColors.background,
        leading: Semantics(
          button: true,
          label: 'Back',
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        actions: [
          if (_totalResults > 0)
            Semantics(
              button: true,
              label: l10n.searchMapView,
              child: IconButton(
                icon: const Icon(Symbols.map),
                onPressed: () => context.push(
                  '/search/map',
                  extra: widget.criteria.copyWithSort(
                    _sortBy,
                    _sortedProviders,
                    _sortedFacilities,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.criteria.isOffline)
            Container(
              color: HomeDashboardColors.warning.withValues(alpha: 0.15),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.searchOfflineHint,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: HomeDashboardColors.textSecondary,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.searchResultsCount(_totalResults),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: HomeDashboardColors.textPrimary,
              ),
            ),
          ),
          if (_totalResults > 0) ...[
            SearchSortBar(
              selected: _sortBy,
              onChanged: (sort) => setState(() => _sortBy = sort),
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: _totalResults == 0
                ? operationalEmpty ??
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.searchNoResults,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: HomeDashboardColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (_sortedFacilities.isNotEmpty) ...[
                        _SectionLabel(title: l10n.homeNearbyFacilities),
                        const SizedBox(height: 8),
                        for (var i = 0; i < _sortedFacilities.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          FacilityCard(
                            facility: _sortedFacilities[i],
                            onTap: () => context.push(
                              '/facility/${_sortedFacilities[i].id}?tab=1',
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                      if (_sortedProviders.isNotEmpty) ...[
                        _SectionLabel(title: l10n.homeNearbyProviders),
                        const SizedBox(height: 8),
                        for (var i = 0; i < _sortedProviders.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          ProviderCard(
                            provider: _sortedProviders[i],
                            onTap: () => context.push(
                              '/provider/${_sortedProviders[i].id}',
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: HomeDashboardColors.textPrimary,
      ),
    );
  }
}

extension on SearchCriteria {
  SearchCriteria copyWithSort(
    SearchSortOption sort,
    List<ProviderModel> sortedProviders,
    List<FacilityModel> sortedFacilities,
  ) {
    return SearchCriteria(
      query: query,
      specialties: specialties,
      conditions: conditions,
      ageGroups: ageGroups,
      operational: operational,
      providers: List.from(sortedProviders),
      facilities: List.from(sortedFacilities),
      isOffline: isOffline,
      sortBy: sort,
    );
  }
}
