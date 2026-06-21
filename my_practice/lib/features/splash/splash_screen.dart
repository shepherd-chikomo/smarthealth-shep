import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/seed/dev_team_seed.dart';
import 'package:my_practice/data/seed/seed_data_loader.dart';
import 'package:my_practice/data/sync/sync_notifier.dart';
import 'package:my_practice/design_system/widgets/practice_icon_widgets.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Never block boot on seed generation — it can take minutes on device.
    if (MyPracticeConfig.useLocalDevSeed) {
      final db = ref.read(appDatabaseProvider);
      await DevTeamSeed.ensure(db, DevTeamSeed.seedFacilityId);
      unawaited(SeedDataLoader(db).loadIfNeeded());
    }

    if (!MyPracticeConfig.skipAuthForTesting) {
      unawaited(ref.read(syncNotifierProvider.notifier).syncNow());
    }

    await _waitForAuthReady(const Duration(seconds: 5));
    if (!mounted) return;
    _navigateFromAuth(ref.read(authStateProvider));
  }

  Future<void> _waitForAuthReady(Duration timeout) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (!mounted) return;
      final auth = ref.read(authStateProvider);
      if (auth.status != AuthStatus.unknown) return;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  void _navigateFromAuth(AuthState auth) {
    switch (auth.status) {
      case AuthStatus.authenticated:
        context.go('/dashboard');
      case AuthStatus.needsFacility:
        context.go('/facility-picker');
      case AuthStatus.unauthenticated:
      case AuthStatus.unknown:
        context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PracticeBrandMark(size: 72),
            const SizedBox(height: 16),
            Text(
              'MyPractice',
              style: AppTextStyles.xxl(
                fontWeight: AppTextStyles.bold,
                color: Theme.of(context).colorScheme.primary,
                isHeading: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Powered by SmartHealth',
              style: AppTextStyles.sm(color: context.appColors.mutedForeground),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            if (MyPracticeConfig.devMode) ...[
              const SizedBox(height: 16),
              Text(
                'Preparing workspace…',
                style: AppTextStyles.sm(color: context.appColors.mutedForeground),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
