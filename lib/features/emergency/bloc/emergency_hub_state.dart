import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/core/location/models/location_models.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_hub_data.dart';

enum EmergencyHubStatus { initial, loading, loaded, error }

class EmergencyHubState extends Equatable {
  const EmergencyHubState({
    this.status = EmergencyHubStatus.initial,
    this.data,
    this.errorMessage,
    this.isOffline = true,
    this.searchOrigin,
  });

  final EmergencyHubStatus status;
  final EmergencyHubData? data;
  final String? errorMessage;
  final bool isOffline;
  final AppPosition? searchOrigin;

  EmergencyHubState copyWith({
    EmergencyHubStatus? status,
    EmergencyHubData? data,
    String? errorMessage,
    bool? isOffline,
    AppPosition? searchOrigin,
    bool clearError = false,
  }) {
    return EmergencyHubState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOffline: isOffline ?? this.isOffline,
      searchOrigin: searchOrigin ?? this.searchOrigin,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage, isOffline, searchOrigin];
}
