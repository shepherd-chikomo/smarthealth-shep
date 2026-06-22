import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/data/sync/sync_notifier.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/design_system/widgets/practice_icon_widgets.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsFuture = ref.watch(_dashboardStatsProvider);
    final sync = ref.watch(syncNotifierProvider);
    final auth = ref.watch(authStateProvider);
    final queueStream = ref.watch(queueRepositoryProvider).watchQueue();
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return ColoredBox(
      color: context.appColors.background,
      child: statsFuture.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DashboardHeader(auth: auth, ref: ref, isMobile: isMobile),
              if (!isMobile &&
                  (sync.pendingMutations > 0 || sync.lastSyncedAt != null)) ...[
                const SizedBox(height: 12),
                Text(
                  sync.pendingMutations > 0
                      ? '${sync.pendingMutations} change(s) waiting to sync'
                      : 'Last synced ${_formatSyncTime(sync.lastSyncedAt!)}',
                  style: PracticeDesignTokens.metadata(context),
                ),
              ],
              const SizedBox(height: 16),
              _KpiGrid(stats: stats, compact: isMobile),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, c) {
                  if (c.maxWidth < 800) {
                    return Column(
                      children: [
                        _QuickActionsCard(
                          onNavigate: (r) {
                            if (r == '/tasks') {
                              context.push(r);
                            } else {
                              context.go(r);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<QueueEntry>>(
                          stream: queueStream,
                          builder: (context, snap) => _WaitingRoomCard(
                            entries: snap.data ?? [],
                            ref: ref,
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child:
                            _QuickActionsCard(
                          onNavigate: (r) {
                            if (r == '/tasks') {
                              context.push(r);
                            } else {
                              context.go(r);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StreamBuilder<List<QueueEntry>>(
                          stream: queueStream,
                          builder: (context, snap) => _WaitingRoomCard(
                            entries: snap.data ?? [],
                            ref: ref,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader({
    required this.auth,
    required this.ref,
    required this.isMobile,
  });

  final AuthState auth;
  final WidgetRef ref;
  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final facilityId = ref.watch(facilityIdProvider);
    final facilityName =
        auth.profile?.facilityNameFor(facilityId) ?? 'MyPractice Facility';
    final name = auth.profile?.displayName ?? 'Practitioner';
    final greeting = _greeting();
    final titleStyle = isMobile
        ? PracticeDesignTokens.mobilePageTitle(context)
        : PracticeDesignTokens.pageTitle(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: PracticeDesignTokens.headerGradient(context),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$greeting, $name', style: titleStyle),
          const SizedBox(height: 4),
          Text(
            '${_todayLabel()} · $facilityName',
            style: PracticeDesignTokens.metadata(context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go('/patients'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Start Consultation'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _todayLabel() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.stats, required this.compact});

  final Map<String, dynamic> stats;
  final bool compact;

  static const _accents = PracticeDesignTokens.kpiAccents;
  static const _sparkline = [0.4, 0.5, 0.45, 0.6, 0.55, 0.7];

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Today\'s Appointments',
        '${stats['appointmentsToday'] ?? 0}',
        Icons.calendar_month_outlined,
      ),
      (
        'Waiting Patients',
        '${stats['queueSize'] ?? 0}',
        Icons.groups_outlined,
      ),
      (
        'Encounters Done',
        '${stats['encountersCompleted'] ?? 0}',
        Icons.check_circle_outline,
      ),
      (
        'Revenue Today',
        _formatRevenue(stats['revenueToday']),
        Icons.payments_outlined,
      ),
    ];

    if (compact) {
      return Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            PracticeKpiCard(
              label: items[i].$1,
              value: items[i].$2,
              icon: items[i].$3,
              accentColor: _accents[i],
              sparkline: _sparkline,
              layout: PracticeKpiLayout.compact,
            ),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth > 900) {
          // 4 equal columns — use Row so cards size to their natural height.
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(
                    child: PracticeKpiCard(
                      label: items[i].$1,
                      value: items[i].$2,
                      icon: items[i].$3,
                      accentColor: _accents[i],
                      sparkline: _sparkline,
                    ),
                  ),
                ],
              ],
            ),
          );
        }
        // 2-column layout: two rows of two cards.
        return Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: PracticeKpiCard(
                      label: items[0].$1,
                      value: items[0].$2,
                      icon: items[0].$3,
                      accentColor: _accents[0],
                      sparkline: _sparkline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PracticeKpiCard(
                      label: items[1].$1,
                      value: items[1].$2,
                      icon: items[1].$3,
                      accentColor: _accents[1],
                      sparkline: _sparkline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: PracticeKpiCard(
                      label: items[2].$1,
                      value: items[2].$2,
                      icon: items[2].$3,
                      accentColor: _accents[2],
                      sparkline: _sparkline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PracticeKpiCard(
                      label: items[3].$1,
                      value: items[3].$2,
                      icon: items[3].$3,
                      accentColor: _accents[3],
                      sparkline: _sparkline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static String _formatRevenue(dynamic value) {
    final amount = value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    if (amount == amount.roundToDouble()) {
      return '\$${amount.round()}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({required this.onNavigate});

  final void Function(String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    const actions = [
      (Icons.medical_services_outlined, 'New Consultation', '/patients'),
      (Icons.person_search_outlined, 'Search Patients', '/patients'),
      (Icons.calendar_month_outlined, 'Book Appointment', '/calendar'),
      (Icons.groups_outlined, 'Open Queue', '/queue'),
      (Icons.task_alt_outlined, 'Clinical Tasks', '/tasks'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions',
              style: PracticeDesignTokens.sectionTitle(context)),
          const SizedBox(height: 8),
          for (final a in actions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              leading: PracticeActionIcon(icon: a.$1),
              title: Text(a.$2),
              trailing: Icon(
                Icons.chevron_right,
                size: PracticeDesignTokens.iconMd,
                color: context.appColors.mutedForeground,
              ),
              onTap: () => onNavigate(a.$3),
            ),
        ],
      ),
    );
  }
}

class _WaitingRoomCard extends StatelessWidget {
  const _WaitingRoomCard({required this.entries, required this.ref});

  final List<QueueEntry> entries;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final active = entries
        .where((e) => e.status != 'completed')
        .take(5)
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PracticeSectionHeader(
            title: 'Waiting room',
            actionLabel: 'Open queue',
            onAction: () => context.go('/queue'),
          ),
          if (active.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Queue is empty',
                  style: PracticeDesignTokens.metadata(context)),
            )
          else
            for (final e in active)
              _WaitingRoomRow(entry: e, ref: ref),
        ],
      ),
    );
  }
}

class _WaitingRoomRow extends StatelessWidget {
  const _WaitingRoomRow({required this.entry, required this.ref});

  final QueueEntry entry;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Patient?>(
      future: ref.read(patientRepositoryProvider).findById(entry.patientId),
      builder: (context, snapshot) {
        final patient = snapshot.data;
        final name = patient == null
            ? 'Patient ${entry.patientId.split('-').last}'
            : '${patient.firstName} ${patient.lastName}';
        final initials = patient == null
            ? '#${entry.position}'
            : '${patient.firstName.isNotEmpty ? patient.firstName[0] : 'P'}'
                '${patient.lastName.isNotEmpty ? patient.lastName[0] : 'R'}'
                .toUpperCase();
        final detail = patient == null
            ? (entry.triageStatus ?? 'Consultation')
            : _patientDetail(patient, entry);

        return InkWell(
          onTap: () => context.push('/encounter/${entry.patientId}?queueEntryId=${entry.id}'),
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                PracticeAvatar(initials: initials, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: PracticeDesignTokens.inter(
                          weight: FontWeight.w600,
                          size: 14,
                        ),
                      ),
                      Text(
                        detail,
                        style: PracticeDesignTokens.metadata(context),
                      ),
                    ],
                  ),
                ),
                PracticeStatusChip(
                  label: PracticeStatusChip.labelForQueueStatus(entry.status),
                  tone: PracticeStatusChip.toneForClaimStatus(entry.status),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: PracticeDesignTokens.iconMd,
                  color: context.appColors.mutedForeground,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _patientDetail(Patient patient, QueueEntry entry) {
    final parts = <String>[];
    if (patient.dateOfBirth != null) {
      final age = DateTime.now().year - patient.dateOfBirth!.year;
      parts.add('$age');
    }
    if (patient.gender != null && patient.gender!.isNotEmpty) {
      parts.add(patient.gender!.substring(0, 1).toUpperCase());
    }
    final demo = parts.isEmpty ? null : parts.join(' · ');
    final reason = entry.triageStatus ?? 'Consultation';
    return demo == null ? reason : '$demo · $reason';
  }
}

String _formatSyncTime(DateTime at) {
  final local = at.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

final _dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(dashboardRepositoryProvider).getDashboardStats();
});
