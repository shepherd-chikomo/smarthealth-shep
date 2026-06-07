import 'package:flutter/foundation.dart';

/// Runtime configuration via `--dart-define` flags.
abstract final class AppConfig {
  /// When true (default), the app uses the REST API / main database and does not
  /// seed or fall back to bundled demo data.
  static const bool useMainDatabase = bool.fromEnvironment(
    'USE_MAIN_DATABASE',
    defaultValue: true,
  );

  /// REST API base URL including version prefix, e.g. `https://api.example.com/v1`.
  ///
  /// Override on a physical device with your machine's LAN IP, e.g.
  /// `--dart-define=API_BASE_URL=http://192.168.1.10:3000/v1`.
  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'http://localhost:3000/v1';
  }

  /// When true, empty local stores may be seeded with demo catalog data.
  static const bool allowMockData = bool.fromEnvironment(
    'ALLOW_MOCK_DATA',
    defaultValue: false,
  );

  /// True when the API URL targets the dev machine loopback (invalid on physical devices).
  static bool get usesLocalhostApi =>
      apiBaseUrl.contains('localhost') ||
      apiBaseUrl.contains('127.0.0.1') ||
      apiBaseUrl.contains('10.0.2.2');

  /// Whether mock fallbacks are permitted (debug demos only).
  static bool get allowMockFallbacks =>
      kDebugMode && allowMockData && !useMainDatabase;

  static bool get seedMockDataOnEmpty => allowMockFallbacks;

  /// Bypass OTP/login for local device testing. Hard-disabled in release builds.
  ///
  /// Enabled in debug when API is localhost, or when `--dart-define=SKIP_AUTH=true`.
  /// Production builds always require real authentication.
  static bool get skipAuthForTesting {
    if (kReleaseMode) return false;
    const skipAuthFlag = bool.fromEnvironment('SKIP_AUTH', defaultValue: false);
    return skipAuthFlag || usesLocalhostApi;
  }

  static bool get isReleaseMode => kReleaseMode;

  /// Accept self-signed TLS for dev hosts in debug builds (never in release).
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

  /// Public web base for shareable facility profile links (no trailing slash).
  static String get publicWebBaseUrl {
    const fromEnv = String.fromEnvironment('PUBLIC_WEB_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv.replaceAll(RegExp(r'/+$'), '');
    return 'https://myhealth.smarthealth.co.zw';
  }

  /// App download landing page appended to facility share messages.
  static String get appDownloadUrl {
    const fromEnv = String.fromEnvironment('APP_DOWNLOAD_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'https://smarthealth.co.zw/download';
  }

  /// Default map centre for Harare when device location is unavailable.
  static const double defaultLatitude = -17.8252;
  static const double defaultLongitude = 31.0335;
  static const double defaultSearchRadiusKm = 50;
}
