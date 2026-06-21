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
                        isMobile ? () => _openDrawer(context, auth) : null,
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
              selectedIndex: widget.navigationShell.currentIndex.clamp(0, 3),
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
    final tab = PracticeNavItems.shellTabs
        .where((t) => t.route == route)
        .cast<PracticeNavItem?>()
        .firstOrNull;
    if (tab?.shellIndex != null) {
      widget.navigationShell.goBranch(tab!.shellIndex!);
    } else {
      context.push(route);
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

  void _openDrawer(BuildContext context, AuthState auth) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        builder: (_, controller) => Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('Menu',
                    style: PracticeDesignTokens.sectionTitle(context)),
              ),
              for (final tab in PracticeNavItems.shellTabs)
                ListTile(
                  leading: PracticeNavIcon(icon: tab.icon, selected: false),
                  title: Text(tab.label),
                  onTap: () {
                    Navigator.pop(context);
                    _go(tab.route);
                  },
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
  });

  final bool expanded;
  final int selectedIndex;
  final VoidCallback onToggle;
  final AuthState auth;
  final void Function(String route) onNavigate;

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
          Padding(
            padding: EdgeInsets.all(expanded ? 20 : 12),
            child: Row(
              children: [
                const PracticeBrandMark(),
                if (expanded) ...[
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
                    icon: Icon(
                      expanded ? Icons.chevron_left : Icons.chevron_right,
                      size: 20,
                    ),
                    onPressed: onToggle,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (var i = 0; i < PracticeNavItems.shellTabs.length; i++)
                  _NavTile(
                    item: PracticeNavItems.shellTabs[i],
                    selected: i == selectedIndex,
                    expanded: expanded,
                    onTap: () => onNavigate(PracticeNavItems.shellTabs[i].route),
                  ),
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
          Expanded(
            child: isMobile
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(facilityName,
                          style: PracticeDesignTokens.inter(
                            size: 13,
                            weight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis),
                      Text(practitionerName,
                          style: PracticeDesignTokens.metadata(context),
                          overflow: TextOverflow.ellipsis),
                    ],
                  )
                : TextField(
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
