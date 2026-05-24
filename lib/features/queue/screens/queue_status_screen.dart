import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_bloc.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_event.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_state.dart';
import 'package:smarthealth_shep/features/queue/models/queue_session.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/queue_card.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';

/// Live queue progress with polling refresh and leave action.
class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QueueBloc, QueueState>(
      listenWhen: (prev, curr) => prev.flowStatus != curr.flowStatus,
      listener: (context, state) {
        if (state.flowStatus == QueueFlowStatus.left) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have left the queue')),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        if (state.flowStatus == QueueFlowStatus.loading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Queue Status')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.flowStatus == QueueFlowStatus.error) {
          return Scaffold(
            appBar: AppBar(title: const Text('Queue Status')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Something went wrong'),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Go back',
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final session = state.session;
        if (session == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Queue Status')),
            body: const Center(child: Text('No active queue session')),
          );
        }

        return Scaffold(
          backgroundColor: HomeDashboardColors.background,
          appBar: AppBar(
            backgroundColor: HomeDashboardColors.surface,
            foregroundColor: HomeDashboardColors.textPrimary,
            title: const Text('Queue Status'),
            elevation: 0,
            actions: [
              IconButton(
                icon: state.isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: state.isRefreshing
                    ? null
                    : () => context
                        .read<QueueBloc>()
                        .add(const RefreshQueueStatus()),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: HomeDashboardColors.primary,
            onRefresh: () async {
              context.read<QueueBloc>().add(const RefreshQueueStatus());
              await context.read<QueueBloc>().stream.firstWhere(
                    (s) => !s.isRefreshing,
                  );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                QueueCard.fromSession(
                  session,
                  showLiveIndicator: session.status.isActive,
                  isRefreshing: state.isRefreshing,
                  onLeaveQueue: session.status.isActive &&
                          session.status != QueuePatientStatus.inConsultation
                      ? () => _confirmLeave(context)
                      : null,
                ),
                const SizedBox(height: 16),
                _ProviderInfo(session: session),
                if (_notificationHint(session.status) != null) ...[
                  const SizedBox(height: 16),
                  _StatusHint(message: _notificationHint(session.status)!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String? _notificationHint(QueuePatientStatus status) {
    return switch (status) {
      QueuePatientStatus.youreNext =>
        'You\'re next — please proceed to the reception desk.',
      QueuePatientStatus.delayed =>
        'The queue is running behind schedule. Your wait time may increase.',
      QueuePatientStatus.paused =>
        'The queue is temporarily paused. Please wait for updates.',
      QueuePatientStatus.inConsultation =>
        'You are now in consultation.',
      QueuePatientStatus.completed =>
        'Your visit is complete. Thank you.',
      _ => null,
    };
  }

  Future<void> _confirmLeave(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave queue?'),
        content: const Text(
          'You will lose your place in line. You can join again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<QueueBloc>().add(const LeaveQueueRequested());
    }
  }
}

class _ProviderInfo extends StatelessWidget {
  const _ProviderInfo({required this.session});

  final QueueSession session;

  @override
  Widget build(BuildContext context) {
    return Material(
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
              session.providerName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: HomeDashboardColors.textPrimary,
              ),
            ),
            if (session.providerSpecialty != null) ...[
              const SizedBox(height: 4),
              Text(
                session.providerSpecialty!,
                style: const TextStyle(
                  fontSize: 13,
                  color: HomeDashboardColors.primary,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              session.facilityName,
              style: const TextStyle(
                fontSize: 13,
                color: HomeDashboardColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusHint extends StatelessWidget {
  const _StatusHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HomeDashboardColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: HomeDashboardColors.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: HomeDashboardColors.secondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: HomeDashboardColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
