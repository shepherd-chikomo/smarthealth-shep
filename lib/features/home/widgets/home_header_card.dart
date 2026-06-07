import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/home/providers/home_medical_summary_provider.dart';
import 'package:smarthealth_shep/features/home/widgets/home_medical_profile_card.dart';
import 'package:smarthealth_shep/features/home/widgets/profile_completion_widget.dart';
import 'package:smarthealth_shep/features/notifications/widgets/notification_bell_button.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/medical_texture_background.dart';
import 'package:smarthealth_shep/shared/widgets/my_health_header_brand.dart';

class HomeHeaderCard extends ConsumerWidget {
  const HomeHeaderCard({
    super.key,
    required this.city,
    required this.searchHint,
    required this.onSearchTap,
    required this.onLocationTap,
  });

  final String city;
  final String searchHint;
  final VoidCallback onSearchTap;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summaryAsync = ref.watch(homeMedicalSummaryProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final wordmarkWidth = (screenWidth * 0.36).clamp(120.0, 160.0);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: MedicalTextureBackground(
        baseColor: HomeDashboardColors.of(context).headerBlue,
        patternColor: Colors.white,
        patternOpacity: 0.04,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.paddingOf(context).top + 12,
            16,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: summaryAsync.when(
                        data: (summary) => ProfileCompletionWidget(
                          completion: summary.completion,
                          compact: true,
                        ),
                        loading: () => const SizedBox(
                          width: 96,
                          height: 48,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                        error: (_, _) => const SizedBox(width: 96, height: 48),
                      ),
                    ),
                    Center(
                      child: MyHealthHeaderBrand(
                        wordmarkWidth: wordmarkWidth,
                        poweredByText: l10n.homePoweredBySmartHealth,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: NotificationBellButton(headerStyle: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              summaryAsync.when(
                data: (summary) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greetingPrefix(l10n),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${summary.displayName} 👋',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _LocationPill(
                            city: city,
                            onTap: onLocationTap,
                            label: l10n.homeChangeLocation,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 60,
                      child: HomeMedicalProfileCard(
                        summary: summary,
                        compact: true,
                      ),
                    ),
                  ],
                ),
                loading: () => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greetingPrefix(l10n),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _LocationPill(
                            city: city,
                            onTap: onLocationTap,
                            label: l10n.homeChangeLocation,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      flex: 60,
                      child: SizedBox(
                        height: 140,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                error: (_, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greetingPrefix(l10n),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _LocationPill(
                      city: city,
                      onTap: onLocationTap,
                      label: l10n.homeChangeLocation,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _HeaderSearchBar(hint: searchHint, onTap: onSearchTap),
            ],
          ),
        ),
      ),
    );
  }

  String _greetingPrefix(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.homeGoodMorning;
    if (hour < 17) return l10n.homeGoodAfternoon;
    return l10n.homeGoodEvening;
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill({
    required this.city,
    required this.onTap,
    required this.label,
  });

  final String city;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: HomeDashboardColors.of(context).headerBlueDark,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Symbols.location_on,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Symbols.expand_more,
                  size: 18,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSearchBar extends StatelessWidget {
  const _HeaderSearchBar({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hint,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: AppConstants.minTapTarget,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Symbols.search,
                  color: HomeDashboardColors.of(context).headerBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(
                      color: HomeDashboardColors.of(context).textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
