import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/appointments/data/appointments_repository.dart';
import 'package:smarthealth_shep/features/appointments/models/appointment_model.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';

/// Lightweight arrival confirmation and queue assignment.
class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _repository = AppointmentsRepository();
  AppointmentModel? _appointment;
  bool _loading = true;
  bool _submitting = false;
  bool _assignQueue = true;

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

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    try {
      var updated =
          await _repository.checkIn(widget.appointmentId);
      if (_assignQueue) {
        updated = await _repository.joinQueue(widget.appointmentId);
      }
      if (!mounted) return;
      context.pop(updated);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.appointmentsCheckIn)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final appointment = _appointment;
    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.appointmentsCheckIn)),
        body: Center(child: Text(l10n.appointmentsNotFound)),
      );
    }

    return Scaffold(
      backgroundColor: HomeDashboardColors.of(context).background,
      appBar: AppBar(
        title: Text(l10n.appointmentsCheckIn),
        backgroundColor: HomeDashboardColors.of(context).background,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HomeDashboardColors.of(context).surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFE5E8EE)),
              ),
              child: Column(
                children: [
                  Icon(
                    Symbols.location_on,
                    size: 40,
                    color: HomeDashboardColors.of(context).primary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    l10n.appointmentsCheckInPrompt,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: HomeDashboardColors.of(context).textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    appointment.facilityName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: HomeDashboardColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.appointmentsAssignQueue),
              subtitle: Text(l10n.appointmentsAssignQueueHint),
              value: _assignQueue,
              activeTrackColor: HomeDashboardColors.of(context).primary,
              onChanged: _submitting
                  ? null
                  : (value) => setState(() => _assignQueue = value),
            ),
            const Spacer(),
            PrimaryButton(
              label: l10n.appointmentsConfirmArrival,
              isLoading: _submitting,
              onPressed: _confirm,
            ),
          ],
        ),
      ),
    );
  }
}
