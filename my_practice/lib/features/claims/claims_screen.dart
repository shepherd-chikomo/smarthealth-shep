import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/repositories/claims_repository.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/shared/widgets/practice_more_app_bar.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class ClaimsScreen extends ConsumerStatefulWidget {
  const ClaimsScreen({super.key});

  @override
  ConsumerState<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends ConsumerState<ClaimsScreen> {
  static const _pipelineOrder = [
    ('submitted', 'Submitted', PracticeStatusTone.info),
    ('under_review', 'Under Review', PracticeStatusTone.warning),
    ('approved', 'Approved', PracticeStatusTone.success),
    ('paid', 'Paid', PracticeStatusTone.success),
    ('rejected', 'Rejected', PracticeStatusTone.danger),
    ('draft', 'Awaiting', PracticeStatusTone.neutral),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(claimsRepositoryProvider).refreshFromApi(),
    );
  }

  Future<void> _submitAllDrafts() async {
    final count = await ref.read(claimsRepositoryProvider).submitAllDrafts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Submitted $count draft claim${count == 1 ? '' : 's'}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final claimsRepo = ref.watch(claimsRepositoryProvider);

    return Scaffold(
      appBar: practiceMoreAppBar(context, 'Medical Aid Claims'),
      floatingActionButton: StreamBuilder<List<InsuranceClaim>>(
        stream: claimsRepo.watchClaims(),
        builder: (context, snapshot) {
          final drafts =
              (snapshot.data ?? []).where((c) => c.status == 'draft').length;
          if (drafts == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: _submitAllDrafts,
            icon: const Icon(Icons.send_outlined),
            label: Text('Submit $drafts draft${drafts == 1 ? '' : 's'}'),
          );
        },
      ),
      body: StreamBuilder<List<InsuranceClaim>>(
        stream: claimsRepo.watchClaims(),
        builder: (context, snapshot) {
          final claims = snapshot.data ?? [];
          final grouped = <String, int>{};
          for (final c in claims) {
            grouped[c.status] = (grouped[c.status] ?? 0) + 1;
          }

          return RefreshIndicator(
            onRefresh: () => claimsRepo.refreshFromApi(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text('Claims Pipeline',
                    style: PracticeDesignTokens.sectionTitle(context)),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, c) {
                    final cols = c.maxWidth > 600 ? 3 : 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final (key, label, tone) in _pipelineOrder)
                          SizedBox(
                            width: cols == 3
                                ? (c.maxWidth - 24) / 3
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
                                    '${grouped[key] ?? 0}',
                                    style: PracticeDesignTokens.kpiValueCompact(
                                      context,
                                    ),
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
                PracticeSectionHeader(title: 'Recent Claims'),
                if (claims.isEmpty)
                  const PracticeEmptyState(
                    title: 'No claims yet',
                    message: 'Insurance claims will appear here once submitted.',
                    icon: Icons.receipt_long_outlined,
                  )
                else
                  ...claims.take(30).map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ClaimTile(
                            claim: c,
                            onTap: () => _showClaimDetail(c),
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showClaimDetail(InsuranceClaim claim) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(claim.payerKey.toUpperCase(),
                style: PracticeDesignTokens.sectionTitle(ctx)),
            const SizedBox(height: 8),
            Text('Amount: \$${claim.amount.toStringAsFixed(2)}',
                style: PracticeDesignTokens.clinicalNote(ctx)),
            Text('Paid: \$${claim.amountPaid.toStringAsFixed(2)}',
                style: PracticeDesignTokens.metadata(ctx)),
            const SizedBox(height: 8),
            PracticeStatusChip(
              label: claim.status.replaceAll('_', ' '),
              tone: PracticeStatusChip.toneForClaimStatus(
                claim.status.replaceAll('_', ' '),
              ),
            ),
            if (claim.status == 'draft') ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  await ref.read(claimsRepositoryProvider).submitClaim(claim.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Claim submitted')),
                    );
                  }
                },
                icon: const Icon(Icons.send_outlined),
                label: const Text('Submit to medical aid'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClaimTile extends StatelessWidget {
  const _ClaimTile({required this.claim, required this.onTap});

  final InsuranceClaim claim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: PracticeDesignTokens.previewCardDecoration(context),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    claim.payerKey.toUpperCase(),
                    style: PracticeDesignTokens.inter(weight: FontWeight.w600),
                  ),
                  Text(
                    'Patient ${claim.patientId.split('-').last}',
                    style: PracticeDesignTokens.metadata(context),
                  ),
                ],
              ),
            ),
            PracticeStatusChip(
              label: claim.status.replaceAll('_', ' '),
              tone: PracticeStatusChip.toneForClaimStatus(
                claim.status.replaceAll('_', ' '),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '\$${claim.amount.toStringAsFixed(2)}',
              style: PracticeDesignTokens.inter(weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
