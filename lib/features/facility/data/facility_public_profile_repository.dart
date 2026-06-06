import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/features/facility/data/facility_public_profile_cache.dart';
import 'package:smarthealth_shep/shared/models/facility_public_profile.dart';

const _logName = 'FacilityPublicProfileRepository';

class FacilityPublicProfileResult {
  const FacilityPublicProfileResult({
    required this.profile,
    required this.isOffline,
    required this.isStale,
  });

  final FacilityPublicProfile profile;
  final bool isOffline;
  final bool isStale;
}

class FacilityPublicProfileRepository {
  FacilityPublicProfileRepository({
    ApiService? api,
    FacilityPublicProfileCache? cache,
    Connectivity? connectivity,
  })  : _api = api ?? ApiService(createApiDio()),
        _cache = cache ?? FacilityPublicProfileCache(),
        _connectivity = connectivity ?? Connectivity();

  final ApiService _api;
  final FacilityPublicProfileCache _cache;
  final Connectivity _connectivity;

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<FacilityPublicProfileResult> getPublicProfile(
    String facilityId, {
    double? distanceKm,
    bool forceRefresh = false,
  }) async {
    final online = await _isOnline();
    final cached = _cache.read(facilityId);
    final stale = _cache.isStale(facilityId);

    if (online && (forceRefresh || cached == null || stale)) {
      try {
        final remote = await _api.fetchFacilityPublicProfile(
          facilityId,
          distanceKm: distanceKm,
        );
        if (remote != null) {
          await _cache.save(facilityId, remote.toJson());
          return FacilityPublicProfileResult(
            profile: remote,
            isOffline: false,
            isStale: false,
          );
        }
      } catch (error, stackTrace) {
        developer.log(
          'Public profile fetch failed',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (cached != null) {
      return FacilityPublicProfileResult(
        profile: FacilityPublicProfile.fromJson(cached),
        isOffline: !online,
        isStale: stale || !online,
      );
    }

    throw Exception('Facility profile unavailable offline');
  }

  Future<List<FacilitySpecialistSummary>> fetchSpecialists(
    String facilityId, {
    int limit = 5,
    String? serviceId,
  }) async {
    if (!await _isOnline()) return [];
    return _api.fetchFacilitySpecialists(
      facilityId,
      limit: limit,
      serviceId: serviceId,
    );
  }

  Future<List<FacilityAvailabilityDay>> fetchAvailability(
    String facilityId, {
    String? serviceId,
    int days = 2,
  }) async {
    if (!await _isOnline()) return [];
    return _api.fetchFacilityAvailability(
      facilityId,
      serviceId: serviceId,
      days: days,
    );
  }
}
