import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/notifications/models/notification_model.dart';
import 'package:smarthealth_shep/features/notifications/providers/notification_providers.dart';

/// Sticky platform broadcast popup on the home dashboard until dismissed.
class HomeBroadcastBanner extends ConsumerStatefulWidget {
  const HomeBroadcastBanner({super.key});

  @override
  ConsumerState<HomeBroadcastBanner> createState() => _HomeBroadcastBannerState();
}

class _HomeBroadcastBannerState extends ConsumerState<HomeBroadcastBanner> {
  AppNotification? _banner;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(notificationRepositoryProvider);
    final banner = await repo.fetchDashboardBanner();
    if (mounted) {
      setState(() {
        _banner = banner;
        _loading = false;
      });
    }
  }

  Future<void> _dismiss() async {
    final banner = _banner;
    if (banner == null) return;
    await ref.read(notificationRepositoryProvider).dismissNotification(banner.id);
    ref.invalidate(unreadNotificationCountProvider);
    if (mounted) {
      setState(() => _banner = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _banner == null) return const SizedBox.shrink();

    final banner = _banner!;
    return Material(
      color: Colors.black54,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Material(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    banner.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: HomeDashboardColors.of(context).textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    banner.body,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: HomeDashboardColors.of(context).textSecondary,
                    ),
                  ),
                  SizedBox(height: 20),
                  FilledButton(
                    onPressed: _dismiss,
                    style: FilledButton.styleFrom(
                      backgroundColor: HomeDashboardColors.of(context).primary,
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
