import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/search/search_filter_options.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Contextual empty state for operational search filters.
class SearchOperationalEmptyState extends StatelessWidget {
  const SearchOperationalEmptyState({
    super.key,
    required this.operational,
    this.onClearFilters,
  });

  final Set<String> operational;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = _resolveMessage(l10n);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _resolveIcon(),
              size: 48,
              color: HomeDashboardColors.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: HomeDashboardColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.searchNoResultsHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: HomeDashboardColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (onClearFilters != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: onClearFilters,
                child: Text(l10n.searchClearFilters),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _resolveMessage(AppLocalizations l10n) {
    if (operational.contains('available_today')) {
      return l10n.searchEmptyAvailableToday;
    }
    if (operational.contains('walk_ins')) {
      return l10n.searchEmptyWalkIns;
    }
    if (operational.contains('queue_under_30')) {
      return l10n.searchEmptyQueueHigh;
    }
    return l10n.searchNoResults;
  }

  IconData _resolveIcon() {
    if (operational.contains('available_today')) {
      return Symbols.event_busy;
    }
    if (operational.contains('walk_ins')) {
      return Symbols.directions_walk;
    }
    if (operational.contains('queue_under_30')) {
      return Symbols.hourglass_top;
    }
    return Symbols.search_off;
  }
}

/// Resolves which operational empty state applies, if any.
SearchOperationalEmptyState? buildOperationalEmptyState({
  required Set<String> operational,
  required int resultCount,
  VoidCallback? onClearFilters,
}) {
  if (resultCount > 0) return null;

  final hasOperationalEmpty = operational.contains('available_today') ||
      operational.contains('walk_ins') ||
      operational.contains('queue_under_30');

  if (!hasOperationalEmpty) return null;

  return SearchOperationalEmptyState(
    operational: operational,
    onClearFilters: onClearFilters,
  );
}

/// Nearby facility suggestion derived from provider list.
class NearbyFacilitySuggestion {
  const NearbyFacilitySuggestion({
    required this.name,
    required this.distanceKm,
    required this.providerId,
  });

  final String name;
  final double distanceKm;
  final String providerId;
}

List<NearbyFacilitySuggestion> buildNearbyFacilitySuggestions(
  List<ProviderModel> providers, {
  int limit = 4,
}) {
  final seen = <String>{};
  final suggestions = <NearbyFacilitySuggestion>[];

  final sorted = List<ProviderModel>.from(providers)
    ..sort(
      (a, b) => (a.distanceKm ?? double.infinity)
          .compareTo(b.distanceKm ?? double.infinity),
    );

  for (final provider in sorted) {
    final facility = provider.facilityName;
    if (facility == null || seen.contains(facility)) continue;
    seen.add(facility);
    suggestions.add(
      NearbyFacilitySuggestion(
        name: facility,
        distanceKm: provider.distanceKm ?? 0,
        providerId: provider.id,
      ),
    );
    if (suggestions.length >= limit) break;
  }

  return suggestions;
}

/// Popular specialty shortcuts for discovery.
List<SearchFilterOption> get popularSpecialtySuggestions =>
    SearchFilterOptions.specialties.take(5).toList();
