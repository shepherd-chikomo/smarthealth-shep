import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_bloc.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_event.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_state.dart';

/// Step 2 — review walk-in details and confirm queue join.
class QueueConfirmScreen extends StatelessWidget {
  const QueueConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueBloc, QueueState>(
      builder: (context, state) {
        final provider = state.provider;
        final patient = state.selectedPatient;
        final isJoining = state.flowStatus == QueueFlowStatus.joining;

        if (provider == null || patient == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Confirm Queue')),
            body: const Center(child: Text('Missing queue details')),
          );
        }

        return Scaffold(
          backgroundColor: HomeDashboardColors.background,
          appBar: AppBar(
            backgroundColor: HomeDashboardColors.surface,
            foregroundColor: HomeDashboardColors.textPrimary,
            title: const Text('Confirm Queue'),
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Material(
                      color: HomeDashboardColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E8EE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Walk-in summary',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: HomeDashboardColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SummaryRow(
                              label: 'Provider',
                              value: provider.name,
                            ),
                            _SummaryRow(
                              label: 'Facility',
                              value: provider.facilityName ?? provider.name,
                            ),
                            _SummaryRow(label: 'Patient', value: patient.name),
                            if (state.complaint.isNotEmpty)
                              _SummaryRow(
                                label: 'Reason',
                                value: state.complaint,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: HomeDashboardColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: HomeDashboardColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: HomeDashboardColors.primary,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'You will receive a queue number and live updates on your wait time.',
                              style: TextStyle(
                                fontSize: 13,
                                color: HomeDashboardColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isJoining
                        ? null
                        : () => context
                            .read<QueueBloc>()
                            .add(const QueueJoinConfirmed()),
                    style: FilledButton.styleFrom(
                      backgroundColor: HomeDashboardColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isJoining
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Join Queue',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: HomeDashboardColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: HomeDashboardColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
