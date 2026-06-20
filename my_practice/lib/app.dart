import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/theme/theme_mode_provider.dart';
import 'package:my_practice/design_system/theme/practice_app_theme.dart';
import 'package:my_practice/core/router/app_router.dart';

class MyPracticeApp extends ConsumerWidget {
  const MyPracticeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
