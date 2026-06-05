import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/search/bloc/search_bloc.dart';
import 'package:smarthealth_shep/features/search/bloc/search_event.dart';
import 'package:smarthealth_shep/features/search/bloc/search_state.dart';
import 'package:smarthealth_shep/features/search/data/search_repository.dart';
import 'package:smarthealth_shep/features/search/search_filter_options.dart';
import 'package:smarthealth_shep/features/search/widgets/search_filter_chip.dart';
import 'package:smarthealth_shep/features/search/widgets/search_suggestions_panel.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => SearchBloc(repository: ref.read(searchRepositoryProvider)),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<SearchBloc, SearchState>(
      listenWhen: (previous, current) => current.navigateToResults,
      listener: (context, state) {
        context.push('/search/results', extra: state.criteria);
      },
      child: AppShellScaffold(
        backgroundColor: HomeDashboardColors.background,
        appBar: AppBar(
          title: Text(l10n.navSearch),
          backgroundColor: HomeDashboardColors.background,
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state.status == SearchStatus.loading &&
                state.allProviders.isEmpty &&
                state.allFacilities.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == SearchStatus.error &&
                state.allProviders.isEmpty &&
                state.allFacilities.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.searchErrorTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(state.errorMessage ?? ''),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: l10n.homeRetry,
                        onPressed: () => context
                            .read<SearchBloc>()
                            .add(const SearchReloadRequested()),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                if (state.isOffline)
                  Container(
                    width: double.infinity,
                    color: HomeDashboardColors.warning.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _SearchInputField(
                    controller: _controller,
                    hint: l10n.searchInputHint,
                    onChanged: (value) => context
                        .read<SearchBloc>()
                        .add(SearchQueryChanged(value)),
                    onSubmitted: (value) {
                      if (value.trim().isEmpty) return;
                      context
                          .read<SearchBloc>()
                          .add(const FiltersApplied());
                    },
                    onClear: () {
                      _controller.clear();
                      context
                          .read<SearchBloc>()
                          .add(const SearchQueryChanged(''));
                    },
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      if (!state.hasActiveCriteria)
                        SearchSuggestionsPanel(
                          recentSearches: state.recentSearches,
                          providers: state.allProviders,
                          facilities: state.allFacilities,
                          specialtyOptions: state.specialtyFilterOptions,
                          onQuerySelected: (query) {
                            _controller.text = query;
                            context
                                .read<SearchBloc>()
                                .add(SearchQueryChanged(query));
                            context
                                .read<SearchBloc>()
                                .add(const FiltersApplied());
                          },
                          onSpecialtySelected: (id) => context
                              .read<SearchBloc>()
                              .add(
                                FilterToggled(
                                  group: SearchFilterGroup.specialty,
                                  filterId: id,
                                ),
                              ),
                          onOperationalSelected: (id) => context
                              .read<SearchBloc>()
                              .add(
                                FilterToggled(
                                  group: SearchFilterGroup.operational,
                                  filterId: id,
                                ),
                              ),
                          onRecentRemoved: (query) => context
                              .read<SearchBloc>()
                              .add(RecentSearchRemoved(query)),
                          onFacilitySelected: (id) =>
                              context.push('/facility/$id?tab=1'),
                        ),
                      SearchFilterSection(
                        title: l10n.searchFilterSpecialty,
                        options: state.specialtyFilterOptions.isNotEmpty
                            ? state.specialtyFilterOptions
                            : SearchFilterOptions.specialties,
                        selectedIds: state.specialties,
                        group: SearchFilterGroup.specialty,
                        onToggle: (group, id) => context
                            .read<SearchBloc>()
                            .add(FilterToggled(group: group, filterId: id)),
                      ),
                      SearchFilterSection(
                        title: l10n.searchFilterCondition,
                        options: state.conditionFilterOptions.isNotEmpty
                            ? state.conditionFilterOptions
                            : SearchFilterOptions.conditions,
                        selectedIds: state.conditions,
                        group: SearchFilterGroup.condition,
                        onToggle: (group, id) => context
                            .read<SearchBloc>()
                            .add(FilterToggled(group: group, filterId: id)),
                      ),
                      SearchFilterSection(
                        title: l10n.searchFilterAgeGroup,
                        options: state.ageGroupFilterOptions.isNotEmpty
                            ? state.ageGroupFilterOptions
                            : SearchFilterOptions.ageGroups,
                        selectedIds: state.ageGroups,
                        group: SearchFilterGroup.ageGroup,
                        onToggle: (group, id) => context
                            .read<SearchBloc>()
                            .add(FilterToggled(group: group, filterId: id)),
                      ),
                      SearchFilterSection(
                        title: l10n.searchFilterOperational,
                        options: SearchFilterOptions.operational,
                        selectedIds: state.operational,
                        group: SearchFilterGroup.operational,
                        onToggle: (group, id) => context
                            .read<SearchBloc>()
                            .add(FilterToggled(group: group, filterId: id)),
                      ),
                      const SizedBox(height: 88),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: PrimaryButton(
                      label: l10n.searchApplyFilters(state.resultsCount),
                      onPressed: state.status == SearchStatus.loading ||
                              !state.hasActiveCriteria
                          ? null
                          : () => context
                              .read<SearchBloc>()
                              .add(const FiltersApplied()),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchInputField extends StatelessWidget {
  const _SearchInputField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: hint,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(
            Symbols.search,
            color: HomeDashboardColors.textSecondary,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return Semantics(
                button: true,
                label: 'Clear search',
                child: IconButton(
                  icon: const Icon(Symbols.close),
                  onPressed: onClear,
                ),
              );
            },
          ),
          filled: true,
          fillColor: HomeDashboardColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E8EE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E8EE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: HomeDashboardColors.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
