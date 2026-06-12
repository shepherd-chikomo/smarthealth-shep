import 'package:flutter/foundation.dart';

/// Runtime configuration via `--dart-define` flags.
abstract final class AppConfig {
  static const bool useMainDatabase = bool.fromEnvironment(
    'USE_MAIN_DATABASE',
    defaultValue: true,
  );

  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'http://localhost:3000/v1';
  }

  static const bool allowMockData = bool.fromEnvironment(
    'ALLOW_MOCK_DATA',
    defaultValue: false,
  );

  static bool get usesLocalhostApi =>
      apiBaseUrl.contains('localhost') ||
      apiBaseUrl.contains('127.0.0.1') ||
      apiBaseUrl.contains('10.0.2.2');

  static bool get allowMockFallbacks =>
      kDebugMode && allowMockData && !useMainDatabase;

  static bool get skipAuthForTesting {
    if (kReleaseMode) return false;
    const skipAuthFlag = bool.fromEnvironment('SKIP_AUTH', defaultValue: false);
    return skipAuthFlag || usesLocalhostApi;
  }

  static bool get isReleaseMode => kReleaseMode;

  static bool get trustDevCertificates {
    if (kReleaseMode) return false;
    const fromEnv = bool.fromEnvironment(
      'TRUST_DEV_CERTIFICATES',
      defaultValue: false,
    );
    if (fromEnv) return true;
    final host = Uri.tryParse(apiBaseUrl)?.host ?? '';
    return host == 'dev.smarthealth.co.zw';
  }

  static const double defaultLatitude = -17.8252;
  static const double defaultLongitude = 31.0335;
}
