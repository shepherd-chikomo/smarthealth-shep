import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/family/bloc/family_event.dart';
import 'package:smarthealth_shep/features/family/bloc/family_state.dart';
import 'package:smarthealth_shep/features/family/data/family_repository.dart';

const _logName = 'FamilyBloc';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  FamilyBloc({FamilyRepository? repository})
      : _repository = repository ?? FamilyRepository(),
        super(const FamilyState()) {
    on<LoadMembers>(_onLoadMembers);
    on<AddMember>(_onAddMember);
    on<UpdateMember>(_onUpdateMember);
    on<DeleteMember>(_onDeleteMember);

    add(const LoadMembers());
  }

  final FamilyRepository _repository;

  Future<void> _onLoadMembers(
    LoadMembers event,
    Emitter<FamilyState> emit,
  ) async {
    emit(state.copyWith(status: FamilyStatus.loading, clearError: true));

    try {
      final isOffline = !(await _repository.isOnline());
      final members = await _repository.loadMembers(syncRemote: true);
      emit(
        state.copyWith(
          status: FamilyStatus.loaded,
          members: members,
          isOffline: isOffline,
        ),
      );
    } catch (error, stackTrace) {
      developer.log(
        'LoadMembers failed',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: FamilyStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onAddMember(
    AddMember event,
    Emitter<FamilyState> emit,
  ) async {
    emit(state.copyWith(status: FamilyStatus.saving, clearError: true));

    try {
      final saved = await _repository.addMember(event.member);
      final members = await _repository.loadMembers(syncRemote: true);
      final isOffline = !(await _repository.isOnline());

      emit(
        state.copyWith(
          status: FamilyStatus.loaded,
          members: members,
          isOffline: isOffline,
          pendingSync: !isOffline,
        ),
      );

      developer.log('Added family member ${saved.id}', name: _logName);
    } catch (error, stackTrace) {
      developer.log(
        'AddMember failed',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: FamilyStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateMember(
    UpdateMember event,
    Emitter<FamilyState> emit,
  ) async {
    emit(state.copyWith(status: FamilyStatus.saving, clearError: true));

    try {
      await _repository.updateMember(event.member);
      final members = await _repository.loadMembers(syncRemote: true);
      final isOffline = !(await _repository.isOnline());

      emit(
        state.copyWith(
          status: FamilyStatus.loaded,
          members: members,
          isOffline: isOffline,
          pendingSync: !isOffline,
        ),
      );
    } catch (error, stackTrace) {
      developer.log(
        'UpdateMember failed',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: FamilyStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteMember(
    DeleteMember event,
    Emitter<FamilyState> emit,
  ) async {
    emit(state.copyWith(status: FamilyStatus.saving, clearError: true));

    try {
      await _repository.deleteMember(event.memberId);
      final members = await _repository.loadMembers(syncRemote: true);
      final isOffline = !(await _repository.isOnline());

      emit(
        state.copyWith(
          status: FamilyStatus.loaded,
          members: members,
          isOffline: isOffline,
          pendingSync: !isOffline,
        ),
      );
    } catch (error, stackTrace) {
      developer.log(
        'DeleteMember failed',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: FamilyStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
