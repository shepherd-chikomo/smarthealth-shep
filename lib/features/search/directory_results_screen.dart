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
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
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

  List<ProviderModel> get _sortedResults =>
      SearchSortEngine.apply(widget.criteria.results, _sortBy);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = _sortedResults;
    final operationalEmpty = buildOperationalEmptyState(
      operational: widget.criteria.operational,
      resultCount: results.length,
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
          if (results.isNotEmpty)
            Semantics(
              button: true,
              label: l10n.searchMapView,
              child: IconButton(
                icon: const Icon(Symbols.map),
                onPressed: () => context.push(
                  '/search/map',
                  extra: widget.criteria.copyWithSort(_sortBy, results),
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
              l10n.searchResultsCount(results.length),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: HomeDashboardColors.textPrimary,
              ),
            ),
          ),
          if (results.isNotEmpty) ...[
            SearchSortBar(
              selected: _sortBy,
              onChanged: (sort) => setState(() => _sortBy = sort),
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: results.isEmpty
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
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final provider = results[index];
                      return ProviderCard(
                        provider: provider,
                        onTap: () =>
                            context.push('/provider/${provider.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

extension on SearchCriteria {
  SearchCriteria copyWithSort(
    SearchSortOption sort,
    List<ProviderModel> sortedResults,
  ) {
    return SearchCriteria(
      query: query,
      specialties: specialties,
      conditions: conditions,
      ageGroups: ageGroups,
      operational: operational,
      results: List.from(sortedResults),
      isOffline: isOffline,
      sortBy: sort,
    );
  }
}
