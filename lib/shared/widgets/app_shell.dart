import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/shared/widgets/app_bottom_navigation_bar.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/offline_banner.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selected = mainTabIndexForLocation(location);

    return Column(
      children: [
        const OfflineBanner(),
        Expanded(
          child: AppShellBody(child: navigationShell),
        ),
        AppBottomNavigationBar(
          selectedIndex: selected,
          onSelected: (index) => goToMainTab(context, index),
        ),
      ],
    );
  }
}
