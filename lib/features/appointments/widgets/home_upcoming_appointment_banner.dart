import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/features/appointments/data/appointments_repository.dart';
import 'package:smarthealth_shep/features/appointments/models/appointment_model.dart';
import 'package:smarthealth_shep/features/appointments/widgets/appointment_reminder_widgets.dart';

final nextUpcomingAppointmentProvider =
    FutureProvider<AppointmentModel?>((ref) async {
  final repository = AppointmentsRepository();
  await repository.syncFromRemote();
  return repository.getNextUpcoming();
});

/// Loads and displays the next upcoming appointment on the home dashboard.
class HomeUpcomingAppointmentBanner extends ConsumerWidget {
  const HomeUpcomingAppointmentBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(nextUpcomingAppointmentProvider);

    return upcomingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (appointment) {
        if (appointment == null) return const SizedBox.shrink();

        return AppointmentReminderCard(
          appointment: appointment,
          onTap: () => context.push('/appointments/${appointment.id}'),
        );
      },
    );
  }
}
