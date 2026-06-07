import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_bloc.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_state.dart';
import 'package:smarthealth_shep/features/booking/widgets/appointment_summary_card.dart';
import 'package:smarthealth_shep/features/booking/widgets/booking_success_checkmark.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// Step 3 — booking confirmed with reference number and next actions.
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  Future<void> _addToCalendar(BookingState state) async {
    final confirmation = state.confirmation;
    if (confirmation == null) return;

    final parts = confirmation.time.split(':');
    final hour = int.tryParse(parts.first) ?? 8;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final start = DateTime(
      confirmation.date.year,
      confirmation.date.month,
      confirmation.date.day,
      hour,
      minute,
    );
    final end = start.add(Duration(minutes: confirmation.durationMinutes));

    String fmt(DateTime dt) =>
        DateFormat("yyyyMMdd'T'HHmmss'Z'").format(dt.toUtc());

    final uri = Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE'
      '&text=${Uri.encodeComponent('Appointment with ${confirmation.providerName}')}'
      '&dates=${fmt(start)}/${fmt(end)}'
      '&details=${Uri.encodeComponent('Ref: ${confirmation.referenceNumber}')}'
      '&location=${Uri.encodeComponent(confirmation.facilityName)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        final confirmation = state.confirmation;
        final provider = state.provider;

        if (confirmation == null || provider == null) {
          return Scaffold(
            body: Center(
              child: PrimaryButton(
                label: 'Go back',
                onPressed: () => context.pop(),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: HomeDashboardColors.of(context).background,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Spacer(),
                  BookingSuccessCheckmark(),
                  SizedBox(height: 24),
                  Text(
                    'Booking Confirmed!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: HomeDashboardColors.of(context).textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppointmentSummaryCard.fromProvider(
                    provider: provider,
                    date: confirmation.date,
                    time: confirmation.time,
                    durationMinutes: confirmation.durationMinutes,
                    referenceNumber: confirmation.referenceNumber,
                    patientName: confirmation.patientName,
                    notes: confirmation.notes,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Symbols.sms,
                        size: 18,
                        color: HomeDashboardColors.of(context).textSecondary
                            .withValues(alpha: 0.8),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'SMS reminder will be sent 24 hours before',
                          style: TextStyle(
                            fontSize: 13,
                            color: HomeDashboardColors.of(context).textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'View My Appointments',
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      context.go('/bookings');
                    },
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _addToCalendar(state),
                      icon: Icon(Symbols.calendar_add_on),
                      label: Text('Add to Calendar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HomeDashboardColors.of(context).primary,
                        side: BorderSide(color: HomeDashboardColors.of(context).primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
