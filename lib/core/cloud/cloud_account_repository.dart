import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/auth/patient_profile.dart';
import 'package:smarthealth_shep/core/cloud/cloud_account_dao.dart';
import 'package:smarthealth_shep/core/cloud/cloud_account_model.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/core/patient_id/patient_identity_service.dart';

final cloudAccountRepositoryProvider = Provider<CloudAccountRepository>((ref) {
  return CloudAccountRepository(
    dio: ref.watch(dioProvider),
    identity: PatientIdentityService(),
  );
});

/// Local cache + remote fetch for cloud-safe account data only.
class CloudAccountRepository {
  CloudAccountRepository({
    CloudAccountDao? dao,
    required Dio dio,
    required PatientIdentityService identity,
  })  : _dao = dao ?? CloudAccountDao(),
        _dio = dio,
        _identity = identity;

  final CloudAccountDao _dao;
  final Dio _dio;
  final PatientIdentityService _identity;

  Future<CloudAccount?> readCached() => _dao.read();

  Future<CloudAccount?> fetchAndCache({bool allowOffline = true}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/patients/me');
      final profileJson =
          response.data?['profile'] as Map<String, dynamic>? ?? const {};
      final profile = PatientProfile.fromJson(profileJson);
      final shpId = await _identity.resolve(
        apiPatientId: profile.id,
        apiSmarthealthPatientId:
            profileJson['smarthealthPatientId'] as String?,
      );
      final account = CloudAccount(
        accountUuid: profile.id ?? shpId,
        smarthealthPatientId: shpId,
        firstName: profile.firstName,
        lastName: profile.lastName,
        phone: profile.phone,
        email: profile.email,
        dateOfBirth: profile.dateOfBirth,
        gender: profile.gender,
        updatedAt: DateTime.now().toUtc(),
      );
      await _dao.upsert(account);
      return account;
    } on DioException {
      if (!allowOffline) rethrow;
      return _dao.read();
    }
  }

  Future<void> clear() => _dao.clear();
}
