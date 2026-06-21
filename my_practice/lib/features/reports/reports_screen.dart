import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const _categories = [
    ('Operational Reports', 'Queue, utilisation, staff activity'),
    ('Clinical Reports', 'Diagnoses, medications, disease trends'),
    ('Financial Reports', 'Revenue, claims performance, collections'),
    ('Practitioner Reports', 'Productivity and earnings by provider'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: StreamBuilder<List<FinancialSummary>>(
        stream: (db.select(db.financialSummaries)
              ..where((t) => t.facilityId.equals(facilityId))
              ..orderBy([(t) => OrderingTerm.desc(t.period)]))
            .watch(),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Report Center', style: PracticeDesignTokens.sectionTitle(context)),
              Text(
                'Generate and export operational reports',
                style: PracticeDesignTokens.metadata(context),
              ),
              const SizedBox(height: 16),
              for (final cat in _categories) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: PracticeDesignTokens.previewCardDecoration(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description_outlined,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(cat.$1,
                                style: PracticeDesignTokens.sectionTitle(context)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(cat.$2, style: PracticeDesignTokens.metadata(context)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () => _exportSnack(context, cat.$1, 'PDF'),
                            child: const Text('PDF'),
                          ),
                          OutlinedButton(
                            onPressed: () => _exportSnack(context, cat.$1, 'Excel'),
                            child: const Text('Excel'),
                          ),
                          OutlinedButton(
                            onPressed: () => _exportSnack(context, cat.$1, 'CSV'),
                            child: const Text('CSV'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (rows.isNotEmpty) ...[
                const SizedBox(height: 12),
                PracticeSectionHeader(title: 'Financial Summaries'),
                ...rows.map(
                  (r) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: PracticeDesignTokens.previewCardDecoration(context),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Period ${r.period}'),
                      subtitle: Text(
                        'Revenue \$${r.revenue.toStringAsFixed(0)} · Outstanding \$${r.outstanding.toStringAsFixed(0)}',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _exportSnack(BuildContext context, String category, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$format export for $category — dev mode preview')),
    );
  }
}
