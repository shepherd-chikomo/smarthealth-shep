import 'package:smarthealth_shep/features/notifications/models/notification_model.dart';

enum NotificationTimeGroup { today, yesterday, earlier }

/// Groups notifications by relative time for the inbox.
abstract final class NotificationGrouping {
  static Map<NotificationTimeGroup, List<AppNotification>> byTime(
    List<AppNotification> notifications,
  ) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    final sorted = List<AppNotification>.from(notifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final groups = {
      NotificationTimeGroup.today: <AppNotification>[],
      NotificationTimeGroup.yesterday: <AppNotification>[],
      NotificationTimeGroup.earlier: <AppNotification>[],
    };

    for (final notification in sorted) {
      if (!notification.createdAt.isBefore(todayStart)) {
        groups[NotificationTimeGroup.today]!.add(notification);
      } else if (!notification.createdAt.isBefore(yesterdayStart)) {
        groups[NotificationTimeGroup.yesterday]!.add(notification);
      } else {
        groups[NotificationTimeGroup.earlier]!.add(notification);
      }
    }

    return groups;
  }
}
