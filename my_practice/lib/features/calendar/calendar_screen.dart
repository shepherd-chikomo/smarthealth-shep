import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/sync/sync_notifier.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/domain/models/facility_hour.dart';
import 'package:my_practice/features/calendar/facility_hours_editor.dart';
import 'package:my_practice/features/facility/team_provider.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/shared/utils/patient_formatters.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    // Pull latest appointments from the server when the calendar opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncNotifierProvider.notifier).syncNow();
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text('Calendar', style: PracticeDesignTokens.pageTitle(context)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            '${_monthLabel(_focused)} · Appointments & availability',
            style: PracticeDesignTokens.metadata(context),
          ),
        ),
        TableCalendar(
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focused,
          selectedDayPredicate: (d) => isSameDay(_selected, d),
          onPageChanged: (focused) => setState(() => _focused = focused),
          onDaySelected: (selected, focused) {
            setState(() {
              _selected = selected;
              _focused = focused;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Appointment>>(
            stream: (db.select(db.appointments)
                  ..where((t) => t.facilityId.equals(facilityId))
                  ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
                .watch(),
            builder: (context, snapshot) {
              final day = _selected ?? DateTime.now();
              final appts = (snapshot.data ?? [])
                  .where(
                    (a) =>
                        a.scheduledAt.year == day.year &&
                        a.scheduledAt.month == day.month &&
                        a.scheduledAt.day == day.day,
                  )
                  .toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _AvailabilityCard(
                    hoursAsync: ref.watch(facilityHoursProvider),
                    onEdit: (hours) async {
                      await showFacilityHoursEditor(context, hours);
                      if (context.mounted) {
                        ref.invalidate(facilityHoursProvider);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Appointments', style: PracticeDesignTokens.sectionTitle(context)),
                  const SizedBox(height: 8),
                  if (appts.isEmpty)
                    const PracticeEmptyState(
                      title: 'No appointments',
                      message: 'No bookings on this day.',
                      icon: Icons.event_busy_outlined,
                    )
                  else
                    ...appts.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _AppointmentCard(
                          appointment: a,
                          onTap: () => context.push('/patients/${a.patientId}/chart'),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _monthLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.hoursAsync,
    required this.onEdit,
  });

  final AsyncValue<List<FacilityHour>> hoursAsync;
  final void Function(List<FacilityHour> hours) onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Working hours',
                  style: PracticeDesignTokens.sectionTitle(context)),
              const Spacer(),
              TextButton(
                onPressed: hoursAsync.maybeWhen(
                  data: (hours) => () => onEdit(hours),
                  orElse: () => null,
                ),
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          hoursAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            ),
            error: (e, _) => Text(
              'Could not load hours · using defaults',
              style: PracticeDesignTokens.metadata(context),
            ),
            data: (hours) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final h in _compactLines(hours))
                  Text(h, style: PracticeDesignTokens.clinicalNote(context)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: const [
              PracticeStatusChip(label: '30 min slots', tone: PracticeStatusTone.info),
              PracticeStatusChip(label: 'Syncs to MyHealth', tone: PracticeStatusTone.success),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _compactLines(List<FacilityHour> hours) {
    return hours.map((h) => h.displayLine).toList();
  }
}

class _AppointmentCard extends ConsumerWidget {
  const _AppointmentCard({required this.appointment, required this.onTap});

  final Appointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(patientRepositoryProvider).findById(appointment.patientId),
      builder: (context, snapshot) {
        final patient = snapshot.data;
        final name = patient != null
            ? PatientFormatters.fullName(patient)
            : 'Patient ${appointment.patientId.split('-').last}';

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: PracticeDesignTokens.previewCardDecoration(context),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    PatientFormatters.formatTime(appointment.scheduledAt),
                    style: PracticeDesignTokens.inter(weight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
                      Text(
                        appointment.appointmentType ?? appointment.referenceNumber ?? 'Consultation',
                        style: PracticeDesignTokens.metadata(context),
                      ),
                    ],
                  ),
                ),
                PracticeStatusChip(
                  label: appointment.status,
                  tone: PracticeStatusChip.toneForClaimStatus(appointment.status),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
