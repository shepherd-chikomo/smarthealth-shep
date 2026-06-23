import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/core/theme/theme_mode_provider.dart';
import 'package:my_practice/data/sync/sync_notifier.dart';
import 'package:my_practice/data/sync/sync_state.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_icon_widgets.dart';
import 'package:my_practice/shared/navigation/practice_nav_items.dart';
import 'package:my_practice/shared/widgets/facility_switcher_sheet.dart';
import 'package:my_practice/shared/widgets/more_menu_content.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

/// Responsive app chrome: sidebar (desktop), bottom nav (mobile), top bar, theme toggle.
class PracticeResponsiveShell extends ConsumerStatefulWidget {
  const PracticeResponsiveShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<PracticeResponsiveShell> createState() =>
      _PracticeResponsiveShellState();
}

class _PracticeResponsiveShellState extends ConsumerState<PracticeResponsiveShell> {
  bool _sidebarExpanded = true;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < PracticeNavItems.mobileBreakpoint;
    final auth = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = practiceIsDark(context, themeMode);
    final facilityName = auth.profile?.facilities
            .where((f) => f.id == ref.watch(facilityIdProvider))
            .map((f) => f.name)
            .firstOrNull ??
        auth.profile?.facilities.firstOrNull?.name ??
        'MyPractice Facility';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (!isMobile)
              _DesktopSidebar(
                expanded: _sidebarExpanded,
                selectedIndex: widget.navigationShell.currentIndex,
                onToggle: () =>
                    setState(() => _sidebarExpanded = !_sidebarExpanded),
                auth: auth,
                onNavigate: _go,
                onMoreNavigate: _handleMoreEntry,
              ),
            Expanded(
              child: Column(
                children: [
                  _PracticeTopBar(
                    searchController: _searchCtrl,
                    facilityName: facilityName,
                    practitionerName:
                        auth.profile?.displayName ?? 'Practitioner',
                    initials: _initials(auth),
                    isDark: isDark,
                    isMobile: isMobile,
                    onMenuTap:
                        isMobile ? () => _openDrawer(context) : null,
                    onFacilityTap: () => showFacilitySwitcherSheet(context, ref),
                    onThemeToggle: () =>
                        ref.read(themeModeProvider.notifier).toggleLightDark(),
                    syncState: ref.watch(syncNotifierProvider),
                    onSync: () =>
                        ref.read(syncNotifierProvider.notifier).syncNow(),
                  ),
                  Expanded(child: widget.navigationShell),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: widget.navigationShell.currentIndex.clamp(
                0,
                PracticeNavItems.mobileBottomTabs.length - 1,
              ),
              onDestinationSelected: (index) {
                final tab = PracticeNavItems.mobileBottomTabs[index];
                widget.navigationShell.goBranch(tab.shellIndex!);
              },
              destinations: [
                for (final tab in PracticeNavItems.mobileBottomTabs)
                  NavigationDestination(
                    icon: Icon(tab.icon, size: PracticeDesignTokens.iconLg),
                    selectedIcon: Icon(
                      _filledIcon(tab.icon),
                      size: PracticeDesignTokens.iconLg,
                    ),
                    label: tab.label.split(' ').first,
                  ),
              ],
            )
          : null,
    );
  }

  void _go(String route) {
    final tab = PracticeNavItems.mainShellTabs
        .where((t) => t.route == route)
        .cast<PracticeNavItem?>()
        .firstOrNull;
    if (tab?.shellIndex != null) {
      widget.navigationShell.goBranch(tab!.shellIndex!);
    } else {
      context.push(route);
    }
  }

