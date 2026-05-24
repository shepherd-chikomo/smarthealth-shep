import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/notifications/providers/notification_providers.dart';

/// Home header bell with unread badge.
class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(unreadNotificationCountProvider);
    final unread = unreadAsync.maybeWhen(data: (c) => c, orElse: () => 0);

    return Semantics(
      button: true,
      label: unread > 0 ? 'Notifications, $unread unread' : 'Notifications',
      child: Material(
        color: HomeDashboardColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => context.push('/notifications'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E8EE)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Symbols.notifications,
                  color: HomeDashboardColors.textPrimary,
                  size: 22,
                ),
                if (unread > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: HomeDashboardColors.emergency,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
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
