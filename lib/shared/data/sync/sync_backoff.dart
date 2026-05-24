/// Retry schedule for failed sync queue items.
///
/// Mission-critical offline mutations retry every 15 minutes, up to 10 attempts.
abstract final class SyncBackoff {
  static const maxRetries = 10;

  static const retryInterval = Duration(minutes: 15);

  /// Returns the delay before the next attempt after [retryCount] failures.
  static Duration delayForRetry(int retryCount) => retryInterval;

  static DateTime nextRetryTime(int retryCount, {DateTime? from}) {
    final base = from ?? DateTime.now().toUtc();
    return base.add(retryInterval);
  }

  static bool exceededMaxRetries(int retryCount) => retryCount >= maxRetries;
}
