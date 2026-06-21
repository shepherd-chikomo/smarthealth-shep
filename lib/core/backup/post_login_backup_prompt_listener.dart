import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/auth/auth_state.dart';
import 'package:smarthealth_shep/core/backup/backup_restore_offer_provider.dart';
import 'package:smarthealth_shep/core/router/app_router.dart';

/// Redirects to the restore screen when a local backup should be offered.
class PostLoginBackupPromptListener extends ConsumerStatefulWidget {
  const PostLoginBackupPromptListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PostLoginBackupPromptListener> createState() =>
      _PostLoginBackupPromptListenerState();
}

class _PostLoginBackupPromptListenerState
    extends ConsumerState<PostLoginBackupPromptListener>
    with WidgetsBindingObserver {
  var _promptedThisAuthSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ref.read(authControllerProvider).isAuthenticated) {
      ref.invalidate(backupRestoreOfferProvider);
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        _promptedThisAuthSession = false;
        ref.invalidate(backupRestoreOfferProvider);
        WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
      }
    });

    ref.listen(backupRestoreOfferProvider, (previous, next) {
      next.whenData((shouldOffer) {
        if (shouldOffer) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
        }
      });
    });

    return widget.child;
  }

  bool _isExcludedRoute(String location) {
    return location.contains('/profile/backup') ||
        location.startsWith('/login') ||
        location.startsWith('/otp') ||
        location == '/' ||
        location == '/onboarding';
  }

  Future<void> _maybePrompt() async {
    if (_promptedThisAuthSession) return;

    final auth = ref.read(authControllerProvider);
    if (!auth.isAuthenticated || auth.isLoading) return;

    final location = ref.read(routerProvider).state.uri.toString();
    if (_isExcludedRoute(location)) return;

    final shouldOffer = await ref.read(backupRestoreOfferProvider.future);
    if (!shouldOffer) return;

    _promptedThisAuthSession = true;
    ref.read(routerProvider).go('/profile/backup?discovered=true');
  }
}
