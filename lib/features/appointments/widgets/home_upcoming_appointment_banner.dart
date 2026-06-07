import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/features/appointments/providers/appointments_providers.dart';
import 'package:smarthealth_shep/features/appointments/widgets/appointment_reminder_widgets.dart';

/// Loads and displays the next upcoming appointment on the home dashboard.
class HomeUpcomingAppointmentBanner extends ConsumerWidget {
  const HomeUpcomingAppointmentBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(nextUpcomingAppointmentProvider);

    return upcomingAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LinearProgressIndicator(minHeight: 2),
      ),
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
