import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/shared/utils/patient_formatters.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  static const _sections = [
    ('waiting', 'Waiting', Icons.schedule),
    ('in_progress', 'In Consultation', Icons.medical_services_outlined),
    ('investigations', 'Investigations', Icons.biotech_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueStream = ref.watch(queueRepositoryProvider).watchEnrichedQueue();

    return StreamBuilder<List<QueueEntryWithPatient>>(
      stream: queueStream,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const PracticeEmptyState(
            title: 'Queue is empty',
            message: 'Patients will appear here when they check in.',
            icon: Icons.people_outline,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Patient Queue', style: PracticeDesignTokens.pageTitle(context)),
              Text(
                'Live triage and consultation flow',
                style: PracticeDesignTokens.metadata(context),
              ),
              const SizedBox(height: 20),
              for (final (status, title, icon) in _sections) ...[
                _QueueSection(
                  title: title,
                  icon: icon,
                  status: status,
                  items: items.where((i) => i.entry.status == status).toList(),
                  onStart: (item) => context.push(
                    '/encounter/${item.entry.patientId}?queueEntryId=${item.entry.id}',
                  ),
                  onStatus: (item, newStatus) => ref
                      .read(queueRepositoryProvider)
                      .updateStatus(item.entry.id, newStatus),
                ),
                const SizedBox(height: 8),
              ],
              if (items.any((i) => !_knownStatus(i.entry.status)))
                _QueueSection(
                  title: 'Other',
                  icon: Icons.more_horiz,
                  status: 'other',
                  items: items
                      .where((i) => !_knownStatus(i.entry.status))
                      .toList(),
                  onStart: (item) => context.push(
                    '/encounter/${item.entry.patientId}?queueEntryId=${item.entry.id}',
                  ),
                  onStatus: (item, newStatus) => ref
                      .read(queueRepositoryProvider)
                      .updateStatus(item.entry.id, newStatus),
                ),
            ],
          ),
        );
      },
    );
  }

  static bool _knownStatus(String status) =>
      _sections.any((s) => s.$1 == status);
}

class _QueueSection extends StatelessWidget {
  const _QueueSection({
    required this.title,
    required this.icon,
    required this.status,
    required this.items,
    required this.onStart,
    required this.onStatus,
  });

  final String title;
  final IconData icon;
  final String status;
  final List<QueueEntryWithPatient> items;
  final void Function(QueueEntryWithPatient item) onStart;
  final void Function(QueueEntryWithPatient item, String status) onStatus;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(title, style: PracticeDesignTokens.sectionTitle(context)),
            const SizedBox(width: 8),
            PracticeStatusChip(
              label: '${items.length}',
              tone: PracticeStatusTone.neutral,
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final item in items)
          _QueueCard(
            item: item,
            onStart: () => onStart(item),
            onStatus: (s) => onStatus(item, s),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({
    required this.item,
    required this.onStart,
    required this.onStatus,
  });

  final QueueEntryWithPatient item;
  final VoidCallback onStart;
  final void Function(String status) onStatus;

  @override
  Widget build(BuildContext context) {
    final entry = item.entry;
    final patient = item.patient;
    final name = patient != null
        ? PatientFormatters.fullName(patient)
        : 'Patient ${entry.patientId.split('-').last}';
    final initials = patient != null
        ? PatientFormatters.initials(patient)
        : entry.patientId.substring(entry.patientId.length - 2).toUpperCase();
    final meta = patient != null
        ? '${PatientFormatters.ageSex(patient)} · ${PatientFormatters.insurerLabel(patient.insuranceInfo)}'
        : entry.triageStatus ?? 'routine';
    final shId = patient?.smarthealthPatientId ?? entry.patientId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Row(
        children: [
          PracticeAvatar(initials: initials),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
                Text('$shId · ${entry.triageStatus ?? 'routine'}',
                    style: PracticeDesignTokens.metadata(context)),
                Text(
                  'Arrived ${PatientFormatters.formatRelativeArrival(entry.arrivedAt)} · #${entry.position}',
                  style: PracticeDesignTokens.metadata(context),
                ),
                Text(meta, style: PracticeDesignTokens.metadata(context)),
              ],
            ),
          ),
          PracticeStatusChip(
            label: PracticeStatusChip.labelForQueueStatus(entry.status),
            tone: PracticeStatusChip.toneForClaimStatus(entry.status),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: onStatus,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'waiting', child: Text('Waiting')),
              PopupMenuItem(value: 'in_progress', child: Text('In Consultation')),
              PopupMenuItem(value: 'investigations', child: Text('Investigations')),
              PopupMenuItem(value: 'completed', child: Text('Complete')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Start consultation',
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}
