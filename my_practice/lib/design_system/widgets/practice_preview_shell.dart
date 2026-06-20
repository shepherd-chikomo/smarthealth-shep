import 'package:flutter/material.dart';
import 'package:my_practice/design_system/data/preview_seed_data.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_icon_widgets.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

/// Shared chrome for all design previews — sidebar + top bar + content.
class PracticePreviewShell extends StatefulWidget {
  const PracticePreviewShell({
    super.key,
    required this.child,
    this.selectedNavIndex = 0,
    this.title,
    this.subtitle,
    this.actions,
    this.showSidebar = true,
  });

  final Widget child;
  final int selectedNavIndex;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showSidebar;

  @override
  State<PracticePreviewShell> createState() => _PracticePreviewShellState();
}

class _PracticePreviewShellState extends State<PracticePreviewShell> {
  bool _sidebarExpanded = true;
  bool _isDark = true;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Builder(
        builder: (context) {
          final width = MediaQuery.sizeOf(context).width;
          final isMobile = width < 768;
          final sidebarWidth = isMobile
              ? 0.0
              : (_sidebarExpanded
                  ? PracticeDesignTokens.sidebarWidth
                  : PracticeDesignTokens.sidebarCollapsedWidth);

          return Material(
            color: context.appColors.background,
            child: Row(
              children: [
                if (widget.showSidebar && !isMobile)
                  _PreviewSidebar(
                    expanded: _sidebarExpanded,
                    selectedIndex: widget.selectedNavIndex,
                    onToggle: () =>
                        setState(() => _sidebarExpanded = !_sidebarExpanded),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      _PreviewTopBar(
                        title: widget.title,
                        subtitle: widget.subtitle,
                        actions: widget.actions,
                        isDark: _isDark,
                        onThemeToggle: () => setState(() => _isDark = !_isDark),
                        onMenuTap: isMobile
                            ? () => _openMobileDrawer(context)
                            : null,
                      ),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openMobileDrawer(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(16),
            children: PreviewSeedData.navItems
                .map(
                  (item) => ListTile(
                    leading: Icon(item.$2),
                    title: Text(item.$1),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _PreviewSidebar extends StatelessWidget {
  const _PreviewSidebar({
    required this.expanded,
    required this.selectedIndex,
    required this.onToggle,
  });

  final bool expanded;
  final int selectedIndex;
  final VoidCallback onToggle;

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
                    icon: const Icon(Icons.close, size: 20),
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
                for (var i = 0; i < PreviewSeedData.navItems.length; i++)
                  _NavTile(
                    label: PreviewSeedData.navItems[i].$1,
                    icon: PreviewSeedData.navItems[i].$2,
                    selected: i == selectedIndex,
                    expanded: expanded,
                  ),
                if (expanded) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('SmartHealth Network',
                        style: PracticeDesignTokens.tableHeader(context)),
                  ),
                  for (final m in PreviewSeedData.futureModules)
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.construction_outlined,
                          size: 20, color: colors.mutedForeground),
                      title: Text(m.$1,
                          style: PracticeDesignTokens.inter(size: 13)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.primarySoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('SOON',
                            style: PracticeDesignTokens.inter(
                              size: 10,
                              weight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            )),
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: PracticeDesignTokens.previewCardDecoration(context),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colors.primarySoft,
                      child: Text(PreviewSeedData.practitionerInitials,
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
                          Text(PreviewSeedData.practitionerName,
                              style: PracticeDesignTokens.inter(
                                size: 13,
                                weight: FontWeight.w600,
                              )),
                          Text(PreviewSeedData.practitionerTitle,
                              style: PracticeDesignTokens.metadata(context)),
                        ],
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.expanded,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool expanded;

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
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 12 : 8,
              vertical: 10,
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: PracticeDesignTokens.iconMd,
                    color: selected ? primary : colors.mutedForeground),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(label,
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

class _PreviewTopBar extends StatelessWidget {
  const _PreviewTopBar({
    this.title,
    this.subtitle,
    this.actions,
    required this.isDark,
    required this.onThemeToggle,
    this.onMenuTap,
  });

  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool isDark;
  final VoidCallback onThemeToggle;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: PracticeDesignTokens.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: PracticeDesignTokens.headerGradient(context),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          if (onMenuTap != null)
            PracticeToolbarIconButton(icon: Icons.menu, onPressed: onMenuTap),
          Expanded(
            child: title != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title!, style: PracticeDesignTokens.sectionTitle(context)),
                      if (subtitle != null)
                        Text(subtitle!, style: PracticeDesignTokens.metadata(context)),
                    ],
                  )
                : TextField(
                    decoration: InputDecoration(
                      hintText: 'Search patients, claims, encounters…',
                      prefixIcon: Icon(
                        Icons.search,
                        size: PracticeDesignTokens.iconMd,
                        color: colors.mutedForeground,
                      ),
                      filled: true,
                      fillColor: colors.muted.withValues(alpha: 0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      isDense: true,
                    ),
                  ),
          ),
          if (title == null) ...[
            const SizedBox(width: 12),
            Text(PreviewSeedData.facilityName,
                style: PracticeDesignTokens.metadata(context)),
          ],
          const SizedBox(width: 8),
          PracticeToolbarIconButton(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            tooltip: 'Theme',
            onPressed: onThemeToggle,
          ),
          PracticeToolbarIconButton(
            icon: Icons.sync,
            tooltip: 'Synced 2 min ago',
            onPressed: () {},
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
            child: Text(PreviewSeedData.practitionerInitials,
                style: PracticeDesignTokens.inter(
                  size: 12,
                  weight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                )),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
