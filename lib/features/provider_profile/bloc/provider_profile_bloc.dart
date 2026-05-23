import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/provider_profile/bloc/provider_profile_event.dart';
import 'package:smarthealth_shep/features/provider_profile/bloc/provider_profile_state.dart';
import 'package:smarthealth_shep/features/provider_profile/data/provider_profile_repository.dart';

class ProviderProfileBloc
    extends Bloc<ProviderProfileEvent, ProviderProfileState> {
  ProviderProfileBloc({
    required String providerId,
    ProviderProfileRepository? repository,
  })  : _repository = repository ?? ProviderProfileRepository(),
        super(ProviderProfileState(providerId: providerId)) {
    on<LoadProviderProfile>(_onLoad);
    on<ReloadProviderProfile>(_onReload);

    add(LoadProviderProfile(providerId));
  }

  final ProviderProfileRepository _repository;

  Future<void> _onLoad(
    LoadProviderProfile event,
    Emitter<ProviderProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProviderProfileStatus.loading,
        providerId: event.providerId,
        clearError: true,
      ),
    );
    await _fetch(event.providerId, emit);
  }

  Future<void> _onReload(
    ReloadProviderProfile event,
    Emitter<ProviderProfileState> emit,
  ) async {
    final id = state.providerId;
    if (id == null) return;
    emit(
      state.copyWith(
        status: ProviderProfileStatus.loading,
        clearError: true,
      ),
    );
    await _fetch(id, emit);
  }

  Future<void> _fetch(String id, Emitter<ProviderProfileState> emit) async {
    try {
      final result = await _repository.fetchProfile(id);
      if (result == null) {
        emit(
          state.copyWith(
            status: ProviderProfileStatus.notFound,
            clearProvider: true,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: ProviderProfileStatus.loaded,
          provider: result.provider,
          fromCache: result.fromCache,
          isOffline: result.isOffline,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProviderProfileStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
