import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsFuture = ref.watch(_dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {},
            tooltip: 'Sync status',
          ),
        ],
      ),
      body: statsFuture.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatGrid(stats: stats),
            const SizedBox(height: 16),
            Text('Quick Actions', style: AppTextStyles.lg(fontWeight: AppTextStyles.semibold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickAction(
                  label: 'View Queue',
                  icon: Icons.groups,
                  onTap: () => context.go('/queue'),
                ),
                _QuickAction(
                  label: 'Start Consultation',
                  icon: Icons.medical_services,
                  onTap: () => context.go('/patients'),
                ),
                _QuickAction(
                  label: 'Search Patient',
                  icon: Icons.person_search,
                  onTap: () => context.go('/patients'),
                ),
                _QuickAction(
                  label: 'Calendar',
                  icon: Icons.calendar_month,
                  onTap: () => context.go('/calendar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final _dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(dashboardRepositoryProvider).getDashboardStats();
});

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Today\'s Appointments', stats['appointmentsToday']),
      ('Waiting Patients', stats['queueSize']),
      ('Encounters Done', stats['encountersCompleted']),
      ('Revenue Today', stats['revenueToday']),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: items
          .map(
            (e) => AppTheme.themedCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.$1,
                    style: AppTextStyles.sm(
                      color: context.appColors.mutedForeground,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${e.$2}',
                    style: AppTextStyles.xl(fontWeight: AppTextStyles.bold),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
