import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/shared/utils/patient_formatters.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class PatientChartScreen extends ConsumerWidget {
  const PatientChartScreen({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartFuture = ref.watch(_chartProvider(patientId));

    return chartFuture.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Patient Record')),
        body: Center(child: Text('$e')),
      ),
      data: (chart) => _PatientChartBody(chart: chart, patientId: patientId),
    );
  }
}

class _PatientChartBody extends ConsumerWidget {
  const _PatientChartBody({required this.chart, required this.patientId});

  final Map<String, dynamic> chart;
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = chart['patient'];
    final allergies = chart['allergies'] as List? ?? [];
    final conditions = chart['conditions'] as List? ?? [];
    final timeline = chart['timeline'] as List? ?? [];
    final name = _patientName(patient);
    final initials = _initials(patient);
    final shId = _patientField(patient, 'smarthealthPatientId') ?? patientId;
    final insurer = PatientFormatters.insurerLabel(
      _patientField(patient, 'insuranceInfo'),
    );
    final ageSex = patient is Patient
        ? PatientFormatters.ageSex(patient)
        : '?';

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(name),
          actions: [
            IconButton(
              icon: const Icon(Icons.medical_services_outlined),
              tooltip: 'Start encounter',
              onPressed: () => context.push('/encounter/$patientId'),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Medical History'),
              Tab(text: 'Encounters'),
              Tab(text: 'Prescriptions'),
              Tab(text: 'Timeline'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(
              name: name,
              initials: initials,
              subtitle: '$shId · $ageSex · $insurer',
              conditions: conditions,
              allergies: allergies,
              timeline: timeline,
              onStartEncounter: () => context.push('/encounter/$patientId'),
            ),
            _MedicalHistoryTab(conditions: conditions, allergies: allergies),
            _EncountersTab(timeline: timeline, patientId: patientId),
            _PrescriptionsTab(patientId: patientId),
            _TimelineTab(timeline: timeline),
          ],
        ),
      ),
    );
  }

  String _patientName(dynamic patient) {
    if (patient is Patient) return PatientFormatters.fullName(patient);
    if (patient is Map) {
      return '${patient['firstName'] ?? ''} ${patient['lastName'] ?? ''}'.trim();
    }
    return 'Patient';
  }

  String _initials(dynamic patient) {
    if (patient is Patient) return PatientFormatters.initials(patient);
    if (patient is Map) {
      return PatientFormatters.initialsFromName(
        patient['firstName'] as String? ?? '',
        patient['lastName'] as String? ?? '',
      );
    }
    return '?';
  }

  String? _patientField(dynamic patient, String key) {
    if (patient is Map) return patient[key]?.toString();
    if (patient is Patient) {
      return switch (key) {
        'smarthealthPatientId' => patient.smarthealthPatientId,
        'insuranceInfo' => patient.insuranceInfo,
        _ => null,
      };
    }
    return null;
  }
}

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({
    required this.name,
    required this.initials,
    required this.subtitle,
    required this.conditions,
    required this.allergies,
    required this.onStartEncounter,
  });

  final String name;
  final String initials;
  final String subtitle;
  final List<dynamic> conditions;
  final List<dynamic> allergies;
  final VoidCallback onStartEncounter;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 500;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PracticeAvatar(initials: initials, size: 56),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _HeaderText(
                        name: name,
                        subtitle: subtitle,
                        conditions: conditions,
                        allergies: allergies,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onStartEncounter,
                    icon: const Icon(Icons.medical_services_outlined, size: 18),
                    label: const Text('Start Encounter'),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                PracticeAvatar(initials: initials, size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: _HeaderText(
                    name: name,
                    subtitle: subtitle,
                    conditions: conditions,
                    allergies: allergies,
                  ),
                ),
                FilledButton.icon(
                  onPressed: onStartEncounter,
                  icon: const Icon(Icons.medical_services_outlined, size: 18),
                  label: const Text('Start Encounter'),
                ),
              ],
            ),
    );
  }

  String _conditionLabel(dynamic c) {
    if (c is Map) return c['conditionName'] as String? ?? 'Condition';
    return c.conditionName as String;
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({
    required this.name,
    required this.subtitle,
    required this.conditions,
    required this.allergies,
  });

  final String name;
  final String subtitle;
  final List<dynamic> conditions;
  final List<dynamic> allergies;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: PracticeDesignTokens.sectionTitle(context)),
        Text(subtitle, style: PracticeDesignTokens.metadata(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            if (conditions.isNotEmpty)
              PracticeStatusChip(
                label: conditions.first is Map
                    ? conditions.first['conditionName'] as String? ?? 'Condition'
                    : conditions.first.conditionName as String,
                tone: PracticeStatusTone.info,
              ),
            PracticeStatusChip(
              label: allergies.isEmpty
                  ? 'No known allergies'
                  : '${allergies.length} allergy(ies)',
              tone: allergies.isEmpty
                  ? PracticeStatusTone.success
                  : PracticeStatusTone.warning,
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.name,
    required this.initials,
    required this.subtitle,
    required this.allergies,
    required this.conditions,
    required this.timeline,
    required this.onStartEncounter,
  });

  final String name;
  final String initials;
  final String subtitle;
  final List<dynamic> allergies;
  final List<dynamic> conditions;
  final List<dynamic> timeline;
  final VoidCallback onStartEncounter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _PatientHeader(
          name: name,
          initials: initials,
          subtitle: subtitle,
          conditions: conditions,
          allergies: allergies,
          onStartEncounter: onStartEncounter,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SummaryCard(
            'Allergies',
            allergies.isEmpty
                ? ['None recorded']
                : allergies.map(_allergenLabel).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SummaryCard(
            'Chronic Conditions',
            conditions.isEmpty
                ? ['None recorded']
                : conditions.map(_conditionLabel).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SummaryCard(
            'Recent Visits',
            timeline.isEmpty
                ? ['No encounters yet']
                : timeline.take(3).map(_timelineLabel).toList(),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _SummaryCard('Outstanding Balance', ['\$0.00']),
        ),
      ],
    );
  }
}

