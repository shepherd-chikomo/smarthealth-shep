import 'package:smarthealth_shep/core/privacy/data_domains.dart';

/// Guards sync payloads — rejects PHI keys before cloud transmission.
abstract final class PhiBoundary {
  static Map<String, dynamic> stripPhi(Map<String, dynamic> payload) {
    final cleaned = <String, dynamic>{};
    for (final entry in payload.entries) {
      if (DataDomains.healthVaultOnlyFields.contains(entry.key)) continue;
      if (entry.key == 'metadata') continue;
      if (entry.key == 'medicalConditions') continue;
      if (entry.key == 'allergies') continue;
      cleaned[entry.key] = entry.value;
    }
    return cleaned;
  }

  static void assertCloudSafe(Map<String, dynamic> payload) {
    for (final key in payload.keys) {
      if (DataDomains.healthVaultOnlyFields.contains(key)) {
        throw StateError('PHI field "$key" must not be sent to cloud APIs');
      }
      if (key == 'metadata' || key == 'medicalConditions' || key == 'allergies') {
        throw StateError('Clinical field "$key" must remain in Health Vault only');
      }
    }
  }
}
