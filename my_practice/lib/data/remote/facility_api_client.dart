import 'package:dio/dio.dart';
import 'package:my_practice/domain/models/portal_profile.dart';

class FacilityApiClient {
  FacilityApiClient(this._dio, {required this.facilityId});

  final Dio _dio;
  final String facilityId;

  String _path(String path) {
    final sep = path.contains('?') ? '&' : '?';
    return '$path${sep}facilityId=$facilityId';
  }

  Future<PortalProfile> getMe() async {
    final res = await _dio.get<Map<String, dynamic>>(_path('/facility/me'));
    return PortalProfile.fromJson(res.data ?? {});
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final res =
        await _dio.get<Map<String, dynamic>>(_path('/facility/dashboard'));
    return res.data ?? {};
  }

  Future<List<Map<String, dynamic>>> getQueue() async {
    final res =
        await _dio.get<Map<String, dynamic>>(_path('/facility/queue'));
    final items = res.data?['items'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<void> updateQueueStatus(String id, String status) async {
    await _dio.patch<Map<String, dynamic>>(
      _path('/facility/queue/$id/status'),
      data: {'status': status},
    );
  }

  Future<List<Map<String, dynamic>>> getAppointments({
    String? from,
    String? to,
  }) async {
    final params = <String, String>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final qs = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final path = qs.isEmpty
        ? '/facility/appointments'
        : '/facility/appointments?$qs';
    final res = await _dio.get<Map<String, dynamic>>(_path(path));
    final items = res.data?['items'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> listPatients({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _path('/facility/patients?page=$page&limit=$limit'),
    );
    final items = res.data?['patients'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _path('/facility/patients?q=${Uri.encodeComponent(query)}'),
    );
    final items = res.data?['patients'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getPatientChart(String patientId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _path('/clinical/patients/$patientId/chart'),
    );
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> createConsultation(
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _path('/clinical/consultations'),
      data: body,
    );
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> updateConsultation(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      _path('/clinical/consultations/$id'),
      data: body,
    );
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> completeConsultation(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _path('/clinical/consultations/$id/complete'),
    );
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> createDiagnosis(
    String consultationId, {
    required String patientId,
    required String providerId,
    required String icd11Code,
    required String description,
    bool isPrimary = true,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _path('/clinical/consultations/$consultationId/diagnoses'),
      data: {
        'patientId': patientId,
        'providerId': providerId,
        'icd11Code': icd11Code,
        'description': description,
        'isPrimary': isPrimary,
      },
    );
    return res.data ?? {};
  }

  Future<List<Map<String, dynamic>>> searchIcd11(String q) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/catalog/icd11/search?q=${Uri.encodeComponent(q)}',
    );
    final items = res.data?['items'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getEdlizRecommendations(
    String icd11Code,
  ) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/catalog/edliz?icd11Code=${Uri.encodeComponent(icd11Code)}',
    );
    final items = res.data?['items'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getStaff() async {
    final res = await _dio.get<Map<String, dynamic>>(_path('/facility/staff'));
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> addStaff({
    required String fullName,
    required String email,
    required String role,
    String? phone,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _path('/facility/staff'),
      data: {
        'fullName': fullName,
        'email': email,
        'role': role,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> updateStaff(
    String membershipId, {
    String? fullName,
    String? email,
    String? phone,
    String? role,
    List<String>? additionalRoles,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      _path('/facility/staff/$membershipId'),
      data: {
        if (fullName != null) 'fullName': fullName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (role != null) 'role': role,
        if (additionalRoles != null) 'additionalRoles': additionalRoles,
      },
    );
    return res.data ?? {};
  }

  Future<void> removeStaff(String membershipId) async {
    await _dio.delete<void>(_path('/facility/staff/$membershipId'));
  }

  Future<Map<String, dynamic>> suspendStaff(String membershipId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _path('/facility/staff/$membershipId/suspend'),
    );
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> unsuspendStaff(String membershipId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _path('/facility/staff/$membershipId/unsuspend'),
    );
    return res.data ?? {};
  }

  Future<List<Map<String, dynamic>>> getFacilityHours() async {
    final res = await _dio.get<Map<String, dynamic>>(_path('/facility/hours'));
    final hours = res.data?['hours'] as List<dynamic>? ?? [];
    return hours.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> updateFacilityHours(
    List<Map<String, dynamic>> hours,
  ) async {
    final res = await _dio.put<Map<String, dynamic>>(
      _path('/facility/hours'),
      data: {'hours': hours},
    );
    final updated = res.data?['hours'] as List<dynamic>? ?? hours;
    return updated.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getProviderAvailability({
    String? providerId,
  }) async {
    var path = '/facility/availability';
    if (providerId != null) {
      path = '$path?providerId=$providerId';
    }
    final res = await _dio.get<Map<String, dynamic>>(_path(path));
    final items = res.data?['availability'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getClaims({String? status}) async {
    var path = '/clinical/claims';
    if (status != null) path = '$path?status=$status';
    final res = await _dio.get<Map<String, dynamic>>(_path(path));
    final items = res.data?['items'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> updateProviderAvailability(
    String providerId,
    List<Map<String, dynamic>> hours,
  ) async {
    final res = await _dio.put<Map<String, dynamic>>(
      _path('/facility/availability/$providerId'),
      data: {'hours': hours},
    );
    final items = res.data?['availability'] as List<dynamic>? ?? hours;
    return items.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res =
        await _dio.get<Map<String, dynamic>>(_path('/facility/profile'));
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      _path('/facility/profile'),
      data: body,
    );
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> updateProfileSettings(
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      _path('/facility/profile-settings'),
      data: body,
    );
    return res.data ?? {};
  }

  Future<Map<String, List<Map<String, dynamic>>>> getServicesCatalog() async {
    final res =
        await _dio.get<Map<String, dynamic>>(_path('/facility/services-catalog'));
    final data = res.data ?? {};
    List<Map<String, dynamic>> mapList(String key) {
      final items = data[key] as List<dynamic>? ?? [];
      return items
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    }

    return {
      'preset': mapList('preset'),
      'other': mapList('other'),
    };
  }

  Future<Map<String, dynamic>> submitServiceProposal({
    required String label,
    String? iconKey,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _path('/facility/service-submissions'),
      data: {
        'label': label,
        if (iconKey != null) 'iconKey': iconKey,
      },
    );
    return res.data ?? {};
  }

  Future<List<Map<String, dynamic>>> getMedicalAidCatalog() async {
    final res =
        await _dio.get<Map<String, dynamic>>(_path('/facility/medical-aid-catalog'));
    final items = res.data?['schemes'] as List<dynamic>? ?? [];
    return items.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  Future<List<Map<String, dynamic>>> getMedicalAidSubmissions({
    String status = 'pending',
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _path('/facility/medical-aid-submissions?status=$status'),
    );
    final items = res.data?['submissions'] as List<dynamic>? ?? [];
    return items.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  Future<Map<String, dynamic>> submitMedicalAidProposal(String name) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _path('/facility/medical-aid-submissions'),
      data: {'name': name},
    );
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> uploadLogo(String filePath, String fileName) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      _path('/facility/logo'),
      data: formData,
    );
    return res.data ?? {};
  }

  Future<void> removeLogo() async {
    await _dio.delete<void>(_path('/facility/logo'));
  }

  Future<Map<String, dynamic>> getSlots() async {
    final res = await _dio.get<Map<String, dynamic>>(_path('/facility/slots'));
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> updateSlots(Map<String, dynamic> body) async {
    final res = await _dio.put<Map<String, dynamic>>(
      _path('/facility/slots'),
      data: body,
    );
    return res.data ?? {};
  }

  Future<List<Map<String, dynamic>>> getCredentials() async {
    final res = await _dio.get<Map<String, dynamic>>(_path('/facility/credentials'));
    final items = res.data?['credentials'] as List<dynamic>? ?? [];
    return items.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  Future<Map<String, dynamic>> createCredential({
    required String credentialType,
    required String title,
    String? issuedAt,
    String? expiresAt,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _path('/facility/credentials'),
      data: {
        'credentialType': credentialType,
        'title': title,
        if (issuedAt != null) 'issuedAt': issuedAt,
        if (expiresAt != null) 'expiresAt': expiresAt,
      },
    );
    return res.data ?? {};
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    final res = await _dio.get<Map<String, dynamic>>(_path('/facility/messages'));
    final items = res.data?['messages'] as List<dynamic>? ?? [];
    return items.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  Future<Map<String, dynamic>> sendMessage({
    required String recipientId,
    required String body,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _path('/facility/messages'),
      data: {'recipientId': recipientId, 'body': body},
    );
    return res.data ?? {};
  }

  Future<void> markMessageRead(String messageId) async {
    await _dio.patch<void>(_path('/facility/messages/$messageId/read'));
  }

  Future<List<String>> getDoctorServiceIds(String providerId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _path('/facility/doctors/$providerId/services'),
    );
    final items = res.data?['serviceIds'] as List<dynamic>? ?? [];
    return items.map((e) => e.toString()).toList();
  }

  Future<List<String>> updateDoctorServiceIds(
    String providerId,
    List<String> serviceIds,
  ) async {
    final res = await _dio.put<Map<String, dynamic>>(
      _path('/facility/doctors/$providerId/services'),
      data: {'serviceIds': serviceIds},
    );
    final items = res.data?['serviceIds'] as List<dynamic>? ?? serviceIds;
    return items.map((e) => e.toString()).toList();
  }

  Future<List<Map<String, dynamic>>> getClaimsSummary() async {
    final res = await _dio.get<Map<String, dynamic>>(
      _path('/clinical/claims/summary'),
    );
    final items = res.data?['items'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    final res =
        await _dio.get<Map<String, dynamic>>(_path('/facility/analytics'));
    return res.data ?? {};
  }
}

class SyncApiClient {
  SyncApiClient(this._dio, {required this.facilityId});

  final Dio _dio;
  final String facilityId;

  Future<Map<String, dynamic>> bootstrap() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/sync/bootstrap?facilityId=$facilityId',
    );
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> delta(DateTime since) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/sync/delta?facilityId=$facilityId&since=${since.toUtc().toIso8601String()}',
    );
    return res.data ?? {};
  }

  Future<void> pushMutations(List<Map<String, dynamic>> mutations) async {
    await _dio.post<Map<String, dynamic>>(
      '/sync/mutations?facilityId=$facilityId',
      data: {'facilityId': facilityId, 'mutations': mutations},
    );
  }
}

class CatalogApiClient {
  CatalogApiClient(this._dio);

  final Dio _dio;

  Future<Map<String, bool>> getFeatureFlags() async {
    final res =
        await _dio.get<Map<String, dynamic>>('/catalog/feature-flags');
    final flags = res.data?['flags'] as Map<String, dynamic>? ?? {};
    return flags.map((k, v) => MapEntry(k, v == true));
  }
}
