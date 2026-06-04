import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/features/splash/splash_navigation.dart';

/// Full-screen branded splash using the approved MyHealth artwork.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _minDisplay = Duration(milliseconds: 600);

  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _scheduleNavigation();
  }

  Future<void> _scheduleNavigation() async {
    final destinationFuture = SplashNavigation.resolveDestination(ref);

    await Future.wait<void>([
      Future<void>.delayed(_minDisplay),
      destinationFuture.then((_) {}),
    ]);

    if (!mounted || _navigating) return;
    _navigating = true;
    context.go(await destinationFuture);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        AppAssets.splashFullScreen,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
