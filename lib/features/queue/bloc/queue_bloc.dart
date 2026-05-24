import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/booking/models/patient_option.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_event.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_state.dart';
import 'package:smarthealth_shep/features/queue/data/queue_repository.dart';

const _logName = 'QueueBloc';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  QueueBloc({
    String? providerId,
    String? sessionId,
    QueueRepository? repository,
  })  : _repository = repository ?? QueueRepository(),
        super(QueueState(providerId: providerId)) {
    on<LoadQueueFlow>(_onLoadFlow);
    on<QueuePatientSelected>(_onPatientSelected);
    on<QueueComplaintChanged>(_onComplaintChanged);
    on<QueueJoinConfirmed>(_onJoinConfirmed);
    on<LoadQueueStatus>(_onLoadStatus);
    on<RefreshQueueStatus>(_onRefresh);
    on<LeaveQueueRequested>(_onLeave);
    on<QueuePollTick>(_onPoll);

    if (providerId != null) {
      add(LoadQueueFlow(providerId));
    } else if (sessionId != null) {
      add(LoadQueueStatus(sessionId));
    }
  }

  final QueueRepository _repository;
  Timer? _pollTimer;

  Future<void> _onLoadFlow(
    LoadQueueFlow event,
    Emitter<QueueState> emit,
  ) async {
    emit(state.copyWith(
      flowStatus: QueueFlowStatus.loading,
      providerId: event.providerId,
      clearError: true,
    ));

    try {
      final provider = await _repository.getProvider(event.providerId);
      if (provider == null) {
        emit(state.copyWith(
          flowStatus: QueueFlowStatus.error,
          errorMessage: 'Provider not found',
        ));
        return;
      }

      final patients = await _repository.getPatients();
      emit(state.copyWith(
        flowStatus: QueueFlowStatus.ready,
        provider: provider,
        patients: patients,
        selectedPatientId: PatientOption.selfId,
      ));
    } catch (error, stackTrace) {
      developer.log('LoadQueueFlow failed', name: _logName, error: error, stackTrace: stackTrace);
      emit(state.copyWith(
        flowStatus: QueueFlowStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onPatientSelected(
    QueuePatientSelected event,
    Emitter<QueueState> emit,
  ) {
    emit(state.copyWith(selectedPatientId: event.patientId, clearError: true));
  }

  void _onComplaintChanged(
    QueueComplaintChanged event,
    Emitter<QueueState> emit,
  ) {
    emit(state.copyWith(complaint: event.complaint));
  }

  Future<void> _onJoinConfirmed(
    QueueJoinConfirmed event,
    Emitter<QueueState> emit,
  ) async {
    final provider = state.provider;
    final patient = state.selectedPatient;
    if (provider == null || patient == null) {
      emit(state.copyWith(
        flowStatus: QueueFlowStatus.error,
        errorMessage: 'Please select a patient',
      ));
      return;
    }

    emit(state.copyWith(flowStatus: QueueFlowStatus.joining, clearError: true));

    try {
      final session = await _repository.joinQueue(
        provider: provider,
        patient: patient,
        chiefComplaint: state.complaint,
      );
      emit(state.copyWith(
        flowStatus: QueueFlowStatus.joined,
        session: session,
      ));
    } catch (error, stackTrace) {
      developer.log('QueueJoinConfirmed failed', name: _logName, error: error, stackTrace: stackTrace);
      emit(state.copyWith(
        flowStatus: QueueFlowStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onLoadStatus(
    LoadQueueStatus event,
    Emitter<QueueState> emit,
  ) async {
    emit(state.copyWith(flowStatus: QueueFlowStatus.loading, clearError: true));

    try {
      final session = await _repository.getSession(event.sessionId);
      if (session == null) {
        emit(state.copyWith(
          flowStatus: QueueFlowStatus.error,
          errorMessage: 'Queue session not found',
        ));
        return;
      }

      emit(state.copyWith(
        flowStatus: QueueFlowStatus.ready,
        session: session,
      ));
      _startPolling();
    } catch (error, stackTrace) {
      developer.log('LoadQueueStatus failed', name: _logName, error: error, stackTrace: stackTrace);
      emit(state.copyWith(
        flowStatus: QueueFlowStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onRefresh(
    RefreshQueueStatus event,
    Emitter<QueueState> emit,
  ) async {
    final session = state.session;
    if (session == null) return;

    emit(state.copyWith(isRefreshing: true));
    try {
      final updated = await _repository.refreshSession(session.id);
      emit(state.copyWith(session: updated, isRefreshing: false));
    } catch (_) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  Future<void> _onLeave(
    LeaveQueueRequested event,
    Emitter<QueueState> emit,
  ) async {
    final session = state.session;
    if (session == null) return;

    emit(state.copyWith(flowStatus: QueueFlowStatus.leaving));
    await _repository.leaveQueue(session.id);
    _stopPolling();
    emit(state.copyWith(flowStatus: QueueFlowStatus.left, clearSession: true));
  }

  Future<void> _onPoll(
    QueuePollTick event,
    Emitter<QueueState> emit,
  ) async {
    if (state.session == null || state.isRefreshing) return;
    add(const RefreshQueueStatus());
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 12),
      (_) => add(const QueuePollTick()),
    );
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
