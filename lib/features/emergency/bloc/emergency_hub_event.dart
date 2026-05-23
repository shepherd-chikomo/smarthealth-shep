import 'package:equatable/equatable.dart';

sealed class EmergencyHubEvent extends Equatable {
  const EmergencyHubEvent();

  @override
  List<Object?> get props => [];
}

final class LoadEmergencyHub extends EmergencyHubEvent {
  const LoadEmergencyHub();
}

final class RefreshEmergencyHub extends EmergencyHubEvent {
  const RefreshEmergencyHub();
}
