import 'package:flutter/material.dart';

class PracticeNavItem {
  const PracticeNavItem({
    required this.label,
    required this.icon,
    required this.route,
    this.shellIndex,
  });

  final String label;
  final IconData icon;
  final String route;
  final int? shellIndex;
}

abstract final class PracticeNavItems {
  static const mobileBreakpoint = 768.0;

  static const shellTabs = [
    PracticeNavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      route: '/dashboard',
      shellIndex: 0,
    ),
    PracticeNavItem(
      label: 'Queue',
      icon: Icons.groups_outlined,
      route: '/queue',
      shellIndex: 1,
    ),
    PracticeNavItem(
      label: 'Calendar',
      icon: Icons.calendar_month_outlined,
      route: '/calendar',
      shellIndex: 2,
    ),
    PracticeNavItem(
      label: 'Patients',
      icon: Icons.people_outline,
      route: '/patients',
      shellIndex: 3,
    ),
    PracticeNavItem(
      label: 'More',
      icon: Icons.more_horiz,
      route: '/more',
      shellIndex: 4,
    ),
  ];

  static const desktopExtras = [
    PracticeNavItem(
      label: 'Claims & Medical Aid',
      icon: Icons.shield_outlined,
      route: '/claims',
    ),
    PracticeNavItem(
      label: 'Reports',
      icon: Icons.bar_chart_outlined,
      route: '/reports',
    ),
    PracticeNavItem(
      label: 'Messages',
      icon: Icons.chat_bubble_outline,
      route: '/messages',
    ),
  ];

  static String titleForIndex(int index) {
    if (index < 0 || index >= shellTabs.length) return 'MyPractice';
    return shellTabs[index].label;
  }
}
