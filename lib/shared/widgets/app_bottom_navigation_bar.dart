import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';

/// Main tab destinations aligned with [StatefulShellRoute] branch order.
const mainTabRoutes = [
  '/home',
  '/search',
  '/emergency',
  '/bookings',
  '/profile',
];

void goToMainTab(BuildContext context, int index) {
  if (index < 0 || index >= mainTabRoutes.length) return;
  context.go(mainTabRoutes[index]);
}

/// Resolves the bottom-nav highlight from the active route (handles nested tab routes).
int mainTabIndexForLocation(String location) {
  if (location.startsWith('/profile')) return 4;
  if (location.startsWith('/bookings') || location.startsWith('/appointments')) {
    return 3;
  }
  if (location.startsWith('/emergency')) return 2;
  if (location.startsWith('/search')) return 1;
  return 0;
}

/// Bottom navigation bar shared by [AppShell] and overlay routes (e.g. facility detail).
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _BottomNavBar(
      selectedIndex: selectedIndex,
      onSelected: onSelected,
      items: [
        _NavItem(
          icon: Symbols.home,
          outlinedIcon: Symbols.home,
          label: l10n.navHome,
        ),
        _NavItem(
          icon: Symbols.search,
          outlinedIcon: Symbols.search,
          label: l10n.navSearch,
        ),
        _NavItem(
          icon: Symbols.emergency,
          outlinedIcon: Symbols.emergency,
          label: l10n.navEmergency,
          isEmergency: true,
        ),
        _NavItem(
          icon: Symbols.calendar_month,
          outlinedIcon: Symbols.calendar_month,
          label: l10n.navBookings,
        ),
        _NavItem(
          icon: Symbols.person,
          outlinedIcon: Symbols.person,
          label: l10n.navProfile,
        ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    this.isEmergency = false,
  });

  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final bool isEmergency;
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.items,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SizedBox(
        height: 78,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 64,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E8EE)),
                ),
              ),
              child: Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  if (item.isEmergency) {
                    return Expanded(child: SizedBox());
                  }
                  final selected = selectedIndex == index;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onSelected(index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.outlinedIcon,
                            size: 24,
                            color: selected
                                ? HomeDashboardColors.of(context).primary
                                : HomeDashboardColors.of(context).textSecondary,
                          ),
                          SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected
                                  ? HomeDashboardColors.of(context).primary
                                  : HomeDashboardColors.of(context).textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              top: 0,
              child: _EmergencyNavButton(
                selected: selectedIndex == 2,
                label: items[2].label,
                onTap: () => onSelected(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyNavButton extends StatelessWidget {
  const _EmergencyNavButton({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          elevation: 4,
          color: HomeDashboardColors.of(context).emergency,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                Symbols.emergency,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? HomeDashboardColors.of(context).emergency
                : HomeDashboardColors.of(context).textSecondary,
          ),
        ),
      ],
    );
  }
}
