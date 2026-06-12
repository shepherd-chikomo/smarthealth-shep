import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_practice/core/config/my_practice_config.dart';

class BiometricService {
  BiometricService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> get isAvailable async {
    if (!MyPracticeConfig.enableBiometrics) return false;
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate({String reason = 'Unlock MyPractice'}) async {
    if (!await isAvailable) return true;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
