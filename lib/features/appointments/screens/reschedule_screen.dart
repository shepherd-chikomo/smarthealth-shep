import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/features/appointments/data/appointments_repository.dart';
import 'package:smarthealth_shep/features/appointments/models/appointment_model.dart';
import 'package:smarthealth_shep/features/booking/data/booking_repository.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';
import 'package:table_calendar/table_calendar.dart';

/// Lightweight reschedule picker reusing booking calendar patterns.
class RescheduleScreen extends StatefulWidget {
  const RescheduleScreen({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  final _repository = AppointmentsRepository();
  final _bookingRepository = BookingRepository();

  AppointmentModel? _appointment;
  bool _loading = true;
  bool _submitting = false;
  late List<DateTime> _availableDates;
  DateTime? _selectedDay;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _availableDates = _bookingRepository.availableDates(daysAhead: 30);
    _load();
  }

  Future<void> _load() async {
    final appointment = await _repository.getById(widget.appointmentId);
    if (!mounted) return;
    setState(() {
      _appointment = appointment;
      _selectedDay = appointment?.scheduledAt;
      _loading = false;
    });
  }

  Future<void> _confirm() async {
    if (_selectedDay == null || _selectedTime == null) return;
    setState(() => _submitting = true);
    try {
      final parts = _selectedTime!.split(':');
      final scheduledAt = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      await _repository.reschedule(
        widget.appointmentId,
        scheduledAt: scheduledAt,
      );
      if (!mounted) return;
      context.pop(true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.appointmentsReschedule)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: HomeDashboardColors.of(context).background,
      appBar: AppBar(
        title: Text(l10n.appointmentsReschedule),
        backgroundColor: HomeDashboardColors.of(context).background,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(Duration(days: 60)),
            focusedDay: _selectedDay ?? DateTime.now(),
            selectedDayPredicate: (day) =>
                _selectedDay != null && isSameDay(_selectedDay, day),
            enabledDayPredicate: (day) =>
                _bookingRepository.isDateAvailable(day, _availableDates),
            onDaySelected: (selected, _) =>
                setState(() => _selectedDay = selected),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: HomeDashboardColors.of(context).primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: HomeDashboardColors.of(context).secondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _selectedDay == null
                  ? null
                  : _bookingRepository.getTimeSlots(
                      _appointment!.providerId,
                      _selectedDay!,
                    ),
              builder: (context, snapshot) {
                final slots = snapshot.data ?? [];
                if (slots.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.appointmentsSelectDate,
                      style: TextStyle(
                        color: HomeDashboardColors.of(context).textSecondary,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final selected = _selectedTime == slot.time;
                    return Material(
                      color: selected
                          ? HomeDashboardColors.of(context).primary.withValues(alpha: 0.12)
                          : HomeDashboardColors.of(context).surface,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: slot.isAvailable
                            ? () => setState(() => _selectedTime = slot.time)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? HomeDashboardColors.of(context).primary
                                  : Color(0xFFE5E8EE),
                            ),
                          ),
                          child: Text(
                            slot.time,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: slot.isAvailable
                                  ? HomeDashboardColors.of(context).textPrimary
                                  : HomeDashboardColors.of(context).textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                label: l10n.appointmentsConfirmReschedule,
                isLoading: _submitting,
                onPressed:
                    _selectedDay != null && _selectedTime != null ? _confirm : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
