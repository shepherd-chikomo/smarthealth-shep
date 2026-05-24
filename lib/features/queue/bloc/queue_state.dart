import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/features/booking/models/patient_option.dart';
import 'package:smarthealth_shep/features/queue/models/queue_session.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

enum QueueFlowStatus {
  initial,
  loading,
  ready,
  joining,
  joined,
  leaving,
  left,
  error,
}

class QueueState extends Equatable {
  const QueueState({
    this.flowStatus = QueueFlowStatus.initial,
    this.providerId,
    this.provider,
    this.patients = const [],
    this.selectedPatientId,
    this.complaint = '',
    this.session,
    this.isRefreshing = false,
    this.errorMessage,
  });

  final QueueFlowStatus flowStatus;
  final String? providerId;
  final ProviderModel? provider;
  final List<PatientOption> patients;
  final String? selectedPatientId;
  final String complaint;
  final QueueSession? session;
  final bool isRefreshing;
  final String? errorMessage;

  bool get canJoin =>
      provider != null &&
      selectedPatientId != null &&
      flowStatus != QueueFlowStatus.joining;

  PatientOption? get selectedPatient {
    for (final patient in patients) {
      if (patient.id == selectedPatientId) return patient;
    }
    return null;
  }

  QueueState copyWith({
    QueueFlowStatus? flowStatus,
    String? providerId,
    ProviderModel? provider,
    List<PatientOption>? patients,
    String? selectedPatientId,
    String? complaint,
    QueueSession? session,
    bool? isRefreshing,
    String? errorMessage,
    bool clearSession = false,
    bool clearError = false,
  }) {
    return QueueState(
      flowStatus: flowStatus ?? this.flowStatus,
      providerId: providerId ?? this.providerId,
      provider: provider ?? this.provider,
      patients: patients ?? this.patients,
      selectedPatientId: selectedPatientId ?? this.selectedPatientId,
      complaint: complaint ?? this.complaint,
      session: clearSession ? null : (session ?? this.session),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        flowStatus,
        providerId,
        provider,
        patients,
        selectedPatientId,
        complaint,
        session,
        isRefreshing,
        errorMessage,
      ];
}
