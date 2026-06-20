import 'package:flutter/material.dart';
import 'package:my_practice/design_system/data/preview_seed_data.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/design_system/widgets/practice_icon_widgets.dart';
import 'package:my_practice/design_system/widgets/practice_preview_shell.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

/// High-fidelity dashboard preview.
class DashboardPreview extends StatelessWidget {
  const DashboardPreview({super.key});

  static const iconMap = {
    'calendar_today': Icons.calendar_month_outlined,
    'groups': Icons.groups_outlined,
    'check_circle': Icons.check_circle_outline,
    'request_quote': Icons.request_quote_outlined,
    'payments': Icons.payments_outlined,
    'assignment': Icons.assignment_outlined,
  };

  static const accentColors = PracticeDesignTokens.kpiAccents;

  @override
  Widget build(BuildContext context) {
    return PracticePreviewShell(
      selectedNavIndex: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardHeader(),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth > 900 ? 3 : (c.maxWidth > 600 ? 2 : 1);
                return GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.55,
                  children: [
                    for (var i = 0; i < PreviewSeedData.kpis.length; i++)
                      PracticeKpiCard(
                        label: PreviewSeedData.kpis[i].$1,
                        value: PreviewSeedData.kpis[i].$2,
                        trend: PreviewSeedData.kpis[i].$3,
                        icon: iconMap[PreviewSeedData.kpis[i].$4],
                        accentColor: accentColors[i],
                        sparkline: [0.4, 0.5, 0.45, 0.6, 0.55, 0.7],
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, c) {
                if (c.maxWidth < 800) {
                  return Column(
                    children: [
                      _QuickActionsCard(),
                      const SizedBox(height: 16),
                      _UpcomingCard(),
                      const SizedBox(height: 16),
                      _WaitingRoomCard(),
                      const SizedBox(height: 16),
                      _ClaimsActivityCard(),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _QuickActionsCard(),
                          const SizedBox(height: 16),
                          _UpcomingCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _WaitingRoomCard(),
                          const SizedBox(height: 16),
                          _ClaimsActivityCard(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            PracticeBarChart(
              title: 'Revenue Trends — Last 6 Months',
              labels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
              values: const [62, 70, 78, 75, 85, 82],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: PracticeDesignTokens.headerGradient(context),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning, ${PreviewSeedData.practitionerName}',
                    style: PracticeDesignTokens.pageTitle(context)),
                const SizedBox(height: 4),
                Text(
                  '${PreviewSeedData.todayLabel} · ${PreviewSeedData.facilityName}',
                  style: PracticeDesignTokens.metadata(context),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.medical_services_outlined, size: 18),
                  label: const Text('Start Consultation'),
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width > 600)
            PracticeIconBadge(
              icon: Icons.local_hospital_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 56,
              iconSize: 28,
            ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const actions = [
      (Icons.medical_services_outlined, 'Start Consultation'),
      (Icons.person_search_outlined, 'Search Patient'),
      (Icons.add_circle_outline, 'Add Appointment'),
      (Icons.medication_outlined, 'Create Prescription'),
      (Icons.groups_outlined, 'View Queue'),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: PracticeDesignTokens.sectionTitle(context)),
          const SizedBox(height: 12),
          for (final a in actions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: PracticeActionIcon(icon: a.$1),
              title: Text(a.$2),
              trailing: Icon(
                Icons.chevron_right,
                size: PracticeDesignTokens.iconMd,
                color: context.appColors.mutedForeground,
              ),
            ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PracticeSectionHeader(title: 'Next up', actionLabel: 'View all'),
          for (final a in PreviewSeedData.upcomingAppointments)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: PracticeAvatar(initials: a.$2, size: 36),
              title: Text('${a.$1} · ${a.$3}'),
              subtitle: Text(a.$4),
              trailing: PracticeStatusChip(
                label: a.$5,
                tone: PracticeStatusChip.toneForClaimStatus(a.$5),
              ),
            ),
        ],
      ),
    );
  }
}

class _WaitingRoomCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PracticeSectionHeader(title: 'Waiting room', actionLabel: 'Open queue'),
          for (final p in PreviewSeedData.queueWaiting)
            _QueueRow(
              initials: p.$1,
              name: p.$2,
              detail: '${p.$4} · ${p.$5}',
              meta: 'Arrived ${p.$6}',
              status: 'waiting',
            ),
          for (final p in PreviewSeedData.queueInConsult)
            _QueueRow(
              initials: p.$1,
              name: p.$2,
              detail: '${p.$4} · ${p.$5}',
              meta: 'Started ${p.$6}',
              status: 'in consult',
            ),
        ],
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.initials,
    required this.name,
    required this.detail,
    required this.meta,
    required this.status,
  });

  final String initials;
  final String name;
  final String detail;
  final String meta;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          PracticeAvatar(initials: initials, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
                Text(detail, style: PracticeDesignTokens.metadata(context)),
                Text(meta, style: PracticeDesignTokens.metadata(context)),
              ],
            ),
          ),
          PracticeStatusChip(
            label: status,
            tone: PracticeStatusChip.toneForClaimStatus(status),
          ),
        ],
      ),
    );
  }
}

class _ClaimsActivityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PracticeSectionHeader(
              title: 'Recent claims activity', actionLabel: 'View claims'),
          for (final c in PreviewSeedData.claimsActivity)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${c.$1} · ${c.$2} · ${c.$3}',
                        style: PracticeDesignTokens.inter(size: 13)),
                  ),
                  Text(c.$4,
                      style: PracticeDesignTokens.inter(
                        size: 13,
                        weight: FontWeight.w600,
                        color: c.$5 == true
                            ? context.appColors.success
                            : c.$5 == false
                                ? context.appColors.emergency
                                : Theme.of(context).colorScheme.primary,
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
