import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Shared operational helpers for search, cards, and map markers.
abstract final class ProviderOperationalUtils {
  /// Estimated wait in minutes from explicit field or queue length heuristic.
  static int? estimatedWaitMinutes(ProviderModel provider) {
    if (provider.waitEstimateMinutes != null) {
      return provider.waitEstimateMinutes;
    }
    if (provider.queueLength != null && provider.queueLength! > 0) {
      return provider.queueLength! * 6;
    }
    return null;
  }

  static bool isQueueUnder30Minutes(ProviderModel provider) {
    final wait = estimatedWaitMinutes(provider);
    return wait != null && wait <= 30;
  }

  static bool hasHighQueue(ProviderModel provider) {
    final wait = estimatedWaitMinutes(provider);
    return wait != null && wait > 30;
  }
}
