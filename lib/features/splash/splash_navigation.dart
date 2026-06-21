import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth_shep/core/auth/auth_state.dart';
import 'package:smarthealth_shep/core/auth/secure_storage.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/features/onboarding/onboarding_screen.dart';

/// Resolves post-splash route and performs a fade-style handoff via [GoRouter].
abstract final class SplashNavigation {
  static Future<String> resolveDestination(WidgetRef ref) async {
    final results = await Future.wait([
      SharedPreferences.getInstance(),
      SecureStorage().hasSession(),
    ]);

    final prefs = results[0] as SharedPreferences;
    final hasSession = results[1] as bool;
    final completed = prefs.getBool(OnboardingScreen.completedKey) ?? false;

    if (!completed) return '/onboarding';

    if (AppConfig.skipAuthForTesting) {
      await ref.read(authControllerProvider.notifier).refresh();
      return '/home';
    }

    if (hasSession) {
      await ref.read(authControllerProvider.notifier).refresh();
      return '/home';
    }

    return '/login';
  }
}
