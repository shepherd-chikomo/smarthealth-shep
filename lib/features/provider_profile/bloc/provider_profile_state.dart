import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

enum ProviderProfileStatus { initial, loading, loaded, notFound, error }

class ProviderProfileState extends Equatable {
  const ProviderProfileState({
    this.status = ProviderProfileStatus.initial,
    this.provider,
    this.fromCache = false,
    this.isOffline = false,
    this.errorMessage,
    this.providerId,
  });

  final ProviderProfileStatus status;
  final ProviderModel? provider;
  final bool fromCache;
  final bool isOffline;
  final String? errorMessage;
  final String? providerId;

  ProviderProfileState copyWith({
    ProviderProfileStatus? status,
    ProviderModel? provider,
    bool? fromCache,
    bool? isOffline,
    String? errorMessage,
    String? providerId,
    bool clearError = false,
    bool clearProvider = false,
  }) {
    return ProviderProfileState(
      status: status ?? this.status,
      provider: clearProvider ? null : (provider ?? this.provider),
      fromCache: fromCache ?? this.fromCache,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      providerId: providerId ?? this.providerId,
    );
  }

  @override
  List<Object?> get props =>
      [status, provider, fromCache, isOffline, errorMessage, providerId];
}
