import 'package:equatable/equatable.dart';

sealed class QueueEvent extends Equatable {
  const QueueEvent();

  @override
  List<Object?> get props => [];
}

final class LoadQueueFlow extends QueueEvent {
  const LoadQueueFlow(this.providerId);

  final String providerId;

  @override
  List<Object?> get props => [providerId];
}

final class QueuePatientSelected extends QueueEvent {
  const QueuePatientSelected(this.patientId);

  final String patientId;

  @override
  List<Object?> get props => [patientId];
}

final class QueueComplaintChanged extends QueueEvent {
  const QueueComplaintChanged(this.complaint);

  final String complaint;

  @override
  List<Object?> get props => [complaint];
}

final class QueueJoinConfirmed extends QueueEvent {
  const QueueJoinConfirmed();
}

final class LoadQueueStatus extends QueueEvent {
  const LoadQueueStatus(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

final class RefreshQueueStatus extends QueueEvent {
  const RefreshQueueStatus();
}

final class LeaveQueueRequested extends QueueEvent {
  const LeaveQueueRequested();
}

final class QueuePollTick extends QueueEvent {
  const QueuePollTick();
}
