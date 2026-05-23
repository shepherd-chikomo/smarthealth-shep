import 'package:equatable/equatable.dart';

sealed class ProviderProfileEvent extends Equatable {
  const ProviderProfileEvent();

  @override
  List<Object?> get props => [];
}

final class LoadProviderProfile extends ProviderProfileEvent {
  const LoadProviderProfile(this.providerId);

  final String providerId;

  @override
  List<Object?> get props => [providerId];
}

final class ReloadProviderProfile extends ProviderProfileEvent {
  const ReloadProviderProfile();
}
