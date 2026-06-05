import 'package:equatable/equatable.dart';
sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class LoadHomeData extends HomeEvent {
  const LoadHomeData({this.nearMeLabel = 'Near Me'});

  final String nearMeLabel;

  @override
  List<Object?> get props => [nearMeLabel];
}

final class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}

final class SelectHomeCategory extends HomeEvent {
  const SelectHomeCategory(this.categoryId);

  final String? categoryId;

  @override
  List<Object?> get props => [categoryId];
}

final class ChangeHomeCity extends HomeEvent {
  const ChangeHomeCity(this.city);

  final String city;

  @override
  List<Object?> get props => [city];
}

final class LoadHomeCityFallback extends HomeEvent {
  const LoadHomeCityFallback();
}
