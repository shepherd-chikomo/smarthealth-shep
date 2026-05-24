import 'package:smarthealth_shep/core/auth/patient_profile.dart';

/// Local testing auth bypass — **never active in release builds**.
///
/// Controlled by [AppConfig.skipAuthForTesting]. Remove or set `SKIP_AUTH=false`
/// when pointing the app at a real API during development.
abstract final class DevAuthBypass {
  static const userId = 'dev-test-user';
  static const firstName = 'Tendai';
  static const lastName = 'Moyo';
  static const phone = '+263771234567';
  static const email = 'tendai@example.com';

  static const PatientProfile profile = PatientProfile(
    firstName: firstName,
    lastName: lastName,
    displayName: '$firstName $lastName',
    phone: phone,
    email: email,
  );
}
