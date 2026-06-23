import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/auth/patient_profile.dart';
import 'package:smarthealth_shep/features/appointments/providers/appointments_providers.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_bloc.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_event.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_state.dart';
import 'package:smarthealth_shep/features/booking/models/patient_option.dart';
import 'package:smarthealth_shep/features/booking/screens/booking_success_screen.dart';
import 'package:smarthealth_shep/features/booking/widgets/appointment_summary_card.dart';
import 'package:smarthealth_shep/features/booking/widgets/booking_consent_section.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/home/providers/home_medical_summary_provider.dart';
import 'package:smarthealth_shep/features/profile/utils/primary_profile_resolver.dart';
import 'package:smarthealth_shep/features/profile/widgets/profile_member_switcher.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

/// Step 2 — review details, select patient, and confirm.
class BookingConfirmScreen extends ConsumerStatefulWidget {
  const BookingConfirmScreen({super.key});

  @override
  ConsumerState<BookingConfirmScreen> createState() =>
      _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends ConsumerState<BookingConfirmScreen> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == BookingStatus.confirmed) {
          invalidateUpcomingAppointment(ref);
          final bookingBloc = context.read<BookingBloc>();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: bookingBloc,
                child: BookingSuccessScreen(),
              ),
            ),
          );
        } else if (state.status == BookingStatus.offlineBlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking requires internet'),
              backgroundColor: HomeDashboardColors.of(context).warning,
              action: state.draftSaved
                  ? SnackBarAction(
                      label: 'Draft saved',
                      textColor: Colors.white,
                      onPressed: () {},
                    )
                  : null,
            ),
          );
        } else if (state.status == BookingStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final provider = state.provider;
        final date = state.selectedDate;
        final time = state.selectedTime;

        if (provider == null || date == null || time == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Confirm Booking')),
            body: Center(child: Text('Missing booking details')),
          );
        }

        final isConfirming = state.status == BookingStatus.confirming;

        return Scaffold(
          backgroundColor: HomeDashboardColors.of(context).background,
          appBar: AppBar(
            backgroundColor: HomeDashboardColors.of(context).surface,
            foregroundColor: HomeDashboardColors.of(context).textPrimary,
            title: const Text('Confirm Booking'),
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    AppointmentSummaryCard.fromProvider(
                      provider: provider,
                      date: date,
                      time: time,
                      durationMinutes: 30,
                      patientName: state.selectedPatient?.name,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Patient',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    for (final patient in state.patients) ...[
                      _PatientTile(
                        patient: patient,
                        selected: patient.id == state.selectedPatientId,
                        enabled: !isConfirming,
                        onSelected: () => context
                            .read<BookingBloc>()
                            .add(PatientSelected(patient.id)),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SizedBox(height: 16),
                    Text(
                      'Additional notes (optional)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      enabled: !isConfirming,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Symptoms, accessibility needs, etc.',
                        filled: true,
                        fillColor: HomeDashboardColors.of(context).surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E8EE)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E8EE)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    BookingConsentSection(
                      state: state,
                      enabled: !isConfirming,
                    ),
                  ],
                ),
              ),
              SafeArea(
                minimum: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isConfirming
                        ? null
                        : () {
                            final members =
                                ref.read(familyMembersProvider).value ??
                                    const <FamilyMemberModel>[];
                            final patientProfile =
                                ref.read(patientProfileProvider).value;
                            final selectedPatient = state.selectedPatient;
                            final member = _resolveMemberForPatient(
                              members: members,
                              patient: patientProfile,
                              selectedPatient: selectedPatient,
                            );
                            final snapshot = state.consent.buildProfileSnapshot(
                              member,
                            );
                            context.read<BookingBloc>().add(
                                  BookingConfirmed(
                                    notes: _notesController.text,
                                    consent: state.consent,
                                    profileSnapshot: snapshot,
                                  ),
                                );
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: HomeDashboardColors.of(context).secondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isConfirming
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Confirm Booking',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  FamilyMemberModel _resolveMemberForPatient({
    required List<FamilyMemberModel> members,
    required PatientProfile? patient,
    required PatientOption? selectedPatient,
  }) {
    if (selectedPatient == null || selectedPatient.id == PatientOption.selfId) {
      return resolveSelectedProfileMember(
        members: members,
        patient: patient,
        selectedMemberId: profilePrimaryLocalId,
      );
    }
    for (final member in members) {
      if (member.id == selectedPatient.id) return member;
    }
    return resolveSelectedProfileMember(
      members: members,
      patient: patient,
      selectedMemberId: profilePrimaryLocalId,
    );
  }
}

class _PatientTile extends StatelessWidget {
  const _PatientTile({
    required this.patient,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final PatientOption patient;
  final bool selected;
  final bool enabled;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? HomeDashboardColors.of(context).secondary.withValues(alpha: 0.08)
          : HomeDashboardColors.of(context).surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onSelected : null,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? HomeDashboardColors.of(context).secondary
                  : Color(0xFFE5E8EE),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? HomeDashboardColors.of(context).secondary
                    : HomeDashboardColors.of(context).textSecondary,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      patient.relationship,
                      style: TextStyle(
                        fontSize: 13,
                        color: HomeDashboardColors.of(context).textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
