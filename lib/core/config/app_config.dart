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

  /// Whether mock fallbacks are permitted (debug builds only, unless explicitly enabled).
  static bool get allowMockFallbacks => kDebugMode && allowMockData;

  static bool get seedMockDataOnEmpty => allowMockFallbacks;

  static bool get isReleaseMode => kReleaseMode;
}
