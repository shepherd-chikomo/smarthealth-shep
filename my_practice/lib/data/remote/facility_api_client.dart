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

  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _path('/facility/patients?q=${Uri.encodeComponent(query)}'),
    );
    final items = res.data?['items'] as List<dynamic>? ?? [];
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
