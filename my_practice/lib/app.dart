import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/router/app_router.dart';
import 'package:my_practice/core/security/app_lock_notifier.dart';
import 'package:my_practice/core/theme/theme_mode_provider.dart';
import 'package:my_practice/design_system/theme/practice_app_theme.dart';

class MyPracticeApp extends ConsumerStatefulWidget {
  const MyPracticeApp({super.key});

  @override
  ConsumerState<MyPracticeApp> createState() => _MyPracticeAppState();
}

class _MyPracticeAppState extends ConsumerState<MyPracticeApp> {
  late final AppLockLifecycleObserver _lockObserver;

  @override
  void initState() {
    super.initState();
    _lockObserver = AppLockLifecycleObserver(
      onLock: () => ref.read(appLockProvider.notifier).lock(),
    );
    WidgetsBinding.instance.addObserver(_lockObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lockObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'MyPractice',
      theme: PracticeAppTheme.light,
      darkTheme: PracticeAppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
