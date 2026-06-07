import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/appointments/data/appointments_repository.dart';
import 'package:smarthealth_shep/features/appointments/models/appointment_model.dart';
import 'package:smarthealth_shep/features/appointments/widgets/appointment_reminder_widgets.dart';
import 'package:smarthealth_shep/features/booking/widgets/appointment_summary_card.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/models/operational_status.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/status_chip.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_with_bottom_nav.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({
    super.key,
    required this.appointmentId,
    this.staffMode = false,
  });

  final String appointmentId;
  final bool staffMode;

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final _repository = AppointmentsRepository();
  AppointmentModel? _appointment;
  bool _loading = true;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final appointment = await _repository.getById(widget.appointmentId);
    if (!mounted) return;
    setState(() {
      _appointment = appointment;
      _loading = false;
    });
  }

  Future<void> _run(Future<AppointmentModel> Function() action) async {
    setState(() => _acting = true);
    try {
      final updated = await action();
      if (!mounted) return;
      setState(() => _appointment = updated);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return AppShellWithBottomNav(
        appBar: AppBar(title: Text(l10n.appointmentsDetailTitle)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final appointment = _appointment;
    if (appointment == null) {
      return AppShellWithBottomNav(
        appBar: AppBar(title: Text(l10n.appointmentsDetailTitle)),
        body: Center(child: Text(l10n.appointmentsNotFound)),
      );
    }

    return AppShellWithBottomNav(
      backgroundColor: HomeDashboardColors.of(context).background,
      appBar: AppBar(
        title: Text(l10n.appointmentsDetailTitle),
        backgroundColor: HomeDashboardColors.of(context).background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              StatusChip.appointment(appointment.status),
              const Spacer(),
              AppointmentCountdown(target: appointment.scheduledAt),
            ],
          ),
          const SizedBox(height: 16),
          AppointmentSummaryCard(
            providerName: appointment.providerName,
            facilityName: appointment.facilityName,
            specialty: appointment.specialty,
            date: appointment.scheduledAt,
            time: _formatTime(appointment.scheduledAt),
            durationMinutes: appointment.durationMinutes,
            referenceNumber: appointment.referenceNumber,
            patientName: appointment.patientName,
            notes: appointment.notes,
          ),
          if (appointment.hasQueueInfo) ...[
            const SizedBox(height: 12),
            _QueuePanel(appointment: appointment),
          ],
          const SizedBox(height: 20),
          if (!widget.staffMode) ...[
            _SectionLabel(l10n.appointmentsPatientActions),
            const SizedBox(height: 8),
            ..._patientActions(context, appointment, l10n),
          ],
          if (widget.staffMode) ...[
            _SectionLabel(l10n.appointmentsFacilityActions),
            const SizedBox(height: 8),
            ..._facilityActions(context, appointment, l10n),
          ],
        ],
      ),
    );
  }

  List<Widget> _patientActions(
    BuildContext context,
    AppointmentModel appointment,
    AppLocalizations l10n,
  ) {
    final actions = <Widget>[];

    if (appointment.canCheckIn) {
      actions.add(
        PrimaryButton(
          label: l10n.appointmentsCheckIn,
          isLoading: _acting,
          onPressed: () async {
            final result = await context.push<AppointmentModel>(
              '/appointments/${appointment.id}/check-in',
            );
            if (result != null && mounted) {
              setState(() => _appointment = result);
            }
          },
        ),
      );
      actions.add(const SizedBox(height: 8));
    }

    if (appointment.canJoinQueue &&
        appointment.status != AppointmentOperationalStatus.inQueue) {
      actions.add(
        _ActionTile(
          icon: Symbols.groups,
          label: l10n.appointmentsJoinQueue,
          onTap: _acting
              ? null
              : () => _run(() => _repository.joinQueue(appointment.id)),
        ),
      );
    }

    if (appointment.status == AppointmentOperationalStatus.inQueue &&
        appointment.queueSessionId != null) {
      actions.add(
        _ActionTile(
          icon: Symbols.hourglass_top,
          label: l10n.appointmentsViewQueue,
          onTap: () => context.push('/queue/${appointment.queueSessionId}'),
        ),
      );
    }

    if (appointment.canReschedule) {
      actions.add(
        _ActionTile(
          icon: Symbols.event_repeat,
          label: l10n.appointmentsReschedule,
          onTap: () async {
            final rescheduled = await context.push<bool>(
              '/appointments/${appointment.id}/reschedule',
            );
            if (rescheduled == true && mounted) await _load();
          },
        ),
      );
    }

    if (appointment.canCancel) {
      actions.add(
        _ActionTile(
          icon: Symbols.cancel,
          label: l10n.appointmentsCancel,
          destructive: true,
          onTap: _acting
              ? null
              : () => _confirmCancel(context, appointment.id, l10n),
        ),
      );
    }

    if (appointment.canContactFacility && appointment.facilityPhone != null) {
      actions.add(
        _ActionTile(
          icon: Symbols.call,
          label: l10n.appointmentsContactFacility,
          onTap: () => _callFacility(appointment.facilityPhone!),
        ),
      );
    }

    if (actions.isEmpty) {
      actions.add(
        Text(
          l10n.appointmentsNoActions,
          style: TextStyle(color: HomeDashboardColors.of(context).textSecondary),
        ),
      );
    }

    return actions;
  }

  List<Widget> _facilityActions(
    BuildContext context,
    AppointmentModel appointment,
    AppLocalizations l10n,
  ) {
    return [
      if (appointment.status == AppointmentOperationalStatus.pending)
        _ActionTile(
          icon: Symbols.check_circle,
          label: l10n.appointmentsConfirmBooking,
          onTap: _acting
              ? null
              : () => _run(() => _repository.confirmBooking(appointment.id)),
        ),
      if (appointment.status == AppointmentOperationalStatus.confirmed ||
          appointment.status == AppointmentOperationalStatus.rescheduled)
        _ActionTile(
          icon: Symbols.how_to_reg,
          label: l10n.appointmentsMarkArrived,
          onTap: _acting
              ? null
              : () => _run(() => _repository.markArrived(appointment.id)),
        ),
      if (appointment.status == AppointmentOperationalStatus.checkedIn)
        _ActionTile(
          icon: Symbols.groups,
          label: l10n.appointmentsMoveToQueue,
          onTap: _acting
              ? null
              : () => _run(() => _repository.moveToQueue(appointment.id)),
        ),
      if (appointment.status == AppointmentOperationalStatus.inQueue ||
          appointment.status == AppointmentOperationalStatus.checkedIn)
        _ActionTile(
          icon: Symbols.task_alt,
          label: l10n.appointmentsCompleteConsultation,
          onTap: _acting
              ? null
              : () =>
                  _run(() => _repository.completeConsultation(appointment.id)),
        ),
      _ActionTile(
        icon: Symbols.cancel,
        label: l10n.appointmentsCancelBooking,
        destructive: true,
        onTap: _acting
            ? null
            : () => _run(() => _repository.cancelBooking(appointment.id)),
      ),
    ];
  }

  Future<void> _confirmCancel(
    BuildContext context,
    String id,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.appointmentsCancel),
        content: Text(l10n.appointmentsCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.appointmentsKeep),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.appointmentsCancel),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(() => _repository.cancel(id));
    }
  }

  Future<void> _callFacility(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _SectionLabel extends StatelessWidget {
  _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: HomeDashboardColors.of(context).textPrimary,
      ),
    );
  }
}

class _QueuePanel extends StatelessWidget {
  _QueuePanel({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HomeDashboardColors.of(context).secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HomeDashboardColors.of(context).secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(Symbols.groups, color: HomeDashboardColors.of(context).secondary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.queuePosition != null
                      ? 'Queue position ${appointment.queuePosition}'
                      : 'In queue',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: HomeDashboardColors.of(context).textPrimary,
                  ),
                ),
                if (appointment.estimatedWaitMinutes != null)
                  Text(
                    'Estimated wait ~${appointment.estimatedWaitMinutes} min',
                    style: TextStyle(
                      fontSize: 13,
                      color: HomeDashboardColors.of(context).textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color =
        destructive ? HomeDashboardColors.of(context).emergency : HomeDashboardColors.of(context).primary;

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Material(
        color: HomeDashboardColors.of(context).surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE5E8EE)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: destructive
                          ? HomeDashboardColors.of(context).emergency
                          : HomeDashboardColors.of(context).textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
