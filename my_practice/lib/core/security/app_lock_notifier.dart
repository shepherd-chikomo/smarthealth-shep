import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/security/biometric_service.dart';

/// Tracks whether the app is currently locked (session timeout while backgrounded).
final appLockProvider = NotifierProvider<AppLockNotifier, bool>(AppLockNotifier.new);

class AppLockNotifier extends Notifier<bool> {
  @override
  bool build() => false; // starts unlocked

  /// Called when the user authenticates successfully via biometrics/pattern.
  void unlock() => state = false;

  /// Called by the lifecycle observer when the background timeout elapses.
  void lock() => state = true;

  Future<bool> authenticateAndUnlock() async {
    final ok = await BiometricService().authenticate(
      reason: 'Unlock MyPractice',
    );
    if (ok) unlock();
    return ok;
  }
}

/// Watches app lifecycle and locks the app after [sessionTimeoutMinutes] in background.
///
/// Pass [onLock] as a callback so this observer has no direct Riverpod dependency
/// (avoids the WidgetRef vs Ref mismatch in ConsumerState).
class AppLockLifecycleObserver extends WidgetsBindingObserver {
  AppLockLifecycleObserver({required this.onLock});

  final VoidCallback onLock;
  DateTime? _backgroundedAt;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _backgroundedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        final bg = _backgroundedAt;
        _backgroundedAt = null;
        if (bg == null) return;
        final elapsed = DateTime.now().difference(bg).inMinutes;
        if (elapsed >= MyPracticeConfig.sessionTimeoutMinutes) {
          onLock();
        }
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }
}
