import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/design_system/widgets/practice_icon_widgets.dart';

class CredentialsScreen extends ConsumerWidget {
  const CredentialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    const providerId = 'seed-provider-001';

    return Scaffold(
      appBar: AppBar(title: const Text('Credential Wallet')),
      body: StreamBuilder<List<PractitionerCredential>>(
        stream: (db.select(db.practitionerCredentials)
              ..where((t) => t.providerId.equals(providerId))
              ..orderBy([(t) => OrderingTerm.asc(t.expiresAt)]))
            .watch(),
        builder: (context, snapshot) {
          final creds = snapshot.data ?? [];
          if (creds.isEmpty) {
            return const PracticeEmptyState(
              title: 'No credentials',
              message: 'APC certificates, licences, and CPD records appear here.',
              icon: Icons.badge_outlined,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Credential Wallet', style: PracticeDesignTokens.pageTitle(context)),
              Text(
                'Practising certificates and registrations',
                style: PracticeDesignTokens.metadata(context),
              ),
              const SizedBox(height: 16),
              ...creds.map((c) {
                final expires = c.expiresAt;
                final daysLeft = expires?.difference(DateTime.now()).inDays;
                final tone = daysLeft == null
                    ? PracticeStatusTone.neutral
                    : daysLeft < 30
                        ? PracticeStatusTone.danger
                        : daysLeft < 90
                            ? PracticeStatusTone.warning
                            : PracticeStatusTone.success;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: PracticeDesignTokens.previewCardDecoration(context),
                  child: Row(
                    children: [
                      PracticeIconBadge(
                        icon: Icons.verified_outlined,
                        color: tone.color(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title,
                                style: PracticeDesignTokens.inter(
                                  weight: FontWeight.w600,
                                )),
                            Text(
                              c.credentialType.toUpperCase(),
                              style: PracticeDesignTokens.metadata(context),
                            ),
                            if (expires != null)
                              Text(
                                'Expires ${_formatDate(expires)}',
                                style: PracticeDesignTokens.metadata(context),
                              ),
                          ],
                        ),
                      ),
                      if (daysLeft != null)
                        PracticeStatusChip(
                          label: daysLeft < 0
                              ? 'Expired'
                              : daysLeft == 0
                                  ? 'Today'
                                  : '$daysLeft days',
                          tone: tone,
                        ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
