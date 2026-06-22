import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/shared/utils/patient_formatters.dart';
import 'package:my_practice/shared/widgets/practice_more_app_bar.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';

    return Scaffold(
      appBar: practiceMoreAppBar(context, 'Clinical Tasks'),
      body: StreamBuilder<List<ClinicalTask>>(
        stream: (db.select(db.clinicalTasks)
              ..where((t) => t.facilityId.equals(facilityId))
              ..orderBy([(t) => OrderingTerm.asc(t.dueAt)]))
            .watch(),
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? [];
          final open = tasks.where((t) => t.status == 'open').toList();
          final done = tasks.where((t) => t.status != 'open').toList();

          if (tasks.isEmpty) {
            return const PracticeEmptyState(
              title: 'No tasks',
              message: 'Follow-ups, callbacks, and admin tasks appear here.',
              icon: Icons.task_alt_outlined,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Clinical Tasks', style: PracticeDesignTokens.pageTitle(context)),
              Text(
                '${open.length} open · ${done.length} completed',
                style: PracticeDesignTokens.metadata(context),
              ),
              const SizedBox(height: 16),
              if (open.isNotEmpty) ...[
                PracticeSectionHeader(title: 'Open'),
                ...open.map((t) => _TaskCard(task: t, db: db)),
              ],
              if (done.isNotEmpty) ...[
                const SizedBox(height: 16),
                PracticeSectionHeader(title: 'Completed'),
                ...done.map((t) => _TaskCard(task: t, db: db, dimmed: true)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task, required this.db, this.dimmed = false});

  final ClinicalTask task;
  final AppDatabase db;
  final bool dimmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = task.dueAt;
    final overdue = due != null && due.isBefore(DateTime.now()) && task.status == 'open';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: task.status != 'open',
            onChanged: dimmed
                ? null
                : (_) async {
                    await (db.update(db.clinicalTasks)
                          ..where((t) => t.id.equals(task.id)))
                        .write(const ClinicalTasksCompanion(status: Value('done')));
                  },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: PracticeDesignTokens.inter(
                    weight: FontWeight.w600,
                    color: dimmed ? context.appColors.mutedForeground : null,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    PracticeStatusChip(
                      label: _typeLabel(task.taskType),
                      tone: PracticeStatusChip.toneForClaimStatus(task.taskType),
                    ),
                    if (due != null)
                      PracticeStatusChip(
                        label: overdue
                            ? 'Overdue'
                            : 'Due ${PatientFormatters.formatDate(due)}',
                        tone: overdue
                            ? PracticeStatusTone.danger
                            : PracticeStatusTone.neutral,
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (task.patientId != null)
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.push('/patients/${task.patientId}/chart'),
            ),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    return switch (type) {
      'follow_up' => 'Follow-up',
      'callback' => 'Callback',
      'result_review' => 'Result review',
      'admin' => 'Admin',
      _ => type.replaceAll('_', ' '),
    };
  }
}
