import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

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
              const ListTile(
                title: Text('Practitioner Earnings'),
                subtitle: Text('Multi-facility revenue share'),
              ),
              ...rows.map(
                (r) => ListTile(
                  title: Text('Period ${r.period}'),
                  subtitle: Text(
                    'Revenue \$${r.revenue.toStringAsFixed(0)} · Outstanding \$${r.outstanding.toStringAsFixed(0)}',
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
