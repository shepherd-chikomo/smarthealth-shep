import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/search/widgets/search_operational_empty_state.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Discovery shortcuts shown when search has no active criteria.
class SearchSuggestionsPanel extends StatelessWidget {
  const SearchSuggestionsPanel({
    super.key,
    required this.recentSearches,
    required this.providers,
    required this.onQuerySelected,
    required this.onSpecialtySelected,
    required this.onOperationalSelected,
    required this.onRecentRemoved,
  });

  final List<String> recentSearches;
  final List<ProviderModel> providers;
  final ValueChanged<String> onQuerySelected;
  final ValueChanged<String> onSpecialtySelected;
  final ValueChanged<String> onOperationalSelected;
  final ValueChanged<String> onRecentRemoved;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nearby = buildNearbyFacilitySuggestions(providers);
    final specialties = popularSpecialtySuggestions;

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (recentSearches.isNotEmpty)
          _SuggestionSection(
            title: l10n.searchRecentSearches,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final query in recentSearches)
                  _RecentSearchChip(
                    label: query,
                    onTap: () => onQuerySelected(query),
                    onRemove: () => onRecentRemoved(query),
                  ),
              ],
            ),
          ),
        _SuggestionSection(
          title: l10n.searchPopularSpecialties,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final specialty in specialties)
                _SuggestionChip(
                  label: specialty.label,
                  icon: Symbols.medical_services,
                  onTap: () => onSpecialtySelected(specialty.id),
                ),
            ],
          ),
        ),
        if (nearby.isNotEmpty)
          _SuggestionSection(
            title: l10n.searchNearbyFacilities,
            child: Column(
              children: [
                for (final facility in nearby)
                  _NearbyFacilityTile(
                    name: facility.name,
                    distanceKm: facility.distanceKm,
                    onTap: () => onQuerySelected(facility.name),
                  ),
              ],
            ),
          ),
        _SuggestionSection(
          title: l10n.searchEmergencyShortcuts,
          child: Column(
            children: [
              _EmergencyShortcutTile(
                label: l10n.searchEmergencyNearMe,
                icon: Symbols.emergency,
                color: HomeDashboardColors.emergency,
                onTap: () => onOperationalSelected('emergency'),
              ),
              _EmergencyShortcutTile(
                label: l10n.searchOpenNowShortcut,
                icon: Symbols.schedule,
                color: HomeDashboardColors.primary,
                onTap: () => onOperationalSelected('open_now'),
              ),
              _EmergencyShortcutTile(
                label: l10n.searchEmergencyHub,
                icon: Symbols.local_hospital,
                color: HomeDashboardColors.secondary,
                onTap: () => context.go('/emergency'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuggestionSection extends StatelessWidget {
  const _SuggestionSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: HomeDashboardColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: HomeDashboardColors.surface,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE5E8EE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: HomeDashboardColors.primary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: HomeDashboardColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentSearchChip extends StatelessWidget {
  const _RecentSearchChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Recent search: $label',
      child: Material(
        color: HomeDashboardColors.surface,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE5E8EE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Symbols.history,
                  size: 16,
                  color: HomeDashboardColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: HomeDashboardColors.textPrimary,
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Remove $label',
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    iconSize: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Symbols.close,
                      color: HomeDashboardColors.textSecondary,
                    ),
                    onPressed: onRemove,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NearbyFacilityTile extends StatelessWidget {
  const _NearbyFacilityTile({
    required this.name,
    required this.distanceKm,
    required this.onTap,
  });

  final String name;
  final double distanceKm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: name,
      child: Material(
        color: HomeDashboardColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E8EE)),
            ),
            child: Row(
              children: [
                const Icon(
                  Symbols.location_on,
                  size: 20,
                  color: HomeDashboardColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: HomeDashboardColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  l10n.homeDistanceKm(distanceKm),
                  style: const TextStyle(
                    fontSize: 12,
                    color: HomeDashboardColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmergencyShortcutTile extends StatelessWidget {
  const _EmergencyShortcutTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: HomeDashboardColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E8EE)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: HomeDashboardColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Symbols.chevron_right,
                  size: 20,
                  color: HomeDashboardColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
