import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/features/appointments/data/appointments_repository.dart';
import 'package:smarthealth_shep/features/appointments/models/appointment_model.dart';
import 'package:smarthealth_shep/features/appointments/widgets/appointment_reminder_widgets.dart';

/// Loads and displays the next upcoming appointment on the home dashboard.
class HomeUpcomingAppointmentBanner extends StatelessWidget {
  const HomeUpcomingAppointmentBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppointmentModel?>(
      future: AppointmentsRepository().getNextUpcoming(),
      builder: (context, snapshot) {
        final appointment = snapshot.data;
        if (appointment == null) return const SizedBox.shrink();

        return UpcomingAppointmentBanner(
          appointment: appointment,
          onTap: () => context.push('/appointments/${appointment.id}'),
        );
      },
    );
  }
}
