/// Exponential backoff schedule for failed sync queue items.
abstract final class SyncBackoff {
  static const maxRetries = 5;

  static const delays = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
  ];

  /// Returns the delay before the next attempt after [retryCount] failures.
  static Duration delayForRetry(int retryCount) {
    if (retryCount <= 0) return delays.first;
    if (retryCount >= delays.length) return delays.last;
    return delays[retryCount - 1];
  }

  static DateTime nextRetryTime(int retryCount, {DateTime? from}) {
    final base = from ?? DateTime.now().toUtc();
    return base.add(delayForRetry(retryCount));
  }

  static bool exceededMaxRetries(int retryCount) => retryCount >= maxRetries;
}
