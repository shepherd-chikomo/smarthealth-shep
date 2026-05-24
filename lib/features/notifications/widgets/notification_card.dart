import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/notifications/models/notification_model.dart';
import 'package:smarthealth_shep/features/notifications/utils/notification_timestamp.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/design_system_tokens.dart';

/// Unified inbox card for all notification types.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.actionLabel,
    this.onTap,
    this.onAction,
  });

  final AppNotification notification;
  final String actionLabel;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(notification);
    final ticket = notification.payload['ticketNumber'];

    return Semantics(
      button: onTap != null,
      label: notification.title,
      child: Material(
        color: HomeDashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E8EE)),
              color: notification.isUnread
                  ? style.accent.withValues(alpha: 0.04)
                  : HomeDashboardColors.surface,
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: HomeDashboardColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: style.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: style.accent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(style.icon, size: 20, color: style.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notification.isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: HomeDashboardColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            NotificationTimestamp.format(notification.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: HomeDashboardColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.groupLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: style.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: HomeDashboardColors.textSecondary,
                        ),
                      ),
                      if (ticket != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: DesignSystemColors.primary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#$ticket',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: HomeDashboardColors.primary,
                            ),
                          ),
                        ),
                      ],
                      if (onAction != null) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: onAction,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: HomeDashboardColors.primary,
                            ),
                            child: Text(
                              actionLabel,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _NotificationStyle _styleFor(AppNotification notification) {
    if (notification.category == NotificationCategory.queueUpdate) {
      return switch (notification.queueEvent) {
        'youre_next' => _NotificationStyle(
            icon: Symbols.notifications_active,
            accent: DesignSystemColors.success,
          ),
        'delayed' => _NotificationStyle(
            icon: Symbols.schedule,
            accent: DesignSystemColors.warning,
          ),
        'paused' => _NotificationStyle(
            icon: Symbols.pause_circle,
            accent: DesignSystemColors.pending,
          ),
        _ => _NotificationStyle(
            icon: Symbols.groups,
            accent: DesignSystemColors.primary,
          ),
      };
    }

    return switch (notification.category) {
      NotificationCategory.appointmentReminder ||
      NotificationCategory.appointmentConfirmed ||
      NotificationCategory.appointmentRescheduled =>
        _NotificationStyle(
          icon: Symbols.event,
          accent: HomeDashboardColors.primary,
        ),
      NotificationCategory.appointmentCancellation => _NotificationStyle(
          icon: Symbols.event_busy,
          accent: DesignSystemColors.warning,
        ),
      NotificationCategory.emergencyAlert => _NotificationStyle(
          icon: Symbols.emergency,
          accent: HomeDashboardColors.emergency,
        ),
      NotificationCategory.verificationUpdate => _NotificationStyle(
          icon: Symbols.verified,
          accent: DesignSystemColors.secondary,
        ),
      NotificationCategory.claimApproval => _NotificationStyle(
          icon: Symbols.approval,
          accent: DesignSystemColors.secondary,
        ),
      NotificationCategory.providerMessage => _NotificationStyle(
          icon: Symbols.medical_services,
          accent: HomeDashboardColors.primary,
        ),
      NotificationCategory.facilityAnnouncement => _NotificationStyle(
          icon: Symbols.campaign,
          accent: DesignSystemColors.pending,
        ),
      NotificationCategory.general => _NotificationStyle(
          icon: Symbols.notifications,
          accent: HomeDashboardColors.textSecondary,
        ),
      NotificationCategory.queueUpdate => _NotificationStyle(
          icon: Symbols.groups,
          accent: DesignSystemColors.primary,
        ),
    };
  }
}

class _NotificationStyle {
  const _NotificationStyle({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;
}

/// Resolves primary action label per notification category.
String notificationActionLabel(NotificationCategory category) {
  return switch (category) {
    NotificationCategory.appointmentReminder ||
    NotificationCategory.appointmentConfirmed ||
    NotificationCategory.appointmentRescheduled ||
    NotificationCategory.appointmentCancellation =>
      'View appointment',
    NotificationCategory.queueUpdate => 'View queue',
    NotificationCategory.emergencyAlert => 'Open emergency',
    NotificationCategory.verificationUpdate => 'View provider',
    NotificationCategory.claimApproval => 'View details',
    NotificationCategory.providerMessage => 'View message',
    NotificationCategory.facilityAnnouncement => 'Learn more',
    NotificationCategory.general => 'View',
  };
}
