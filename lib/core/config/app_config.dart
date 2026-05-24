import 'package:flutter/foundation.dart';

/// Runtime configuration via `--dart-define` flags.
abstract final class AppConfig {
  /// REST API base URL including version prefix, e.g. `https://api.example.com/v1`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost/v1',
  );

  /// When true, empty local stores may be seeded with demo catalog data.
  static const bool allowMockData = bool.fromEnvironment(
    'ALLOW_MOCK_DATA',
    defaultValue: false,
  );

  /// True when the API URL targets the dev machine loopback (invalid on physical devices).
  static bool get usesLocalhostApi =>
      apiBaseUrl.contains('localhost') || apiBaseUrl.contains('127.0.0.1');

  /// Whether mock fallbacks are permitted (debug + explicit flag, or debug on localhost).
  static bool get allowMockFallbacks =>
      kDebugMode && (allowMockData || usesLocalhostApi);

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
}
