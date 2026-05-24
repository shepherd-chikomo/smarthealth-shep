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
          backgroundColor: HomeDashboardColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  const BookingSuccessCheckmark(),
                  const SizedBox(height: 24),
                  const Text(
                    'You\'re in the Queue!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: HomeDashboardColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.facilityName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: HomeDashboardColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  QueueCard.fromSession(session),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Symbols.notifications_active,
                        size: 18,
                        color: HomeDashboardColors.textSecondary
                            .withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'We\'ll notify you when you\'re next',
                          style: TextStyle(
                            fontSize: 13,
                            color: HomeDashboardColors.textSecondary,
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        context.go('/home');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HomeDashboardColors.primary,
                        side: const BorderSide(color: HomeDashboardColors.primary),
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
