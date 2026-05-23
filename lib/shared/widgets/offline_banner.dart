import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/connectivity/connectivity_notifier.dart';
import 'package:smarthealth_shep/core/theme/app_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';

/// Thin persistent banner shown when connectivity is lost.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);
    if (isOnline) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: l10n.offlineBannerMessage,
      liveRegion: true,
      child: Material(
        color: isDark ? AppColors.offlineBannerDark : AppColors.offlineBanner,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              l10n.offlineBannerMessage,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isDark ? Colors.black87 : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
