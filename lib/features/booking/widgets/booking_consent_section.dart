import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_bloc.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_event.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_state.dart';
import 'package:smarthealth_shep/features/booking/models/booking_consent_options.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';

class BookingConsentSection extends StatelessWidget {
  const BookingConsentSection({
    super.key,
    required this.state,
    required this.enabled,
  });

  final BookingState state;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);
    final consent = state.consent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share health profile',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Uncheck anything you do not want the provider to see before your visit.',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        for (final field in BookingProfileShareField.values)
          CheckboxListTile(
            value: consent.sharedFields.contains(field),
            onChanged: enabled
                ? (checked) => context.read<BookingBloc>().add(
                      ProfileShareToggled(field, checked ?? false),
                    )
                : null,
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(_shareFieldLabel(field)),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        const SizedBox(height: 16),
        Text(
          'Payment method',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BookingPaymentMethod.values.map((method) {
            final selected = consent.paymentMethod == method;
            return ChoiceChip(
              label: Text(method.label),
              selected: selected,
              onSelected: enabled
                  ? (_) => context.read<BookingBloc>().add(
                        PaymentMethodSelected(method),
                      )
                  : null,
              selectedColor: colors.secondary.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: selected ? colors.secondary : colors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: consent.receiveEncounterSummary,
          onChanged: enabled
              ? (value) => context.read<BookingBloc>().add(
                    EncounterSummaryConsentChanged(value),
                  )
              : null,
          title: const Text('Receive visit summary'),
          subtitle: Text(
            'Get notes and next steps from your practitioner after the visit.',
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: consent.enableOngoingCare,
          onChanged: enabled
              ? (value) => context.read<BookingBloc>().add(
                    OngoingCareConsentChanged(value),
                  )
              : null,
          title: const Text('Ongoing care record'),
          subtitle: Text(
            'Allow this facility to keep your shared allergies and conditions '
            'on file for future visits (separate from this booking snapshot).',
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
        ),
      ],
    );
  }

  String _shareFieldLabel(BookingProfileShareField field) {
    return switch (field) {
      BookingProfileShareField.allergies => 'Allergies',
      BookingProfileShareField.conditions => 'Medical conditions',
      BookingProfileShareField.medications => 'Current medications',
      BookingProfileShareField.bloodGroup => 'Blood group',
      BookingProfileShareField.emergencyContact => 'Emergency contact',
    };
  }
}
