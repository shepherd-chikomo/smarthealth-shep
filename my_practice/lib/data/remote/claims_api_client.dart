import 'package:dio/dio.dart';
import 'package:my_practice/domain/models/claim_models.dart';
import 'package:my_practice/domain/models/portal_profile.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class ClaimsApiClient {
  ClaimsApiClient(this._dio);

  final Dio _dio;

  Dio get _publicDio => createApiDio();

  Future<ProviderLookupResult> lookupProviderByEmail(String email) async {
    final res = await _publicDio.get<Map<String, dynamic>>(
      '/claims/lookup/provider',
      queryParameters: {'email': email.trim()},
    );
    return ProviderLookupResult.fromJson(res.data ?? {});
  }

  Future<OnboardingStatus> onboardingStatus() async {
    final res = await _dio.get<Map<String, dynamic>>('/claims/me/onboarding-status');
    return OnboardingStatus.fromJson(res.data ?? {});
  }

  Future<List<LinkedFacility>> myPrimaryFacilities() async {
    final res = await _dio.get<Map<String, dynamic>>('/claims/me/primary-facilities');
    final raw = res.data?['facilities'] as List<dynamic>? ?? [];
    return raw
        .map((f) => LinkedFacility.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  Future<RegistryEmailMatch> registryEmailMatch() async {
    final res = await _dio.get<Map<String, dynamic>>('/claims/me/registry-email-match');
    return RegistryEmailMatch.fromJson(res.data ?? {});
  }

  Future<void> instantClaimFacility(String facilityId) async {
    await _dio.post<Map<String, dynamic>>(
      '/claims/facility/$facilityId/instant-claim',
    );
  }

  Future<List<ClaimableFacility>> searchFacilities({String? query, int page = 1}) async {
    final res = await _publicDio.get<Map<String, dynamic>>(
      '/claims/search/facilities',
      queryParameters: {
        'page': page,
        'limit': 20,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );
    final raw = res.data?['facilities'] as List<dynamic>? ?? [];
    return raw
        .map((f) => ClaimableFacility.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  Future<List<ClaimableProvider>> searchProviders({String? query, int page = 1}) async {
    final res = await _publicDio.get<Map<String, dynamic>>(
      '/claims/search/providers',
      queryParameters: {
        'page': page,
        'limit': 20,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );
    final raw = res.data?['providers'] as List<dynamic>? ?? [];
    return raw
        .map((p) => ClaimableProvider.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<({List<ClaimRecord> facilityClaims, List<ClaimRecord> providerClaims})>
      myClaims() async {
    final res = await _dio.get<Map<String, dynamic>>('/claims/me');
    final facilityRaw = res.data?['facilityClaims'] as List<dynamic>? ?? [];
    final providerRaw = res.data?['providerClaims'] as List<dynamic>? ?? [];
    return (
      facilityClaims: facilityRaw
          .map((c) => ClaimRecord.fromJson(c as Map<String, dynamic>))
          .toList(),
      providerClaims: providerRaw
          .map((c) => ClaimRecord.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ClaimRecord> createFacilityClaim({
    required String facilityId,
    String? businessRegistrationNumber,
    String? notes,
    Map<String, dynamic>? evidence,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/claims/facility',
      data: {
        'facilityId': facilityId,
        if (businessRegistrationNumber != null)
          'businessRegistrationNumber': businessRegistrationNumber,
        if (notes != null) 'notes': notes,
        if (evidence != null) 'evidence': evidence,
      },
    );
    return ClaimRecord.fromJson(
      res.data?['claim'] as Map<String, dynamic>? ?? res.data ?? {},
    );
  }

  Future<ClaimRecord> createProviderClaim({
    required String providerId,
    String? mdpczNumber,
    String? notes,
    Map<String, dynamic>? evidence,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/claims/provider',
      data: {
        'providerId': providerId,
        if (mdpczNumber != null) 'mdpczNumber': mdpczNumber,
        if (notes != null) 'notes': notes,
        if (evidence != null) 'evidence': evidence,
      },
    );
    return ClaimRecord.fromJson(
      res.data?['claim'] as Map<String, dynamic>? ?? res.data ?? {},
    );
  }

  Future<ClaimRecord> updateFacilityClaim(
    String id, {
    String? businessRegistrationNumber,
    String? notes,
    Map<String, dynamic>? evidence,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/claims/facility/$id',
      data: {
        if (businessRegistrationNumber != null)
          'businessRegistrationNumber': businessRegistrationNumber,
        if (notes != null) 'notes': notes,
        if (evidence != null) 'evidence': evidence,
      },
    );
    return ClaimRecord.fromJson(
      res.data?['claim'] as Map<String, dynamic>? ?? res.data ?? {},
    );
  }

  Future<ClaimRecord> submitFacilityClaim(String id) async {
    final res = await _dio.post<Map<String, dynamic>>('/claims/facility/$id/submit');
    return ClaimRecord.fromJson(
      res.data?['claim'] as Map<String, dynamic>? ?? res.data ?? {},
    );
  }

  Future<ClaimRecord> submitProviderClaim(String id) async {
    final res = await _dio.post<Map<String, dynamic>>('/claims/provider/$id/submit');
    return ClaimRecord.fromJson(
      res.data?['claim'] as Map<String, dynamic>? ?? res.data ?? {},
    );
  }

  Future<Map<String, dynamic>> validatePractitionerCredentials({
    required String registrationNumber,
    required String email,
    required String specialty,
  }) async {
    final res = await _publicDio.post<Map<String, dynamic>>(
      '/claims/practitioner/validate',
      data: {
        'registrationNumber': registrationNumber,
        'email': email.trim(),
        'specialty': specialty,
      },
    );
    return res.data ?? {};
  }

  Future<String> sendPractitionerClaimOtp({
    required String registrationNumber,
    required String email,
    required String specialty,
  }) async {
    final res = await _publicDio.post<Map<String, dynamic>>(
      '/claims/practitioner/otp/send',
      data: {
        'registrationNumber': registrationNumber,
        'email': email.trim(),
        'specialty': specialty,
      },
    );
    return res.data?['sessionId'] as String? ?? '';
  }

  Future<Map<String, dynamic>> verifyPractitionerClaimOtp({
    required String sessionId,
    required String otp,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/claims/practitioner/otp/verify',
      data: {'sessionId': sessionId, 'otp': otp},
    );
    return res.data ?? {};
  }

  Future<String> submitManualValidation({
    required String registrationNumber,
    required String specialty,
    String? submitterName,
    String? submitterEmail,
    String? submitterPhone,
    Map<String, dynamic>? evidence,
  }) async {
    final res = await _publicDio.post<Map<String, dynamic>>(
      '/claims/practitioner/manual-validation',
      data: {
        'registrationNumber': registrationNumber,
        'specialty': specialty,
        if (submitterName != null) 'submitterName': submitterName,
        if (submitterEmail != null) 'submitterEmail': submitterEmail,
        if (submitterPhone != null) 'submitterPhone': submitterPhone,
        if (evidence != null) 'evidence': evidence,
      },
    );
    return res.data?['ticketId'] as String? ?? '';
  }
}

String? extractApiError(DioException error) {
  final data = error.response?.data;
  if (data is Map && data['error'] is Map) {
    return (data['error'] as Map)['message'] as String?;
  }
  return error.message;
}

String? extractApiErrorCode(DioException error) {
  final data = error.response?.data;
  if (data is Map && data['error'] is Map) {
    return (data['error'] as Map)['code'] as String?;
  }
  return null;
}
