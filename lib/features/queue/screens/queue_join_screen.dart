import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/booking/models/patient_option.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_bloc.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_event.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_state.dart';
import 'package:smarthealth_shep/features/queue/screens/queue_confirm_screen.dart';
import 'package:smarthealth_shep/features/queue/screens/queue_success_screen.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/availability_indicator.dart';

/// Step 1 — select patient and optional complaint before joining queue.
class QueueJoinScreen extends StatefulWidget {
  const QueueJoinScreen({super.key});

  @override
  State<QueueJoinScreen> createState() => _QueueJoinScreenState();
}

class _QueueJoinScreenState extends State<QueueJoinScreen> {
  final _complaintController = TextEditingController();

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QueueBloc, QueueState>(
      listenWhen: (prev, curr) => prev.flowStatus != curr.flowStatus,
      listener: (context, state) {
        if (state.flowStatus == QueueFlowStatus.joined && state.session != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: context.read<QueueBloc>(),
                child: const QueueSuccessScreen(),
              ),
            ),
          );
        } else if (state.flowStatus == QueueFlowStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        if (state.flowStatus == QueueFlowStatus.loading ||
            state.flowStatus == QueueFlowStatus.initial) {
          return Scaffold(
            appBar: AppBar(title: const Text('Join Queue')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final provider = state.provider;
        if (provider == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Join Queue')),
            body: const Center(child: Text('Provider not found')),
          );
        }

        return Scaffold(
          backgroundColor: HomeDashboardColors.background,
          appBar: AppBar(
            backgroundColor: HomeDashboardColors.surface,
            foregroundColor: HomeDashboardColors.textPrimary,
            title: const Text('Join Queue'),
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
                            Text(
                              provider.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: HomeDashboardColors.textPrimary,
                              ),
                            ),
                            if (provider.specialty != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                provider.specialty!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: HomeDashboardColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (provider.facilityName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                provider.facilityName!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: HomeDashboardColors.textSecondary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            AvailabilityIndicator.fromProvider(provider),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Patient',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    for (final patient in state.patients) ...[
                      _PatientTile(
                        patient: patient,
                        selected: patient.id == state.selectedPatientId,
                        onSelected: () => context
                            .read<QueueBloc>()
                            .add(QueuePatientSelected(patient.id)),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Reason for visit (optional)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _complaintController,
                      maxLines: 3,
                      onChanged: (v) => context
                          .read<QueueBloc>()
                          .add(QueueComplaintChanged(v)),
                      decoration: InputDecoration(
                        hintText: 'Brief symptoms or reason for walk-in',
                        filled: true,
                        fillColor: HomeDashboardColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E8EE)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E8EE)),
                        ),
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
                    onPressed: state.canJoin
                        ? () {
                            context.read<QueueBloc>().add(
                                  QueueComplaintChanged(
                                    _complaintController.text,
                                  ),
                                );
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<QueueBloc>(),
                                  child: const QueueConfirmScreen(),
                                ),
                              ),
                            );
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: HomeDashboardColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
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

class _PatientTile extends StatelessWidget {
  const _PatientTile({
    required this.patient,
    required this.selected,
    required this.onSelected,
  });

  final PatientOption patient;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? HomeDashboardColors.primary.withValues(alpha: 0.08)
          : HomeDashboardColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSelected,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? HomeDashboardColors.primary
                  : const Color(0xFFE5E8EE),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? HomeDashboardColors.primary
                    : HomeDashboardColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      patient.relationship,
                      style: const TextStyle(
                        fontSize: 13,
                        color: HomeDashboardColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
