import 'package:flutter/material.dart';
import 'package:my_practice/design_system/data/preview_seed_data.dart';
import 'package:my_practice/design_system/previews/dashboard_preview.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/design_system/widgets/practice_preview_shell.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class ClaimsPreview extends StatelessWidget {
  const ClaimsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    const pipeline = [
      ('Submitted', '24', PracticeStatusTone.info),
      ('Under Review', '8', PracticeStatusTone.warning),
      ('Approved', '16', PracticeStatusTone.success),
      ('Paid', '42', PracticeStatusTone.success),
      ('Rejected', '3', PracticeStatusTone.danger),
      ('Overdue', '5', PracticeStatusTone.queue),
    ];

    return PracticePreviewShell(
      selectedNavIndex: 8,
      title: 'Claims & Medical Aid',
      subtitle: 'Pipeline and insurer performance',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth > 800 ? 3 : (c.maxWidth > 500 ? 2 : 1);
                return GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.4,
                  children: [
                    for (final p in pipeline)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: PracticeDesignTokens.previewCardDecoration(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PracticeStatusChip(label: p.$1, tone: p.$3),
                            const Spacer(),
                            Text(p.$2, style: PracticeDesignTokens.kpiValue(context)),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            PracticeSectionHeader(title: 'Insurer Performance'),
            Container(
              decoration: PracticeDesignTokens.previewCardDecoration(context),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        for (final h in [
                          'INSURER',
                          'CLAIMED',
                          'PAID',
                          'OUTSTANDING',
                          'AVG DAYS',
                          'APPROVAL',
                        ])
                          Expanded(
                            child: Text(h, style: PracticeDesignTokens.tableHeader(context)),
                          ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: context.appColors.border),
                  for (final ins in PreviewSeedData.insurers)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(child: Text(ins.$1, style: PracticeDesignTokens.inter(weight: FontWeight.w600))),
                          Expanded(child: Text(ins.$2)),
                          Expanded(child: Text(ins.$3, style: TextStyle(color: context.appColors.success))),
                          Expanded(child: Text(ins.$4)),
                          Expanded(child: Text(ins.$5)),
                          Expanded(
                            child: PracticeStatusChip(
                              label: ins.$6,
                              tone: double.parse(ins.$6.replaceAll('%', '')) > 85
                                  ? PracticeStatusTone.success
                                  : PracticeStatusTone.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FinancePreview extends StatelessWidget {
  const FinancePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return PracticePreviewShell(
      selectedNavIndex: 9,
      title: 'Finance',
      subtitle: 'Executive overview · ${PreviewSeedData.facilityName}',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth > 700 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.6,
                  children: [
                    for (final k in PreviewSeedData.financeKpis)
                      PracticeKpiCard(
                        label: k.$1,
                        value: k.$2,
                        trend: k.$3,
                        accentColor: k.$4 == true
                            ? context.appColors.success
                            : k.$4 == false
                                ? context.appColors.emergency
                                : Theme.of(context).colorScheme.primary,
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PracticeBarChart(
                    title: 'Cash Flow — 6 Months',
                    labels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                    values: const [42, 48, 52, 49, 58, 62],
                    maxY: 70,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PracticeBarChart(
                    title: 'Collection Rate %',
                    labels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                    values: const [78, 82, 85, 83, 88, 91],
                    maxY: 100,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EarningsPreview extends StatelessWidget {
  const EarningsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return PracticePreviewShell(
      selectedNavIndex: 9,
      title: 'Practitioner Earnings',
      subtitle: PreviewSeedData.practitionerName,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                for (final k in PreviewSeedData.earningsKpis)
                  PracticeKpiCard(label: k.$1, value: k.$2, trend: k.$3),
              ],
            ),
            const SizedBox(height: 24),
            PracticeBarChart(
              title: 'Monthly Revenue Trend',
              labels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
              values: const [12, 14, 13, 16, 15, 18],
              maxY: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class FacilityPreview extends StatelessWidget {
  const FacilityPreview({super.key});

  @override
  Widget build(BuildContext context) {
    const services = [
      'General Consultation',
      'Antenatal',
      'Paediatrics',
      'Minor Procedures',
      'Vaccinations',
      'ECG',
      'Phlebotomy',
      'Wound Care',
    ];

    return PracticePreviewShell(
      selectedNavIndex: 7,
      title: 'Facility Management',
      subtitle: PreviewSeedData.facilityName,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: PracticeDesignTokens.previewCardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business_outlined,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Facility profile',
                          style: PracticeDesignTokens.sectionTitle(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 32,
                    runSpacing: 16,
                    children: const [
                      _InfoPair('NAME', PreviewSeedData.facilityName),
                      _InfoPair('LICENSE', PreviewSeedData.facilityLicense),
                      _InfoPair('ADDRESS', '12 Borrowdale Road, Harare'),
                      _InfoPair('PHONE', '+263 242 887 700'),
                      _InfoPair('TYPE', 'Private GP practice'),
                      _InfoPair('BEDS', '2 day-care'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: PracticeDesignTokens.previewCardDecoration(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Operating hours',
                            style: PracticeDesignTokens.sectionTitle(context)),
                        const SizedBox(height: 12),
                        Text('Mon–Fri  07:30 – 18:00',
                            style: PracticeDesignTokens.clinicalNote(context)),
                        Text('Saturday  08:00 – 13:00',
                            style: PracticeDesignTokens.clinicalNote(context)),
                        Text('Sunday  Emergencies only',
                            style: PracticeDesignTokens.clinicalNote(context)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: PracticeDesignTokens.previewCardDecoration(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Services offered',
                            style: PracticeDesignTokens.sectionTitle(context)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: services
                              .map((s) => PracticeStatusChip(
                                    label: s,
                                    tone: PracticeStatusTone.info,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PracticeBarChart(
              title: 'Facility analytics — utilisation %',
              labels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
              values: const [60, 70, 78, 75, 85, 82],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: PracticeDesignTokens.previewCardDecoration(context),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text('Staff & Permissions',
                            style: PracticeDesignTokens.sectionTitle(context)),
                        const Spacer(),
                        TextButton(onPressed: () {}, child: const Text('Invite user')),
                      ],
                    ),
                  ),
                  for (final s in PreviewSeedData.staff)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(s.$1)),
                          Expanded(child: Text(s.$2)),
                          Expanded(flex: 2, child: Text(s.$3, style: PracticeDesignTokens.metadata(context))),
                          Expanded(
                            child: PracticeStatusChip(
                              label: s.$4,
                              tone: s.$4 == 'Active'
                                  ? PracticeStatusTone.success
                                  : PracticeStatusTone.neutral,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPair extends StatelessWidget {
  const _InfoPair(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: PracticeDesignTokens.tableHeader(context)),
          Text(value, style: PracticeDesignTokens.inter(weight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class CalendarPreview extends StatelessWidget {
  const CalendarPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return PracticePreviewShell(
      selectedNavIndex: 5,
      title: 'Calendar',
      subtitle: 'June 2026',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Day')),
                    ButtonSegment(value: 1, label: Text('Week')),
                    ButtonSegment(value: 2, label: Text('Month')),
                    ButtonSegment(value: 3, label: Text('Agenda')),
                  ],
                  selected: const {2},
                  onSelectionChanged: (_) {},
                ),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
                Text('June 2026', style: PracticeDesignTokens.sectionTitle(context)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: PracticeDesignTokens.previewCardDecoration(context),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (final d in ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'])
                          Expanded(
                            child: Center(
                              child: Text(d, style: PracticeDesignTokens.tableHeader(context)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemCount: 35,
                        itemBuilder: (_, i) {
                          final day = i - 2;
                          final isCurrent = day == 12;
                          final hasAppt = [5, 7, 12, 15].contains(day);
                          if (day < 1 || day > 30) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              border: Border.all(
                                color: isCurrent
                                    ? Theme.of(context).colorScheme.primary
                                    : context.appColors.border,
                                width: isCurrent ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$day',
                                    style: PracticeDesignTokens.inter(
                                      weight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                                      color: isCurrent
                                          ? Theme.of(context).colorScheme.primary
                                          : null,
                                    )),
                                if (hasAppt) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: context.appColors.primarySoft,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('08:00',
                                        style: PracticeDesignTokens.inter(size: 9)),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportsPreview extends StatelessWidget {
  const ReportsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return PracticePreviewShell(
      selectedNavIndex: 10,
      title: 'Report Center',
      subtitle: 'Generate and export operational reports',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 2 : 1,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.5,
          ),
          itemCount: PreviewSeedData.reportCategories.length,
          itemBuilder: (_, i) {
            final cat = PreviewSeedData.reportCategories[i];
            return Container(
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
                      Text(cat.$1, style: PracticeDesignTokens.sectionTitle(context)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(cat.$2, style: PracticeDesignTokens.metadata(context)),
                  const Spacer(),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(onPressed: () {}, child: const Text('PDF')),
                      OutlinedButton(onPressed: () {}, child: const Text('Excel')),
                      OutlinedButton(onPressed: () {}, child: const Text('CSV')),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class PrescriptionsPreview extends StatelessWidget {
  const PrescriptionsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return PracticePreviewShell(
      selectedNavIndex: 6,
      title: 'Prescriptions',
      subtitle: 'Create and manage prescriptions',
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
          label: const Text('Preview PDF'),
        ),
        const SizedBox(width: 12),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: PracticeDesignTokens.previewCardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Patient', style: PracticeDesignTokens.sectionTitle(context)),
                  const SizedBox(height: 8),
                  DropdownMenu<String>(
                    initialSelection: 'Rumbidzai Chiweshe · SH-100214',
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: 'Rumbidzai Chiweshe · SH-100214',
                        label: 'Rumbidzai Chiweshe · SH-100214',
                      ),
                    ],
                    onSelected: (_) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: PracticeDesignTokens.previewCardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items', style: PracticeDesignTokens.sectionTitle(context)),
                  _RxItem('Amoxicillin 500mg', '1 cap · TDS · 5 days · Take with food'),
                  _RxItem('Paracetamol 500mg', '2 tabs · QID PRN · 5 days'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.appColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      children: [
                        Text('EDLIZ Compliance',
                            style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
                        const Spacer(),
                        const PracticeStatusChip(
                          label: '2 of 2 items EDLIZ',
                          tone: PracticeStatusTone.success,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RxItem extends StatelessWidget {
  const _RxItem(this.name, this.detail);

  final String name;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.medication_outlined,
          color: Theme.of(context).colorScheme.primary),
      title: Text(name),
      subtitle: Text(detail),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          PracticeStatusChip(label: 'EDLIZ', tone: PracticeStatusTone.success),
          IconButton(icon: Icon(Icons.delete_outline), onPressed: null),
        ],
      ),
    );
  }
}

class MobilePreview extends StatelessWidget {
  const MobilePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 390,
        height: 844,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700, width: 8),
          borderRadius: BorderRadius.circular(32),
        ),
        clipBehavior: Clip.antiAlias,
        child: DashboardPreview(),
      ),
    );
  }
}
