import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/offline_banner.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = navigationShell.currentIndex;

    return Column(
      children: [
        const OfflineBanner(),
        Expanded(
          child: AppShellBody(child: navigationShell),
        ),
        _BottomNavBar(
          selectedIndex: selected,
          onSelected: navigationShell.goBranch,
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
                    return const Expanded(child: SizedBox());
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
                                ? HomeDashboardColors.primary
                                : HomeDashboardColors.textSecondary,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected
                                  ? HomeDashboardColors.primary
                                  : HomeDashboardColors.textSecondary,
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
          color: HomeDashboardColors.emergency,
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
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? HomeDashboardColors.emergency
                : HomeDashboardColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
