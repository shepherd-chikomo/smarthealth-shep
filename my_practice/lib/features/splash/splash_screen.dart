import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/seed/seed_data_loader.dart';
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
    await SeedDataLoader(ref.read(appDatabaseProvider)).loadIfNeeded();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final auth = ref.read(authStateProvider);
    if (auth.status == AuthStatus.authenticated) {
      context.go('/dashboard');
    } else if (auth.status == AuthStatus.unauthenticated) {
      context.go('/login');
    } else {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      final updated = ref.read(authStateProvider);
      context.go(
        updated.status == AuthStatus.authenticated ? '/dashboard' : '/login',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          ],
        ),
      ),
    );
  }
}
