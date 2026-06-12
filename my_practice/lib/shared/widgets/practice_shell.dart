import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class PracticeShell extends StatelessWidget {
  const PracticeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Symbols.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(icon: Icon(Symbols.groups), label: 'Queue'),
          NavigationDestination(
            icon: Icon(Symbols.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(icon: Icon(Symbols.person_search), label: 'Patients'),
          NavigationDestination(icon: Icon(Symbols.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
