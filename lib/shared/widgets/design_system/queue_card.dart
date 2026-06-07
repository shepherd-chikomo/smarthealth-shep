import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/queue/models/queue_session.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/design_system_tokens.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/status_chip.dart';

/// Reusable queue progress card for home, status, and confirmation screens.
class QueueCard extends StatelessWidget {
  const QueueCard({
    super.key,
    required this.session,
    this.compact = false,
    this.onTap,
    this.onLeaveQueue,
    this.showLiveIndicator = false,
    this.isRefreshing = false,
  });

  factory QueueCard.fromSession(
    QueueSession session, {
    bool compact = false,
    VoidCallback? onTap,
    VoidCallback? onLeaveQueue,
    bool showLiveIndicator = false,
    bool isRefreshing = false,
  }) {
    return QueueCard(
      session: session,
      compact: compact,
      onTap: onTap,
      onLeaveQueue: onLeaveQueue,
      showLiveIndicator: showLiveIndicator,
      isRefreshing: isRefreshing,
    );
  }

  final QueueSession session;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onLeaveQueue;
  final bool showLiveIndicator;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final padding = compact ? 12.0 : 16.0;
    final ticketSize = compact ? 18.0 : 22.0;

    return Semantics(
      label:
          'Queue ${session.ticketNumber}, ${session.patientsAhead} patients ahead, '
          '${session.estimatedWaitMinutes} minute wait, ${session.status.label}',
      child: Material(
        color: HomeDashboardColors.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _borderColor(session.status),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HomeDashboardColors.of(context).surface,
                  DesignSystemColors.primary.withValues(alpha: 0.04),
                ],
              ),
              boxShadow: compact
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Queue #${session.ticketNumber}',
                            style: TextStyle(
                              fontSize: ticketSize,
                              fontWeight: FontWeight.w700,
                              color: HomeDashboardColors.of(context).primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (!compact) ...[
                            SizedBox(height: 4),
                            Text(
                              session.facilityName,
                              style: TextStyle(
                                fontSize: 13,
                                color: HomeDashboardColors.of(context).textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _StatusChip(
                        key: ValueKey(session.status),
                        status: session.status,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 8 : 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Column(
                    key: ValueKey(
                      '${session.patientsAhead}_${session.estimatedWaitMinutes}',
                    ),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (session.status != QueuePatientStatus.inConsultation &&
                          session.status != QueuePatientStatus.completed) ...[
                        Text(
                          session.patientsAhead == 0 &&
                                  session.status == QueuePatientStatus.youreNext
                              ? 'Please proceed to the reception desk'
                              : '${session.patientsAhead} patient${session.patientsAhead == 1 ? '' : 's'} ahead',
                          style: TextStyle(
                            fontSize: compact ? 13 : 15,
                            fontWeight: FontWeight.w600,
                            color: HomeDashboardColors.of(context).textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          session.estimatedWaitMinutes > 0
                              ? 'Estimated wait: ${session.estimatedWaitMinutes} mins'
                              : 'Ready now',
                          style: TextStyle(
                            fontSize: 13,
                            color: HomeDashboardColors.of(context).textSecondary,
                          ),
                        ),
                      ] else if (session.status ==
                          QueuePatientStatus.inConsultation) ...[
                        Text(
                          'You are being seen now',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: HomeDashboardColors.of(context).textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showLiveIndicator) ...[
                  SizedBox(height: 10),
                  _LiveRefreshIndicator(isRefreshing: isRefreshing),
                ],
                if (onLeaveQueue != null &&
                    session.status.isActive &&
                    session.status != QueuePatientStatus.inConsultation) ...[
                  SizedBox(height: compact ? 10 : 12),
                  SizedBox(
                    width: double.infinity,
                    height: compact ? 36 : 40,
                    child: OutlinedButton(
                      onPressed: onLeaveQueue,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HomeDashboardColors.of(context).emergency,
                        side: BorderSide(
                          color: HomeDashboardColors.of(context).emergency
                              .withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Leave Queue',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _borderColor(QueuePatientStatus status) {
    return switch (status) {
      QueuePatientStatus.youreNext => DesignSystemColors.success.withValues(
          alpha: 0.5,
        ),
      QueuePatientStatus.delayed ||
      QueuePatientStatus.paused =>
        DesignSystemColors.warning.withValues(alpha: 0.5),
      QueuePatientStatus.inConsultation =>
        DesignSystemColors.secondary.withValues(alpha: 0.5),
      _ => const Color(0xFFE5E8EE),
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({super.key, required this.status});

  final QueuePatientStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (status) {
      QueuePatientStatus.waiting => ('Waiting', StatusChipTone.queue),
      QueuePatientStatus.youreNext => ("You're Next", StatusChipTone.success),
      QueuePatientStatus.inConsultation =>
        ('In Consultation', StatusChipTone.verified),
      QueuePatientStatus.completed => ('Completed', StatusChipTone.neutral),
      QueuePatientStatus.delayed => ('Delayed', StatusChipTone.warning),
      QueuePatientStatus.paused => ('Paused', StatusChipTone.pending),
      QueuePatientStatus.cancelled => ('Cancelled', StatusChipTone.emergency),
    };

    return StatusChip(label: label, tone: tone, compact: true);
  }
}

class _LiveRefreshIndicator extends StatelessWidget {
  _LiveRefreshIndicator({required this.isRefreshing});

  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedRotation(
          turns: isRefreshing ? 1 : 0,
          duration: Duration(milliseconds: 800),
          child: Icon(
            Symbols.sync,
            size: 14,
            color: HomeDashboardColors.of(context).primary.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(width: 6),
        Text(
          isRefreshing ? 'Updating…' : 'Live',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: HomeDashboardColors.of(context).textSecondary.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: DesignSystemColors.success,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: DesignSystemColors.success.withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
