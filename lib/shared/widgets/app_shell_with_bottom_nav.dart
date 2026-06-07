import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/shared/widgets/app_bottom_navigation_bar.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';

/// Overlay routes that should keep the main tab bar visible.
class AppShellWithBottomNav extends StatelessWidget {
  const AppShellWithBottomNav({
    super.key,
    required this.body,
    this.appBar,
    this.backgroundColor,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return AppShellScaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: mainTabIndexForLocation(location),
        onSelected: (index) => goToMainTab(context, index),
      ),
      body: body,
    );
  }
}
