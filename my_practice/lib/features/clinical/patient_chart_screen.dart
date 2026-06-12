import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/feature_flags/feature_flags_notifier.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class PatientChartScreen extends ConsumerWidget {
  const PatientChartScreen({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartFuture = ref.watch(_chartProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Record'),
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services),
            onPressed: () => context.push('/encounter/$patientId'),
          ),
        ],
      ),
      body: chartFuture.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (chart) {
          final patient = chart['patient'];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (patient != null)
                AppTheme.themedCard(
                  context: context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _patientName(patient),
                        style: AppTextStyles.lg(fontWeight: AppTextStyles.semibold),
                      ),
                      if (_patientField(patient, 'smarthealthPatientId') != null)
                        Text('ID: ${_patientField(patient, 'smarthealthPatientId')}'),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              _Section(
                title: 'Allergies',
                items: (chart['allergies'] as List?)?.map((a) => _allergenLabel(a)).toList() ?? [],
              ),
              _Section(
                title: 'Chronic Conditions',
                items: (chart['conditions'] as List?)?.map((c) => _conditionLabel(c)).toList() ?? [],
              ),
              _Section(
                title: 'Clinical Timeline',
                items: (chart['timeline'] as List?)
                        ?.map((t) => _timelineLabel(t))
                        .toList() ??
                    [],
              ),
            ],
          );
        },
      ),
    );
  }

  String _patientName(dynamic patient) {
    if (patient is Map) {
      return '${patient['firstName'] ?? ''} ${patient['lastName'] ?? ''}'.trim();
    }
    return '${patient.firstName} ${patient.lastName}';
  }

  String? _patientField(dynamic patient, String key) {
    if (patient is Map) return patient[key]?.toString();
    return null;
  }

  String _allergenLabel(dynamic a) {
    if (a is Map) return '${a['allergen']} (${a['severity'] ?? 'unknown'})';
    return a.allergen;
  }

  String _conditionLabel(dynamic c) {
    if (c is Map) return '${c['conditionName']} · ${c['icd11Code'] ?? ''}';
    return '${c.conditionName} · ${c.icd11Code ?? ''}';
  }

  String _timelineLabel(dynamic t) {
    if (t is Map) {
      return '${t['status']} · ${t['chiefComplaint'] ?? t['assessment'] ?? 'Encounter'}';
    }
    return '${t.status} · ${t.chiefComplaint ?? t.assessment ?? 'Encounter'}';
  }
}

final _chartProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, patientId) {
  return ref.watch(patientRepositoryProvider).getChart(patientId);
});

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppTheme.themedCard(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.lg(fontWeight: AppTextStyles.semibold)),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Text('None recorded', style: AppTextStyles.sm(color: context.appColors.mutedForeground))
            else
              ...items.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• $i'),
                  )),
          ],
        ),
      ),
    );
  }
}
