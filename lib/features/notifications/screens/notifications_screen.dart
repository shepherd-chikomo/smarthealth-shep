import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/notifications/models/notification_model.dart';
import 'package:smarthealth_shep/features/notifications/providers/notification_providers.dart';
import 'package:smarthealth_shep/features/notifications/services/deep_link_handler.dart';
import 'package:smarthealth_shep/features/notifications/utils/notification_grouping.dart';
import 'package:smarthealth_shep/features/notifications/widgets/notification_card.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/empty_state.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late Future<List<AppNotification>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ref.read(notificationRepositoryProvider).listNotifications(limit: 50);
  }

  Future<void> _openNotification(AppNotification n) async {
    final repo = ref.read(notificationRepositoryProvider);
    if (n.isUnread) {
      await repo.markRead(n.id);
      ref.invalidate(unreadNotificationCountProvider);
      setState(_load);
    }
    if (!mounted) return;
    DeepLinkHandler.navigate(
      GoRouter.of(context),
      actionUrl: n.actionUrl,
      data: {'category': n.category.value, ...n.payload},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppShellScaffold(
      backgroundColor: HomeDashboardColors.background,
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        backgroundColor: HomeDashboardColors.background,
        actions: [
          IconButton(
            icon: const Icon(Symbols.done_all),
            tooltip: l10n.notificationsMarkAllRead,
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
              ref.invalidate(unreadNotificationCountProvider);
              setState(_load);
            },
          ),
          IconButton(
            icon: const Icon(Symbols.settings),
            tooltip: l10n.notificationsPreferences,
            onPressed: () => context.push('/notifications/preferences'),
          ),
        ],
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return EmptyState(
              title: l10n.notificationsErrorTitle,
              subtitle: snapshot.error.toString(),
              icon: Symbols.error_outline,
              useBundledIllustration: false,
              actionLabel: l10n.homeRetry,
              onAction: () => setState(_load),
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return EmptyState(
              title: l10n.notificationsEmptyTitle,
              subtitle: l10n.notificationsEmptyBody,
              icon: Symbols.notifications_off,
              useBundledIllustration: false,
            );
          }

          final groups = NotificationGrouping.byTime(items);

          return RefreshIndicator(
            color: HomeDashboardColors.primary,
            onRefresh: () async => setState(_load),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                for (final entry in groups.entries)
                  if (entry.value.isNotEmpty) ...[
                    _SectionHeader(label: _groupLabel(l10n, entry.key)),
                    ...entry.value.map(
                      (n) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: NotificationCard(
                          notification: n,
                          actionLabel: notificationActionLabel(n.category),
                          onTap: () => _openNotification(n),
                          onAction: () => _openNotification(n),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _groupLabel(AppLocalizations l10n, NotificationTimeGroup group) {
    return switch (group) {
      NotificationTimeGroup.today => l10n.notificationsGroupToday,
      NotificationTimeGroup.yesterday => l10n.notificationsGroupYesterday,
      NotificationTimeGroup.earlier => l10n.notificationsGroupEarlier,
    };
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: HomeDashboardColors.textSecondary,
        ),
      ),
    );
  }
}
