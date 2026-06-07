import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smarthealth_shep/core/patient_id/smarthealth_patient_id.dart';

/// Resolves immutable SmartHealth Patient ID for bookings and facility matching.
class PatientIdentityService {
  PatientIdentityService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const _patientIdKey = 'sh_smarthealth_patient_id';
  final FlutterSecureStorage _storage;

  Future<String> resolve({
    String? apiPatientId,
    String? apiSmarthealthPatientId,
  }) async {
    if (SmartHealthPatientId.isValid(apiSmarthealthPatientId)) {
      final id = apiSmarthealthPatientId!;
      await _persist(id);
      return id;
    }

    final cached = await _storage.read(key: _patientIdKey);
    if (SmartHealthPatientId.isValid(cached)) return cached!;

    final generated = SmartHealthPatientId.generate();
    await _persist(generated);
    return generated;
  }

  Future<String?> readCached() async {
    final cached = await _storage.read(key: _patientIdKey);
    return SmartHealthPatientId.isValid(cached) ? cached : null;
  }

  Future<void> _persist(String id) =>
      _storage.write(key: _patientIdKey, value: id.toUpperCase());

  Future<void> wipe() => _storage.delete(key: _patientIdKey);
}
