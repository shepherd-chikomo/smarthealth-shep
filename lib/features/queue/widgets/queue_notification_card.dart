import 'package:flutter/material.dart';
import 'package:smarthealth_shep/features/notifications/models/notification_model.dart';
import 'package:smarthealth_shep/features/notifications/widgets/notification_card.dart';

/// Queue-specific inbox card — delegates to unified [NotificationCard].
class QueueNotificationCard extends StatelessWidget {
  const QueueNotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NotificationCard(
      notification: notification,
      actionLabel: notificationActionLabel(notification.category),
      onTap: onTap,
      onAction: onTap,
    );
  }
}
