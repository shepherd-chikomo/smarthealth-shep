import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/notifications/providers/notification_providers.dart';

/// Home header bell with unread badge.
class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key, this.headerStyle = false});

  final bool headerStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(unreadNotificationCountProvider);
    final unread = unreadAsync.maybeWhen(data: (c) => c, orElse: () => 0);

    final iconColor =
        headerStyle ? Colors.white : HomeDashboardColors.textPrimary;
    final backgroundColor =
        headerStyle ? Colors.white.withValues(alpha: 0.18) : HomeDashboardColors.surface;
    final borderColor = headerStyle
        ? Colors.white.withValues(alpha: 0.35)
        : const Color(0xFFE5E8EE);

    return Semantics(
      button: true,
      label: unread > 0 ? 'Notifications, $unread unread' : 'Notifications',
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => context.push('/notifications'),
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Symbols.notifications,
                  color: iconColor,
                  size: 22,
                ),
                if (unread > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: HomeDashboardColors.emergency,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
