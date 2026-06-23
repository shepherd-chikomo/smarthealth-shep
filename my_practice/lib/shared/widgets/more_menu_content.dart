import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/feature_flags/feature_flags_notifier.dart';
import 'package:my_practice/core/theme/theme_mode_provider.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/shared/navigation/practice_nav_items.dart';
import 'package:my_practice/shared/widgets/facility_switcher_sheet.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

/// Shared More menu sections — used by the hamburger drawer and optional /more page.
class PracticeMoreMenuSections extends ConsumerWidget {
  const PracticeMoreMenuSections({
    super.key,
    this.onItemActivated,
    this.showProfileHeader = false,
    this.showDevPanels = true,
  });

  final VoidCallback? onItemActivated;
  final bool showProfileHeader;
  final bool showDevPanels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authStateProvider).profile;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showProfileHeader && profile != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: PracticeDesignTokens.previewCardDecoration(context),
            child: Row(
              children: [
                PracticeAvatar(
                  initials: _initials(profile.displayName),
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: PracticeDesignTokens.inter(weight: FontWeight.w600),
                      ),
                      Text(profile.role, style: PracticeDesignTokens.metadata(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        ...PracticeNavItems.moreSections
            .where((section) => _visibleItems(ref, section.items).isNotEmpty)
            .map((section) {
          final items = _visibleItems(ref, section.items);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section.title != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                  child: Text(
                    section.title!,
                    style: PracticeDesignTokens.tableHeader(context),
                  ),
                ),
              ],
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: PracticeDesignTokens.previewCardDecoration(context),
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) Divider(height: 1, color: context.appColors.border),
                      _MoreMenuTile(
                        entry: items[i],
                        isDark: isDark,
                        onItemActivated: onItemActivated,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        }),
        if (showDevPanels && MyPracticeConfig.skipAuthForTesting)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: PracticeDesignTokens.previewCardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Development Mode',
                    style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
                Text('Using seed data · API calls need pilot login',
                    style: PracticeDesignTokens.metadata(context)),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () {
                    onItemActivated?.call();
                    ref.read(authStateProvider.notifier).signOut();
                    context.go('/login');
                  },
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text('Sign in (pilot)'),
                ),
              ],
            ),
          ),
        if (showDevPanels && MyPracticeConfig.devMode && !MyPracticeConfig.skipAuthForTesting)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: PracticeDesignTokens.previewCardDecoration(context),
            child: Row(
              children: [
                Icon(Icons.developer_mode, color: context.appColors.mutedForeground),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Development Mode',
                          style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
                      Text('Using seed data',
                          style: PracticeDesignTokens.metadata(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  List<MoreMenuEntry> _visibleItems(WidgetRef ref, List<MoreMenuEntry> items) {
    return items
        .where(
          (e) => e.featureFlag == null || ref.featureEnabled(e.featureFlag!),
        )
        .toList();
  }
}

/// Optional full-page More hub (desktop deep link).
class MoreMenuContent extends ConsumerWidget {
  const MoreMenuContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('More', style: PracticeDesignTokens.pageTitle(context)),
        const SizedBox(height: 4),
        Text(
          'Practice settings, finance, and operations',
          style: PracticeDesignTokens.metadata(context),
        ),
        const SizedBox(height: 16),
        const PracticeMoreMenuSections(showProfileHeader: true),
      ],
    );
  }
}

class _MoreMenuTile extends ConsumerWidget {
  const _MoreMenuTile({
    required this.entry,
    required this.isDark,
    this.onItemActivated,
  });

  final MoreMenuEntry entry;
  final bool isDark;
  final VoidCallback? onItemActivated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entry.featureFlag != null && !ref.featureEnabled(entry.featureFlag!)) {
      return const SizedBox.shrink();
    }

    final icon = entry.action == MoreMenuActionType.appearance
        ? (isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined)
        : entry.icon;

    String? subtitle;
    if (entry.action == MoreMenuActionType.appearance) {
      subtitle = isDark ? 'Dark mode' : 'Light mode';
    } else if (entry.action == MoreMenuActionType.futureModule) {
      subtitle = 'Architecture preview';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _handleTap(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.label,
                    style: PracticeDesignTokens.inter(size: 14, weight: FontWeight.w500),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: PracticeDesignTokens.metadata(context),
                    ),
                ],
              ),
            ),
            if (entry.action == MoreMenuActionType.navigate ||
                entry.action == MoreMenuActionType.futureModule)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    onItemActivated?.call();
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
        if (context.mounted) context.go('/login');
      case MoreMenuActionType.futureModule:
        if (entry.futureModule != null) {
          context.push('/future/${entry.futureModule}');
        }
      case MoreMenuActionType.switchFacility:
        showFacilitySwitcherSheet(context, ref);
    }
  }
}
