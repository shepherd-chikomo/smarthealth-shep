import 'package:dio/dio.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/features/profile/models/consent_record.dart';

class ConsentRepository {
  ConsentRepository({Dio? dio}) : _dio = dio ?? createApiDio();

  final Dio _dio;

  Future<List<ConsentRecord>> listConsents() async {
    final response = await _dio.get<Map<String, dynamic>>('/patients/consents');
    final raw = response.data?['consents'] as List<dynamic>? ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ConsentRecord.fromJson)
        .toList();
  }

  Future<void> withdrawConsent(
    String consentType, {
    String? facilityId,
  }) async {
    await _dio.delete<void>(
      '/patients/consents/$consentType',
      queryParameters: {
        if (facilityId != null) 'facilityId': facilityId,
      },
    );
  }
}
