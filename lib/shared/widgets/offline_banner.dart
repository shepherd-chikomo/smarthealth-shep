import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/connectivity/connectivity_notifier.dart';
import 'package:smarthealth_shep/core/theme/app_colors.dart';
import 'package:smarthealth_shep/core/theme/app_text_styles.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';

/// Thin persistent banner shown when connectivity is lost.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);
    if (isOnline) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final tokens = context.appColors;

    return Semantics(
      label: l10n.offlineBannerMessage,
      liveRegion: true,
      child: Material(
        color: tokens.warning,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              l10n.offlineBannerMessage,
              style: AppTextStyles.sm(
                fontWeight: AppTextStyles.semibold,
                color: AppColorsLight.foreground,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
