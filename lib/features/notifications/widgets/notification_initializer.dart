import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/notifications/firebase_init.dart';
import 'package:smarthealth_shep/features/notifications/providers/notification_providers.dart';

/// Initializes Firebase + push notifications after auth is available.
class NotificationInitializer extends ConsumerStatefulWidget {
  const NotificationInitializer({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<NotificationInitializer> createState() =>
      _NotificationInitializerState();
}

class _NotificationInitializerState extends ConsumerState<NotificationInitializer> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await initializeFirebase();
    if (!mounted) return;
    await ref.read(pushNotificationServiceProvider).initialize(
          router: widget.router,
        );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
