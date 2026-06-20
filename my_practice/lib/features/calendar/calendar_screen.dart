import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
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
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';

    return Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focused,
            selectedDayPredicate: (d) => isSameDay(_selected, d),
            onDaySelected: (selected, focused) {
              setState(() {
                _selected = selected;
                _focused = focused;
              });
            },
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

                if (appts.isEmpty) {
                  return const Center(child: Text('No appointments'));
                }

                return ListView.builder(
                  itemCount: appts.length,
                  itemBuilder: (_, i) {
                    final a = appts[i];
                    return ListTile(
                      leading: const Icon(Icons.event),
                      title: Text(a.referenceNumber ?? 'Appointment'),
                      subtitle: Text(
                        '${a.scheduledAt.hour}:${a.scheduledAt.minute.toString().padLeft(2, '0')} · ${a.status}',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
  }
}
