import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/shared/utils/patient_formatters.dart';

class ReceivablesScreen extends ConsumerWidget {
  const ReceivablesScreen({super.key});

  static const _buckets = [
    ('0–30 days', 0, 30, PracticeStatusTone.success),
    ('31–60 days', 31, 60, PracticeStatusTone.warning),
    ('61–90 days', 61, 90, PracticeStatusTone.warning),
    ('90+ days', 91, 9999, PracticeStatusTone.danger),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts Receivable')),
      body: StreamBuilder<List<InsuranceClaim>>(
        stream: (db.select(db.insuranceClaims)
              ..where((t) => t.facilityId.equals(facilityId))
              ..orderBy([(t) => OrderingTerm.desc(t.submittedAt)]))
            .watch(),
        builder: (context, snapshot) {
          final claims = snapshot.data ?? [];
          final now = DateTime.now();
          final open = claims
              .map((c) {
                final balance = c.amount - c.amountPaid;
                if (balance <= 0 ||
                    c.status == 'paid' ||
                    c.status == 'rejected') {
                  return null;
                }
                final anchor = c.submittedAt ?? c.updatedAt;
                final days = now.difference(anchor).inDays;
                return _ArLine(claim: c, balance: balance, days: days);
              })
              .whereType<_ArLine>()
              .toList();

          final bucketTotals = {
            for (final (label, _, _, _) in _buckets) label: 0.0,
          };
          for (final line in open) {
            for (final (label, min, max, _) in _buckets) {
              if (line.days >= min && line.days <= max) {
                bucketTotals[label] = bucketTotals[label]! + line.balance;
              }
            }
          }
          final totalOutstanding =
              open.fold<double>(0, (sum, line) => sum + line.balance);

          if (open.isEmpty) {
            return const PracticeEmptyState(
              title: 'No outstanding receivables',
              message: 'Unpaid claims and patient balances appear here.',
              icon: Icons.account_balance_wallet_outlined,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Accounts Receivable',
                  style: PracticeDesignTokens.pageTitle(context)),
              Text(
                '\$${totalOutstanding.toStringAsFixed(0)} outstanding · ${open.length} items',
                style: PracticeDesignTokens.metadata(context),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, c) {
                  final cols = c.maxWidth > 600 ? 4 : 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final (label, min, max, tone) in _buckets)
                        SizedBox(
                          width: cols == 4
                              ? (c.maxWidth - 36) / 4
                              : (c.maxWidth - 12) / 2,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: PracticeDesignTokens.previewCardDecoration(
                              context,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PracticeStatusChip(label: label, tone: tone),
                                const SizedBox(height: 12),
                                Text(
                                  '\$${bucketTotals[label]!.toStringAsFixed(0)}',
                                  style:
                                      PracticeDesignTokens.kpiValueCompact(context),
                                ),
                                Text(
                                  '${open.where((l) => l.days >= min && l.days <= max).length} items',
                                  style: PracticeDesignTokens.metadata(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              PracticeSectionHeader(title: 'Ageing detail'),
              ...open.map(
                (line) => _ArRow(db: db, line: line),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ArLine {
  const _ArLine({
    required this.claim,
    required this.balance,
    required this.days,
  });

  final InsuranceClaim claim;
  final double balance;
  final int days;
}

class _ArRow extends StatelessWidget {
  const _ArRow({required this.db, required this.line});

  final AppDatabase db;
  final _ArLine line;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Patient?>(
      future: (db.select(db.patients)
            ..where((t) => t.id.equals(line.claim.patientId)))
          .getSingleOrNull(),
      builder: (context, snapshot) {
        final patient = snapshot.data;
        final name = patient != null
            ? PatientFormatters.fullName(patient)
            : line.claim.patientId;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: PracticeDesignTokens.previewCardDecoration(context),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: PracticeDesignTokens.inter(
                        weight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${PatientFormatters.insurerLabel(line.claim.payerKey)} · ${line.days}d · ${line.claim.status.replaceAll('_', ' ')}',
                      style: PracticeDesignTokens.metadata(context),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${line.balance.toStringAsFixed(0)}',
                style: PracticeDesignTokens.kpiValueCompact(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
