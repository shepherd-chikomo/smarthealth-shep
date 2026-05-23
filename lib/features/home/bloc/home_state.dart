import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.city,
    required this.providers,
    required this.lastUpdated,
    this.selectedCategoryId,
    this.isRefreshing = false,
    this.isOffline = false,
  });

  final String city;
  final List<ProviderModel> providers;
  final DateTime lastUpdated;
  final String? selectedCategoryId;
  final bool isRefreshing;
  final bool isOffline;

  List<ProviderModel> get visibleProviders {
    if (selectedCategoryId == null || selectedCategoryId == 'near_me') {
      return providers;
    }
    return providers
        .where((p) => p.categoryId == selectedCategoryId)
        .toList();
  }

  HomeLoaded copyWith({
    String? city,
    List<ProviderModel>? providers,
    DateTime? lastUpdated,
    String? selectedCategoryId,
    bool? isRefreshing,
    bool? isOffline,
    bool clearCategory = false,
  }) {
    return HomeLoaded(
      city: city ?? this.city,
      providers: providers ?? this.providers,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
        city,
        providers,
        lastUpdated,
        selectedCategoryId,
        isRefreshing,
        isOffline,
      ];
}

final class HomeOffline extends HomeState {
  const HomeOffline({
    required this.city,
    required this.providers,
    required this.lastUpdated,
    this.selectedCategoryId,
  });

  final String city;
  final List<ProviderModel> providers;
  final DateTime lastUpdated;
  final String? selectedCategoryId;

  List<ProviderModel> get visibleProviders {
    if (selectedCategoryId == null || selectedCategoryId == 'near_me') {
      return providers;
    }
    return providers
        .where((p) => p.categoryId == selectedCategoryId)
        .toList();
  }

  HomeOffline copyWith({
    String? city,
    List<ProviderModel>? providers,
    DateTime? lastUpdated,
    String? selectedCategoryId,
    bool clearCategory = false,
  }) {
    return HomeOffline(
      city: city ?? this.city,
      providers: providers ?? this.providers,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }

  @override
  List<Object?> get props =>
      [city, providers, lastUpdated, selectedCategoryId];
}

final class HomeError extends HomeState {
  const HomeError({
    required this.message,
    this.cachedProviders,
    this.lastUpdated,
    this.city,
  });

  final String message;
  final List<ProviderModel>? cachedProviders;
  final DateTime? lastUpdated;
  final String? city;

  @override
  List<Object?> get props =>
      [message, cachedProviders, lastUpdated, city];
}
