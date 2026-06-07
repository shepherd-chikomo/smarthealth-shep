import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/booking/widgets/booking_success_checkmark.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_bloc.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_state.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/queue_card.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';

/// Step 3 — queue joined confirmation with ticket details.
class QueueSuccessScreen extends StatelessWidget {
  const QueueSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueBloc, QueueState>(
      builder: (context, state) {
        final session = state.session;

        if (session == null) {
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
                    'You\'re in the Queue!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: HomeDashboardColors.of(context).textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    session.facilityName,
                    style: TextStyle(
                      fontSize: 14,
                      color: HomeDashboardColors.of(context).textSecondary,
                    ),
                  ),
                  SizedBox(height: 24),
                  QueueCard.fromSession(session),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Symbols.notifications_active,
                        size: 18,
                        color: HomeDashboardColors.of(context).textSecondary
                            .withValues(alpha: 0.8),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'We\'ll notify you when you\'re next',
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
                    label: 'Track Queue Status',
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      context.push('/queue/${session.id}');
                    },
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        context.go('/home');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HomeDashboardColors.of(context).primary,
                        side: BorderSide(color: HomeDashboardColors.of(context).primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back to Home'),
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
