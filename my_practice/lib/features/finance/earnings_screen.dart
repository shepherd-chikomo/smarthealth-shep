import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';

    return Scaffold(
      appBar: AppBar(title: const Text('Practitioner Earnings')),
      body: StreamBuilder<List<FinancialSummary>>(
        stream: (db.select(db.financialSummaries)
              ..where((t) => t.facilityId.equals(facilityId))
              ..orderBy([(t) => OrderingTerm.desc(t.period)]))
            .watch(),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) {
            return const PracticeEmptyState(
              title: 'No earnings data',
              message: 'Financial summaries will appear after billing activity.',
              icon: Icons.payments_outlined,
            );
          }

          final latest = rows.first;
          final gross = latest.revenue;
          final outstanding = latest.outstanding;
          final collected = gross - outstanding;
          final share = collected * 0.6;

          final chartRows = rows.take(6).toList().reversed.toList();
          final chartLabels = chartRows.map((r) => r.period.split('-').last).toList();
          final chartValues = chartRows.map((r) => r.revenue / 1000).toList();
          final maxY = chartValues.isEmpty
              ? 100.0
              : chartValues.reduce((a, b) => a > b ? a : b) * 1.2;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Practitioner Earnings', style: PracticeDesignTokens.pageTitle(context)),
              Text(
                'Multi-facility revenue share · ${latest.period}',
                style: PracticeDesignTokens.metadata(context),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, c) {
                  final cols = c.maxWidth > 600 ? 4 : 2;
                  final cardWidth = cols == 4
                      ? (c.maxWidth - 36) / 4
                      : (c.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: PracticeKpiCard(
                          label: 'Gross Billings',
                          value: '\$${gross.toStringAsFixed(0)}',
                          trend: 'Latest period',
                          layout: PracticeKpiLayout.compact,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: PracticeKpiCard(
                          label: 'Collected',
                          value: '\$${collected.toStringAsFixed(0)}',
                          trend:
                              '${((collected / gross) * 100).toStringAsFixed(0)}%',
                          layout: PracticeKpiLayout.compact,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: PracticeKpiCard(
                          label: 'Outstanding',
                          value: '\$${outstanding.toStringAsFixed(0)}',
                          trend: 'Claims pending',
                          accentColor: Theme.of(context).colorScheme.error,
                          layout: PracticeKpiLayout.compact,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: PracticeKpiCard(
                          label: 'Revenue Share',
                          value: '\$${share.toStringAsFixed(0)}',
                          trend: '60% share',
                          layout: PracticeKpiLayout.compact,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              PracticeBarChart(
                title: 'Monthly Revenue Trend (USD thousands)',
                labels: chartLabels,
                values: chartValues,
                maxY: maxY,
              ),
              const SizedBox(height: 16),
              PracticeSectionHeader(title: 'Period breakdown'),
              ...rows.take(6).map(
                    (r) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: PracticeDesignTokens.previewCardDecoration(context),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Period ${r.period}',
                                    style: PracticeDesignTokens.inter(
                                      weight: FontWeight.w600,
                                    )),
                                Text(
                                  'Expenses \$${r.expenses.toStringAsFixed(0)}',
                                  style: PracticeDesignTokens.metadata(context),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${r.revenue.toStringAsFixed(0)}',
                            style: PracticeDesignTokens.kpiValueCompact(context),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
