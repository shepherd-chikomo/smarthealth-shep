import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/features/appointments/bloc/appointments_bloc.dart';
import 'package:smarthealth_shep/features/appointments/bloc/appointments_event.dart';
import 'package:smarthealth_shep/features/appointments/bloc/appointments_state.dart';
import 'package:smarthealth_shep/features/appointments/data/appointments_repository.dart';
import 'package:smarthealth_shep/features/appointments/widgets/appointment_card.dart';
import 'package:smarthealth_shep/features/appointments/widgets/appointment_reminder_widgets.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppointmentsBloc(repository: AppointmentsRepository()),
      child: const _AppointmentsView(),
    );
  }
}

class _AppointmentsView extends StatelessWidget {
  const _AppointmentsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppShellScaffold(
      backgroundColor: HomeDashboardColors.background,
      appBar: AppBar(
        title: Text(l10n.navBookings),
        backgroundColor: HomeDashboardColors.background,
      ),
      body: BlocBuilder<AppointmentsBloc, AppointmentsState>(
        builder: (context, state) {
          if (state.status == AppointmentsStatus.loading &&
              state.appointments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AppointmentsStatus.error &&
              state.appointments.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.appointmentsErrorTitle),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: l10n.homeRetry,
                      onPressed: () => context
                          .read<AppointmentsBloc>()
                          .add(const AppointmentsLoadRequested()),
                    ),
                  ],
                ),
              ),
            );
          }

          final upcoming = state.upcoming;
          final past = state.past;
          final nextReminder = upcoming.isEmpty ? null : upcoming.first;

          return RefreshIndicator(
            color: HomeDashboardColors.primary,
            onRefresh: () async {
              context
                  .read<AppointmentsBloc>()
                  .add(const AppointmentsRefreshRequested());
              await context.read<AppointmentsBloc>().stream.firstWhere(
                    (s) => s.status != AppointmentsStatus.loading,
                  );
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (nextReminder != null) ...[
                  AppointmentReminderCard(
                    appointment: nextReminder,
                    onTap: () => context.push(
                      '/appointments/${nextReminder.id}',
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (upcoming.isNotEmpty) ...[
                  _SectionTitle(l10n.appointmentsUpcoming),
                  const SizedBox(height: 10),
                  for (final appointment in upcoming) ...[
                    AppointmentCard(
                      appointment: appointment,
                      onTap: () => context.push(
                        '/appointments/${appointment.id}',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      l10n.appointmentsEmptyUpcoming,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: HomeDashboardColors.textSecondary,
                      ),
                    ),
                  ),
                if (past.isNotEmpty) ...[
                  _SectionTitle(l10n.appointmentsPast),
                  const SizedBox(height: 10),
                  for (final appointment in past) ...[
                    AppointmentCard(
                      appointment: appointment,
                      onTap: () => context.push(
                        '/appointments/${appointment.id}',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: HomeDashboardColors.textPrimary,
      ),
    );
  }
}
