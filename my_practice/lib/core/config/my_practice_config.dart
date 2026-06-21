import 'package:flutter/foundation.dart';

/// MyPractice runtime configuration.
abstract final class MyPracticeConfig {
  static const bool devMode = bool.fromEnvironment(
    'DEV_MODE',
    defaultValue: false,
  );

  static const bool enableBiometrics = bool.fromEnvironment(
    'ENABLE_BIOMETRICS',
    defaultValue: true,
  );

  static const int sessionTimeoutMinutes = int.fromEnvironment(
    'SESSION_TIMEOUT_MINUTES',
    defaultValue: 15,
  );

  static bool get useSeedData => devMode || kDebugMode && devMode;

  /// True when running local seed / dev bypass (debug builds with SKIP_AUTH, etc.).
  static bool get useLocalDevSeed {
    if (kReleaseMode) return devMode;
    return devMode || skipAuthForTesting || kDebugMode;
  }

  static bool get skipAuthForTesting {
    if (kReleaseMode) return false;
    const skip = bool.fromEnvironment('SKIP_AUTH', defaultValue: false);
    return skip || devMode;
  }
}

/// Known feature flag keys (remote + local defaults).
abstract final class FeatureFlagKeys {
  static const claimsModule = 'ENABLE_CLAIMS_MODULE';
  static const voiceDictation = 'ENABLE_VOICE_DICTATION';
  static const edliz = 'ENABLE_EDLIZ';
  static const icd11 = 'ENABLE_ICD11';
  static const providerNetwork = 'ENABLE_PROVIDER_NETWORK';
  static const connect = 'ENABLE_CONNECT';
  static const switchModule = 'ENABLE_SWITCH';
  static const insights = 'ENABLE_INSIGHTS';
  static const telemedicine = 'ENABLE_TELEMEDICINE';
  static const aiCopilot = 'ENABLE_AI_COPILOT';

  static const all = [
    claimsModule,
    voiceDictation,
    edliz,
    icd11,
    providerNetwork,
    connect,
    switchModule,
    insights,
    telemedicine,
    aiCopilot,
  ];
}
