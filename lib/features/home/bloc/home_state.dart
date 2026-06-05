import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/core/location/models/location_models.dart';
import 'package:smarthealth_shep/features/queue/models/queue_session.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/models/service_category_model.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading({this.categories = const []});

  final List<ServiceCategoryModel> categories;

  @override
  List<Object?> get props => [categories];
}

final class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.city,
    required this.facilities,
    required this.lastUpdated,
    required this.categories,
    this.selectedCategoryId,
    this.isRefreshing = false,
    this.isOffline = false,
    this.activeQueue,
    this.loadError,
    this.searchOrigin,
  });

  final String city;
  final List<FacilityModel> facilities;
  final DateTime lastUpdated;
  final List<ServiceCategoryModel> categories;
  final String? selectedCategoryId;
  final bool isRefreshing;
  final bool isOffline;
  final QueueSession? activeQueue;
  final String? loadError;
  final AppPosition? searchOrigin;

  List<FacilityModel> get visibleFacilities {
    if (selectedCategoryId == null || selectedCategoryId == 'near_me') {
      return facilities;
    }
    return facilities
        .where((f) => f.facilityType == selectedCategoryId)
        .toList();
  }

  HomeLoaded copyWith({
    String? city,
    List<FacilityModel>? facilities,
    DateTime? lastUpdated,
    List<ServiceCategoryModel>? categories,
    String? selectedCategoryId,
    bool? isRefreshing,
    bool? isOffline,
    QueueSession? activeQueue,
    String? loadError,
    AppPosition? searchOrigin,
    bool clearCategory = false,
    bool clearQueue = false,
    bool clearLoadError = false,
  }) {
    return HomeLoaded(
      city: city ?? this.city,
      facilities: facilities ?? this.facilities,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      categories: categories ?? this.categories,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isOffline: isOffline ?? this.isOffline,
      activeQueue: clearQueue ? null : (activeQueue ?? this.activeQueue),
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      searchOrigin: searchOrigin ?? this.searchOrigin,
    );
  }

  @override
  List<Object?> get props => [
        city,
        facilities,
        lastUpdated,
        categories,
        selectedCategoryId,
        isRefreshing,
        isOffline,
        activeQueue,
        loadError,
        searchOrigin,
      ];
}

final class HomeOffline extends HomeState {
  const HomeOffline({
    required this.city,
    required this.facilities,
    required this.lastUpdated,
    required this.categories,
    this.selectedCategoryId,
    this.activeQueue,
    this.searchOrigin,
  });

  final String city;
  final List<FacilityModel> facilities;
  final DateTime lastUpdated;
  final List<ServiceCategoryModel> categories;
  final String? selectedCategoryId;
  final QueueSession? activeQueue;
  final AppPosition? searchOrigin;

  List<FacilityModel> get visibleFacilities {
    if (selectedCategoryId == null || selectedCategoryId == 'near_me') {
      return facilities;
    }
    return facilities
        .where((f) => f.facilityType == selectedCategoryId)
        .toList();
  }

  HomeOffline copyWith({
    String? city,
    List<FacilityModel>? facilities,
    DateTime? lastUpdated,
    List<ServiceCategoryModel>? categories,
    String? selectedCategoryId,
    QueueSession? activeQueue,
    AppPosition? searchOrigin,
    bool clearCategory = false,
    bool clearQueue = false,
  }) {
    return HomeOffline(
      city: city ?? this.city,
      facilities: facilities ?? this.facilities,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      categories: categories ?? this.categories,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      activeQueue: clearQueue ? null : (activeQueue ?? this.activeQueue),
      searchOrigin: searchOrigin ?? this.searchOrigin,
    );
  }

  @override
  List<Object?> get props => [
        city,
        facilities,
        lastUpdated,
        categories,
        selectedCategoryId,
        activeQueue,
        searchOrigin,
      ];
}

final class HomeError extends HomeState {
  const HomeError({
    required this.message,
    this.cachedFacilities,
    this.lastUpdated,
    this.city,
    this.categories = const [],
  });

  final String message;
  final List<FacilityModel>? cachedFacilities;
  final DateTime? lastUpdated;
  final String? city;
  final List<ServiceCategoryModel> categories;

  @override
  List<Object?> get props =>
      [message, cachedFacilities, lastUpdated, city, categories];
}
