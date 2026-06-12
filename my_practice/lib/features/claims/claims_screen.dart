import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';

class ClaimsScreen extends ConsumerWidget {
  const ClaimsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';

    return Scaffold(
      appBar: AppBar(title: const Text('Medical Aid Claims')),
      body: StreamBuilder<List<InsuranceClaim>>(
        stream: (db.select(db.insuranceClaims)
              ..where((t) => t.facilityId.equals(facilityId))
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
            .watch(),
        builder: (context, snapshot) {
          final claims = snapshot.data ?? [];
          if (claims.isEmpty) {
            return const Center(child: Text('No claims'));
          }

          final grouped = <String, int>{};
          for (final c in claims) {
            grouped[c.status] = (grouped[c.status] ?? 0) + 1;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                children: grouped.entries
                    .map((e) => Chip(label: Text('${e.key}: ${e.value}')))
                    .toList(),
              ),
              const SizedBox(height: 16),
              ...claims.take(50).map(
                    (c) => ListTile(
                      title: Text('${c.payerKey.toUpperCase()} · ${c.status}'),
                      subtitle: Text('Patient ${c.patientId.split('-').last}'),
                      trailing: Text('\$${c.amount.toStringAsFixed(2)}'),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
