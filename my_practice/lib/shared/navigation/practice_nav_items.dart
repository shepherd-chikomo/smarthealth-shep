import 'package:flutter/material.dart';
import 'package:my_practice/core/config/my_practice_config.dart';

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

enum MoreMenuActionType {
  navigate,
  snackbar,
  appearance,
  signOut,
  signInPilot,
  futureModule,
}

class MoreMenuEntry {
  const MoreMenuEntry({
    required this.label,
    required this.icon,
    required this.action,
    this.route,
    this.featureFlag,
    this.snackbar,
    this.futureModule,
  });

  final String label;
  final IconData icon;
  final MoreMenuActionType action;
  final String? route;
  final String? featureFlag;
  final String? snackbar;
  final String? futureModule;
}

class MoreMenuSection {
  const MoreMenuSection({this.title, required this.items});

  final String? title;
  final List<MoreMenuEntry> items;
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

  /// Bottom nav on mobile — More is reached via the top-left menu or More tab in drawer.
  static List<PracticeNavItem> get mobileBottomTabs =>
      shellTabs.where((t) => t.shellIndex != null && t.shellIndex! < 4).toList();

  /// Single source of truth for everything under the More page.
  static const moreSections = [
    MoreMenuSection(
      title: 'Operations',
      items: [
        MoreMenuEntry(
          label: 'Facility Management',
          icon: Icons.local_hospital_outlined,
          action: MoreMenuActionType.navigate,
          route: '/facility/manage',
        ),
        MoreMenuEntry(
          label: 'Team Management',
          icon: Icons.group_outlined,
          action: MoreMenuActionType.navigate,
          route: '/facility/team',
        ),
        MoreMenuEntry(
          label: 'Provider Schedule',
          icon: Icons.schedule_outlined,
          action: MoreMenuActionType.navigate,
          route: '/calendar/availability',
        ),
        MoreMenuEntry(
          label: 'Claim Facility',
          icon: Icons.verified_user_outlined,
          action: MoreMenuActionType.navigate,
          route: '/claim',
        ),
      ],
    ),
    MoreMenuSection(
      title: 'Finance & Reporting',
      items: [
        MoreMenuEntry(
          label: 'Claims & Medical Aid',
          icon: Icons.shield_outlined,
          action: MoreMenuActionType.navigate,
          route: '/claims',
        ),
        MoreMenuEntry(
          label: 'Practitioner Earnings',
          icon: Icons.payments_outlined,
          action: MoreMenuActionType.navigate,
          route: '/earnings',
        ),
        MoreMenuEntry(
          label: 'Accounts Receivable',
          icon: Icons.account_balance_wallet_outlined,
          action: MoreMenuActionType.navigate,
          route: '/receivables',
        ),
        MoreMenuEntry(
          label: 'Reports & Analytics',
          icon: Icons.bar_chart_outlined,
          action: MoreMenuActionType.navigate,
          route: '/reports',
        ),
      ],
    ),
    MoreMenuSection(
      title: 'Clinical',
      items: [
        MoreMenuEntry(
          label: 'Clinical Tasks',
          icon: Icons.task_alt_outlined,
          action: MoreMenuActionType.navigate,
          route: '/tasks',
        ),
        MoreMenuEntry(
          label: 'Credential Wallet',
          icon: Icons.badge_outlined,
          action: MoreMenuActionType.navigate,
          route: '/credentials',
        ),
      ],
    ),
    MoreMenuSection(
      title: 'Communication',
      items: [
        MoreMenuEntry(
          label: 'Internal Messaging',
          icon: Icons.chat_bubble_outline,
          action: MoreMenuActionType.navigate,
          route: '/messages',
        ),
      ],
    ),
    MoreMenuSection(
      title: 'Settings',
      items: [
        MoreMenuEntry(
          label: 'Appearance',
          icon: Icons.dark_mode_outlined,
          action: MoreMenuActionType.appearance,
        ),
        MoreMenuEntry(
          label: 'Sign out',
          icon: Icons.logout,
          action: MoreMenuActionType.signOut,
        ),
      ],
    ),
    MoreMenuSection(
      title: 'Coming soon',
      items: [
        MoreMenuEntry(
          label: 'SmartHealth Connect',
          icon: Icons.construction,
          action: MoreMenuActionType.futureModule,
          futureModule: 'connect',
          featureFlag: FeatureFlagKeys.connect,
        ),
        MoreMenuEntry(
          label: 'SmartHealth Switch',
          icon: Icons.construction,
          action: MoreMenuActionType.futureModule,
          futureModule: 'switch',
          featureFlag: FeatureFlagKeys.switchModule,
        ),
        MoreMenuEntry(
          label: 'SmartHealth Insights',
          icon: Icons.construction,
          action: MoreMenuActionType.futureModule,
          futureModule: 'insights',
          featureFlag: FeatureFlagKeys.insights,
        ),
      ],
    ),
  ];

  static String titleForIndex(int index) {
    if (index < 0 || index >= shellTabs.length) return 'MyPractice';
    return shellTabs[index].label;
  }
}
