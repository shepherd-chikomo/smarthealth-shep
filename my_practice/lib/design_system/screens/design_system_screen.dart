import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/design_system/widgets/practice_icon_widgets.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

/// Living style guide for MyPractice — reference for Phase 2 global rollout.
class DesignSystemScreen extends StatefulWidget {
  const DesignSystemScreen({super.key});

  @override
  State<DesignSystemScreen> createState() => _DesignSystemScreenState();
}

class _DesignSystemScreenState extends State<DesignSystemScreen> {
  bool _dark = true;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Builder(
        builder: (context) {
          final colors = context.appColors;
          final scheme = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: AppBar(
              title: const Text('MyPractice Design System'),
              actions: [
                TextButton(
                  onPressed: () => context.go('/design-preview'),
                  child: const Text('Design Preview'),
                ),
                IconButton(
                  icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => setState(() => _dark = !_dark),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _Section(
                  title: 'Brand',
                  child: Text(
                    'MyPractice extends the SmartHealth ecosystem. Primary blue, healthcare teal, '
                    'and professional grey scale align with MyHealth and Facility Portal.',
                    style: PracticeDesignTokens.clinicalNote(context),
                  ),
                ),
                _Section(
                  title: 'Color Palette',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _Swatch('Primary', scheme.primary),
                      _Swatch('Secondary / Teal', scheme.secondary),
                      _Swatch('Success', colors.success),
                      _Swatch('Warning', colors.warning),
                      _Swatch('Danger', colors.emergency),
                      _Swatch('Background', colors.background),
                      _Swatch('Card', colors.card),
                      _Swatch('Muted', colors.muted),
                      _Swatch('Border', colors.border),
                    ],
                  ),
                ),
                _Section(
                  title: 'Typography (Inter + Source Sans 3)',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Page Title', style: PracticeDesignTokens.pageTitle(context)),
                      Text('Section Title', style: PracticeDesignTokens.sectionTitle(context)),
                      Text('KPI Value', style: PracticeDesignTokens.kpiValue(context)),
                      Text('TABLE HEADER', style: PracticeDesignTokens.tableHeader(context)),
                      Text('Metadata · secondary text',
                          style: PracticeDesignTokens.metadata(context)),
                      Text(
                        'Clinical note body text for encounter documentation.',
                        style: PracticeDesignTokens.clinicalNote(context),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Buttons',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(onPressed: () {}, child: const Text('Primary')),
                      OutlinedButton(onPressed: () {}, child: const Text('Secondary')),
                      TextButton(onPressed: () {}, child: const Text('Ghost')),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.medical_services_outlined, size: 18),
                        label: const Text('Start Consultation'),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Cards & KPI',
                  child: LayoutBuilder(
                    builder: (context, c) {
                      return GridView.count(
                        crossAxisCount: c.maxWidth > 600 ? 3 : 1,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.6,
                        children: const [
                          PracticeKpiCard(
                            label: 'Today\'s Appointments',
                            value: '24',
                            trend: '+3 vs yest',
                            icon: Icons.calendar_month_outlined,
                          ),
                          PracticeKpiCard(
                            label: 'Outstanding Claims',
                            value: '\$3,840',
                            trend: '12 claims',
                            icon: Icons.request_quote_outlined,
                            accentColor: Color(0xFFE0A030),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                _Section(
                  title: 'Status Chips',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      PracticeStatusChip(label: 'Active', tone: PracticeStatusTone.success),
                      PracticeStatusChip(label: 'Waiting', tone: PracticeStatusTone.queue),
                      PracticeStatusChip(label: 'Under review', tone: PracticeStatusTone.warning),
                      PracticeStatusChip(label: 'Rejected', tone: PracticeStatusTone.danger),
                      PracticeStatusChip(label: 'Cimas', tone: PracticeStatusTone.info),
                    ],
                  ),
                ),
                _Section(
                  title: 'Forms',
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Patient search',
                          hintText: 'Name, SmartHealth ID, phone…',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Clinical note',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Charts',
                  child: PracticeBarChart(
                    title: 'Sample Utilisation',
                    labels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                    values: const [60, 70, 78, 75, 85, 82],
                  ),
                ),
                _Section(
                  title: 'Empty States',
                  child: PracticeEmptyState(
                    title: 'No appointments',
                    message: 'Your schedule is clear for today. Add a walk-in or book ahead.',
                    icon: Icons.event_busy_outlined,
                    actionLabel: 'Add Appointment',
                  ),
                ),
                _Section(
                  title: 'Notifications',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MaterialBanner(
                        content: const Text('3 claims require your attention'),
                        leading: const Icon(Icons.info_outline),
                        actions: [
                          TextButton(onPressed: () {}, child: const Text('Review')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: context.appColors.card,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          border: Border.all(color: context.appColors.border),
                        ),
                        child: Row(
                          children: [
                            const Expanded(child: Text('Encounter saved and synced')),
                            TextButton(onPressed: () {}, child: const Text('Undo')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Icons (Material outlined — Lucide mapping in rollout)',
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: const [
                      _IconLabel(Icons.dashboard_outlined, 'Dashboard'),
                      _IconLabel(Icons.calendar_month_outlined, 'Calendar'),
                      _IconLabel(Icons.groups_outlined, 'Queue'),
                      _IconLabel(Icons.medical_services_outlined, 'Encounter'),
                      _IconLabel(Icons.medication_outlined, 'Rx'),
                      _IconLabel(Icons.request_quote_outlined, 'Claims',
                          color: PracticeDesignTokens.kpiAmber),
                      _IconLabel(Icons.account_balance_wallet_outlined, 'Finance',
                          color: PracticeDesignTokens.kpiGreen),
                      _IconLabel(Icons.bar_chart_outlined, 'Reports'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: PracticeDesignTokens.pageTitle(context)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: context.appColors.border),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: PracticeDesignTokens.inter(size: 11)),
      ],
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel(this.icon, this.label, {this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 88,
      child: Column(
        children: [
          PracticeIconBadge(icon: icon, color: accent),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: PracticeDesignTokens.inter(size: 10)),
        ],
      ),
    );
  }
}
