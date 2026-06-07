import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/emergency/bloc/emergency_hub_event.dart';
import 'package:smarthealth_shep/features/emergency/bloc/emergency_hub_state.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/features/emergency/data/emergency_fallback_data.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_hub_data.dart';
import 'package:smarthealth_shep/features/emergency/data/emergency_hub_repository.dart';

class EmergencyHubBloc extends Bloc<EmergencyHubEvent, EmergencyHubState> {
  EmergencyHubBloc({
    EmergencyHubRepository? repository,
    Connectivity? connectivity,
  })  : _repository = repository ?? EmergencyHubRepository(),
        _connectivity = connectivity ?? Connectivity(),
        super(const EmergencyHubState()) {
    on<LoadEmergencyHub>(_onLoad);
    on<RefreshEmergencyHub>(_onRefresh);

    add(const LoadEmergencyHub());
  }

  final EmergencyHubRepository _repository;
  final Connectivity _connectivity;

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> _onLoad(
    LoadEmergencyHub event,
    Emitter<EmergencyHubState> emit,
  ) async {
    emit(
      state.copyWith(
        status: EmergencyHubStatus.loading,
        clearError: true,
      ),
    );
    await _fetch(emit, forceRefresh: false);
  }

  Future<void> _onRefresh(
    RefreshEmergencyHub event,
    Emitter<EmergencyHubState> emit,
  ) async {
    await _fetch(emit, forceRefresh: true);
  }

  Future<void> _fetch(
    Emitter<EmergencyHubState> emit, {
    required bool forceRefresh,
  }) async {
    try {
      final online = await _isOnline();
      final data = await _repository.loadHub(forceRefresh: forceRefresh);
      emit(
        state.copyWith(
          status: EmergencyHubStatus.loaded,
          data: data,
          isOffline: !online,
        ),
      );
    } catch (error) {
      final fallback = EmergencyFallbackData.hub();
      emit(
        state.copyWith(
          status: EmergencyHubStatus.loaded,
          data: fallback,
          isOffline: true,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
