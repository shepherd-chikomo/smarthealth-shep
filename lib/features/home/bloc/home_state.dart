import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/features/queue/models/queue_session.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

bool homeCategoryMatches(String providerCategoryId, String filterId) {
  return switch (filterId) {
    'general' => providerCategoryId == 'general' || providerCategoryId == 'gp',
    'dental' =>
      providerCategoryId == 'dental' || providerCategoryId == 'dentist',
    'pharmacy' => providerCategoryId == 'pharmacy',
    'lab' => providerCategoryId == 'lab',
    'pediatrics' =>
      providerCategoryId == 'pediatrics' || providerCategoryId == 'pediatric',
    'specialist' => !const {
      'general',
      'gp',
      'dental',
      'dentist',
      'pharmacy',
      'lab',
      'pediatrics',
      'pediatric',
    }.contains(providerCategoryId),
    _ => providerCategoryId == filterId,
  };
}

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
    this.activeQueue,
  });

  final String city;
  final List<ProviderModel> providers;
  final DateTime lastUpdated;
  final String? selectedCategoryId;
  final bool isRefreshing;
  final bool isOffline;
  final QueueSession? activeQueue;

  List<ProviderModel> get visibleProviders {
    if (selectedCategoryId == null || selectedCategoryId == 'near_me') {
      return providers;
    }
    return providers
        .where((p) => homeCategoryMatches(p.categoryId, selectedCategoryId!))
        .toList();
  }

  HomeLoaded copyWith({
    String? city,
    List<ProviderModel>? providers,
    DateTime? lastUpdated,
    String? selectedCategoryId,
    bool? isRefreshing,
    bool? isOffline,
    QueueSession? activeQueue,
    bool clearCategory = false,
    bool clearQueue = false,
  }) {
    return HomeLoaded(
      city: city ?? this.city,
      providers: providers ?? this.providers,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isOffline: isOffline ?? this.isOffline,
      activeQueue: clearQueue ? null : (activeQueue ?? this.activeQueue),
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
        activeQueue,
      ];
}

final class HomeOffline extends HomeState {
  const HomeOffline({
    required this.city,
    required this.providers,
    required this.lastUpdated,
    this.selectedCategoryId,
    this.activeQueue,
  });

  final String city;
  final List<ProviderModel> providers;
  final DateTime lastUpdated;
  final String? selectedCategoryId;
  final QueueSession? activeQueue;

  List<ProviderModel> get visibleProviders {
    if (selectedCategoryId == null || selectedCategoryId == 'near_me') {
      return providers;
    }
    return providers
        .where((p) => homeCategoryMatches(p.categoryId, selectedCategoryId!))
        .toList();
  }

  HomeOffline copyWith({
    String? city,
    List<ProviderModel>? providers,
    DateTime? lastUpdated,
    String? selectedCategoryId,
    QueueSession? activeQueue,
    bool clearCategory = false,
    bool clearQueue = false,
  }) {
    return HomeOffline(
      city: city ?? this.city,
      providers: providers ?? this.providers,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      activeQueue: clearQueue ? null : (activeQueue ?? this.activeQueue),
    );
  }

  @override
  List<Object?> get props =>
      [city, providers, lastUpdated, selectedCategoryId, activeQueue];
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
