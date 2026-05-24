import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/core/auth/auth_state.dart';
import 'package:smarthealth_shep/core/auth/secure_storage.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/onboarding/onboarding_screen.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final results = await Future.wait([
      SharedPreferences.getInstance(),
      SecureStorage().hasSession(),
      Future<void>.delayed(const Duration(milliseconds: 300)),
    ]);

    final prefs = results[0] as SharedPreferences;
    final hasSession = results[1] as bool;
    final completed = prefs.getBool(OnboardingScreen.completedKey) ?? false;

    if (!mounted) return;

    if (!completed) {
      context.go('/onboarding');
      return;
    }

    if (AppConfig.skipAuthForTesting) {
      await ref.read(authControllerProvider.notifier).refresh();
      if (!mounted) return;
      context.go('/home');
      return;
    }

    if (hasSession) {
      await ref.read(authControllerProvider.notifier).refresh();
      if (!mounted) return;
      context.go('/home');
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: HomeDashboardColors.primary,
      body: Center(
        child: Semantics(
          label: l10n.splashLoading,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.splashLogo,
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.appTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 12),
              Text(
                l10n.splashLoading,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