class _MedicalHistoryTab extends StatelessWidget {
  const _MedicalHistoryTab({
    required this.conditions,
    required this.allergies,
  });

  final List<dynamic> conditions;
  final List<dynamic> allergies;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryCard(
          'Chronic Conditions',
          conditions.isEmpty
              ? ['None recorded']
              : conditions.map(_conditionLabel).toList(),
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          'Allergies',
          allergies.isEmpty
              ? ['None recorded']
              : allergies.map(_allergenLabel).toList(),
        ),
      ],
    );
  }
}

class _EncountersTab extends StatelessWidget {
  const _EncountersTab({required this.timeline, required this.patientId});

  final List<dynamic> timeline;
  final String patientId;

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty) {
      return const PracticeEmptyState(
        title: 'No encounters',
        message: 'Start a consultation to create the first encounter.',
        icon: Icons.medical_services_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: timeline.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final t = timeline[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: PracticeDesignTokens.previewCardDecoration(context),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_timelineLabel(t),
                        style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
                    Text(_timelineDetail(t),
                        style: PracticeDesignTokens.metadata(context)),
                  ],
                ),
              ),
              PracticeStatusChip(
                label: _timelineStatus(t),
                tone: PracticeStatusChip.toneForClaimStatus(_timelineStatus(t)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PrescriptionsTab extends ConsumerWidget {
  const _PrescriptionsTab({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return StreamBuilder<List<Prescription>>(
      stream: (db.select(db.prescriptions)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch(),
      builder: (context, snapshot) {
        final rx = snapshot.data ?? [];
        if (rx.isEmpty) {
          return const PracticeEmptyState(
            title: 'No prescriptions',
            message: 'Prescriptions from encounters will appear here.',
            icon: Icons.medication_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: rx.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final p = rx[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: PracticeDesignTokens.previewCardDecoration(context),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.medication_outlined,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(p.medication),
                subtitle: Text(
                  [p.dosage, p.frequency, p.duration, p.instructions]
                      .whereType<String>()
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.timeline});

  final List<dynamic> timeline;

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty) {
      return const PracticeEmptyState(
        title: 'No timeline events',
        message: 'Clinical activity will build the patient timeline.',
        icon: Icons.timeline,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: timeline.length,
      itemBuilder: (_, i) {
        final t = timeline[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (i < timeline.length - 1)
                  Container(width: 2, height: 48, color: context.appColors.border),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_timelineLabel(t),
                        style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
                    Text(_timelineDetail(t),
                        style: PracticeDesignTokens.metadata(context)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(this.title, this.items);

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: PracticeDesignTokens.sectionTitle(context)),
          const SizedBox(height: 8),
          for (final i in items)
            Text('• $i', style: PracticeDesignTokens.clinicalNote(context)),
        ],
      ),
    );
  }
}

String _allergenLabel(dynamic a) {
  if (a is Map) return '${a['allergen']} (${a['severity'] ?? 'unknown'})';
  return '${a.allergen} (${a.severity ?? 'unknown'})';
}

String _conditionLabel(dynamic c) {
  if (c is Map) {
    return '${c['conditionName'] ?? c['condition_name']} · ${c['icd11Code'] ?? c['icd11_code'] ?? ''}';
  }
  return '${c.conditionName} · ${c.icd11Code ?? ''}';
}

String _timelineLabel(dynamic t) {
  if (t is Map) {
    return t['chiefComplaint'] as String? ??
        t['chief_complaint'] as String? ??
        t['assessment'] as String? ??
        'Encounter';
  }
  return t.chiefComplaint ?? t.assessment ?? 'Encounter';
}

String _timelineDetail(dynamic t) {
  if (t is Map) {
    final status = t['status'] as String? ?? 'unknown';
    final updated = t['updatedAt'] ?? t['updated_at'];
    return '$status${updated != null ? ' · $updated' : ''}';
  }
  return '${t.status} · ${t.updatedAt}';
}

String _timelineStatus(dynamic t) {
  if (t is Map) return t['status'] as String? ?? 'unknown';
  return t.status as String? ?? 'unknown';
}

final _chartProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, patientId) {
  return ref.watch(patientRepositoryProvider).getChart(patientId);
});