  void _handleMoreEntry(MoreMenuEntry entry) {
    switch (entry.action) {
      case MoreMenuActionType.navigate:
        if (entry.route != null) context.push(entry.route!);
      case MoreMenuActionType.snackbar:
        if (entry.snackbar != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(entry.snackbar!)),
          );
        }
      case MoreMenuActionType.appearance:
        ref.read(themeModeProvider.notifier).toggleLightDark();
      case MoreMenuActionType.signOut:
        ref.read(authStateProvider.notifier).signOut();
      case MoreMenuActionType.signInPilot:
        ref.read(authStateProvider.notifier).signOut();
        context.go('/login');
      case MoreMenuActionType.futureModule:
        if (entry.futureModule != null) {
          context.push('/future/${entry.futureModule}');
        }
      case MoreMenuActionType.switchFacility:
        showFacilitySwitcherSheet(context, ref);
    }
  }

  IconData _filledIcon(IconData outlined) {
    return switch (outlined) {
      Icons.dashboard_outlined => Icons.dashboard,
      Icons.groups_outlined => Icons.groups,
      Icons.calendar_month_outlined => Icons.calendar_month,
      Icons.people_outline => Icons.people,
      _ => outlined,
    };
  }

  String _initials(AuthState auth) {
    final first = auth.profile?.firstName?.characters.firstOrNull ?? 'P';
    final last = auth.profile?.lastName?.characters.firstOrNull ?? 'R';
    return '$first$last'.toUpperCase();
  }

  void _openDrawer(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, controller) => Material(
          color: Theme.of(sheetContext).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('Menu',
                    style: PracticeDesignTokens.sectionTitle(sheetContext)),
              ),
              Consumer(
                builder: (context, ref, _) => PracticeMoreMenuSections(
                  showDevPanels: false,
                  onItemActivated: () => Navigator.pop(sheetContext),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.expanded,
    required this.selectedIndex,
    required this.onToggle,
    required this.auth,
    required this.onNavigate,
    required this.onMoreNavigate,
  });

  final bool expanded;
  final int selectedIndex;
  final VoidCallback onToggle;
  final AuthState auth;
  final void Function(String route) onNavigate;
  final void Function(MoreMenuEntry entry) onMoreNavigate;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final width = expanded
        ? PracticeDesignTokens.sidebarWidth
        : PracticeDesignTokens.sidebarCollapsedWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: width,
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: Column(
        children: [
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const PracticeBrandMark(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MyPractice',
                            style: PracticeDesignTokens.inter(
                              size: 16,
                              weight: FontWeight.w700,
                              color: colors.foreground,
                            )),
                        Text('Powered by SmartHealth',
                            style: PracticeDesignTokens.metadata(context)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: onToggle,
                  ),
                ],
              ),
            )
          else
            // Collapsed: show only the expand button so it's always reachable.
            SizedBox(
              height: 72,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: onToggle,
                  tooltip: 'Expand sidebar',
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (var i = 0; i < PracticeNavItems.mainShellTabs.length; i++)
                  _NavTile(
                    item: PracticeNavItems.mainShellTabs[i],
                    selected: i == selectedIndex,
                    expanded: expanded,
                    onTap: () =>
                        onNavigate(PracticeNavItems.mainShellTabs[i].route),
                  ),
                if (expanded) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'More',
                      style: PracticeDesignTokens.tableHeader(context),
                    ),
                  ),
                ],
                for (final section in PracticeNavItems.moreSections) ...[
                  if (expanded && section.title != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                      child: Text(
                        section.title!,
                        style: PracticeDesignTokens.metadata(context),
                      ),
                    ),
                  for (final entry in section.items)
                    if (entry.action != MoreMenuActionType.futureModule ||
                        entry.featureFlag == null)
                      _MoreNavTile(
                        entry: entry,
                        expanded: expanded,
                        onTap: () => onMoreNavigate(entry),
                      ),
                ],
              ],
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _ProfileFooter(auth: auth),
            ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final PracticeNavItem item;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? colors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 12 : 8,
              vertical: 10,
            ),
            child: Row(
              children: [
                Icon(item.icon,
                    size: PracticeDesignTokens.iconMd,
                    color: selected ? primary : colors.mutedForeground),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item.label,
                        style: PracticeDesignTokens.inter(
                          size: 13,
                          weight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? primary : colors.foreground,
                        )),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoreNavTile extends StatelessWidget {
  const _MoreNavTile({
    required this.entry,
    required this.expanded,
    required this.onTap,
  });

  final MoreMenuEntry entry;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 12 : 8,
              vertical: 8,
            ),
            child: Row(
              children: [
                Icon(
                  entry.icon,
                  size: PracticeDesignTokens.iconMd,
                  color: colors.mutedForeground,
                ),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.label,
                      style: PracticeDesignTokens.inter(
                        size: 12,
                        color: colors.foreground,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileFooter extends StatelessWidget {
  const _ProfileFooter({required this.auth});

  final AuthState auth;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final initials =
        '${auth.profile?.firstName?.characters.firstOrNull ?? 'P'}${auth.profile?.lastName?.characters.firstOrNull ?? 'R'}'
            .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.primarySoft,
            child: Text(initials,
                style: PracticeDesignTokens.inter(
                  weight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                )),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(auth.profile?.displayName ?? 'Practitioner',
                    style: PracticeDesignTokens.inter(
                      size: 13,
                      weight: FontWeight.w600,
                    )),
                Text(auth.profile?.role ?? 'doctor',
                    style: PracticeDesignTokens.metadata(context)),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: colors.success, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _PracticeTopBar extends StatelessWidget {
  const _PracticeTopBar({
    required this.searchController,
    required this.facilityName,
    required this.practitionerName,
    required this.initials,
    required this.isDark,
    required this.isMobile,
    required this.onThemeToggle,
    required this.syncState,
    required this.onSync,
    required this.onFacilityTap,
    this.onMenuTap,
  });

  final TextEditingController searchController;
  final String facilityName;
  final String practitionerName;
  final String initials;
  final bool isDark;
  final bool isMobile;
  final VoidCallback onThemeToggle;
  final SyncState syncState;
  final VoidCallback onSync;
  final VoidCallback onFacilityTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: PracticeDesignTokens.topBarHeight,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
      decoration: BoxDecoration(
        gradient: PracticeDesignTokens.headerGradient(context),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          if (onMenuTap != null)
            PracticeToolbarIconButton(
              icon: Icons.menu,
              tooltip: 'More',
              onPressed: onMenuTap,
            ),
          if (isMobile)
            Expanded(
              child: InkWell(
                onTap: onFacilityTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              facilityName,
                              style: PracticeDesignTokens.inter(
                                size: 13,
                                weight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.unfold_more,
                            size: 16,
                            color: colors.mutedForeground,
                          ),
                        ],
                      ),
                      Text(
                        practitionerName,
                        style: PracticeDesignTokens.metadata(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            InkWell(
              onTap: onFacilityTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        facilityName,
                        style: PracticeDesignTokens.inter(
                          size: 14,
                          weight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.unfold_more,
                      size: 18,
                      color: colors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
          if (!isMobile)
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search patients, claims, encounters…',
                  prefixIcon: Icon(
                    Icons.search,
                    size: PracticeDesignTokens.iconMd,
                    color: colors.mutedForeground,
                  ),
                  filled: true,
                  fillColor: colors.muted.withValues(alpha: 0.55),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  isDense: true,
                ),
                onSubmitted: (q) {
                  if (q.trim().isNotEmpty) context.go('/patients');
                },
              ),
            ),
          PracticeToolbarIconButton(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            tooltip: 'Toggle theme',
            onPressed: onThemeToggle,
          ),
          syncState.isSyncing
              ? SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: SizedBox(
                      width: PracticeDesignTokens.iconLg,
                      height: PracticeDesignTokens.iconLg,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.mutedForeground,
                      ),
                    ),
                  ),
                )
              : PracticeToolbarIconButton(
                  icon: _syncIcon(syncState),
                  onPressed: onSync,
                  color: syncState.phase == SyncPhase.error
                      ? colors.emergency
                      : null,
                ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              PracticeToolbarIconButton(
                icon: Icons.notifications_outlined,
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.emergency,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.primarySoft,
            child: Text(initials,
                style: PracticeDesignTokens.inter(
                  size: 12,
                  weight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                )),
          ),
        ],
      ),
    );
  }

  IconData _syncIcon(SyncState sync) {
    return switch (sync.phase) {
      SyncPhase.offline => Icons.cloud_off,
      SyncPhase.error => Icons.sync_problem,
      _ => Icons.sync,
    };
  }
}
