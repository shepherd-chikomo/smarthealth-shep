import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_bloc.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_event.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_state.dart';
import 'package:smarthealth_shep/features/booking/screens/booking_confirm_screen.dart';
import 'package:smarthealth_shep/features/booking/widgets/provider_mini_card.dart';
import 'package:smarthealth_shep/features/booking/widgets/time_slots_grid.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';
import 'package:table_calendar/table_calendar.dart';

/// Step 1 — pick a date and available time slot.
class BookingDateScreen extends StatelessWidget {
  BookingDateScreen({super.key});

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        title: Text(
          'Book Appointment',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state.status == BookingStatus.loading ||
              state.status == BookingStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BookingStatus.error && state.provider == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Something went wrong',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final provider = state.provider!;
          final focusedDay = state.focusedDay ?? DateTime.now();
          final firstDay = DateTime.now();
          final lastDay = firstDay.add(Duration(days: 60));

          return Column(
            children: [
              if (state.isOffline)
                Container(
                  width: double.infinity,
                  color: HomeDashboardColors.of(context).warning.withValues(alpha: 0.15),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'You are offline — showing cached availability',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: HomeDashboardColors.of(context).textSecondary,
                    ),
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    ProviderMiniCard(provider: provider),
                    SizedBox(height: 20),
                    Material(
                      color: HomeDashboardColors.of(context).surface,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: TableCalendar<void>(
                          firstDay: firstDay,
                          lastDay: lastDay,
                          focusedDay: focusedDay,
                          selectedDayPredicate: (day) =>
                              state.selectedDate != null &&
                              _isSameDay(day, state.selectedDate!),
                          enabledDayPredicate: (day) {
                            final normalized =
                                DateTime(day.year, day.month, day.day);
                            return state.availableDates.any(
                              (d) => _isSameDay(d, normalized),
                            );
                          },
                          onDaySelected: (selected, focused) {
                            context
                                .read<BookingBloc>()
                                .add(DateSelected(selected));
                          },
                          onPageChanged: (focused) {},
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: TextStyle(
                              color: colors.textPrimary,
                            ),
                            todayDecoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: TextStyle(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            disabledTextStyle: TextStyle(
                              color: colors.textSecondary.withValues(alpha: 0.4),
                            ),
                            weekendTextStyle: TextStyle(
                              color: colors.textSecondary,
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                            weekendStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Available times',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TimeSlotsGrid(
                      slots: state.slots,
                      selectedTime: state.selectedTime,
                      isLoading: state.status == BookingStatus.loadingSlots,
                      onTimeSelected: (time) => context
                          .read<BookingBloc>()
                          .add(TimeSelected(time)),
                    ),
                  ],
                ),
              ),
              SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: PrimaryButton(
                  label: 'Continue',
                  onPressed: state.canContinue
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: context.read<BookingBloc>(),
                                child: const BookingConfirmScreen(),
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
