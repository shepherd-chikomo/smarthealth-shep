import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/search/models/search_criteria.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/provider_card.dart';

/// Directory listing for applied search filters.
class DirectoryResultsScreen extends StatelessWidget {
  const DirectoryResultsScreen({super.key, required this.criteria});

  final SearchCriteria criteria;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (criteria.isOffline)
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
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.searchResultsCount(criteria.results.length),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: HomeDashboardColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: criteria.results.isEmpty
                ? Center(
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
                    itemCount: criteria.results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final provider = criteria.results[index];
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
