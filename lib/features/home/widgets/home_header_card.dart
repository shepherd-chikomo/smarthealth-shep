import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/auth/patient_profile.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
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
    final profileAsync = ref.watch(patientProfileProvider);
    final firstName = profileAsync.maybeWhen(
      data: (profile) => profile?.greetingName,
      orElse: () => null,
    );

    final wordmarkWidth = MediaQuery.sizeOf(context).width * 0.42;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: MedicalTextureBackground(
        baseColor: HomeDashboardColors.primary,
        patternColor: Colors.white,
        patternOpacity: 0.12,
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
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: MyHealthHeaderBrand(
                      wordmarkWidth: wordmarkWidth,
                      poweredByText: l10n.homePoweredBySmartHealth,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: NotificationBellButton(headerStyle: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _greetingPrefix(l10n),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                firstName != null ? '$firstName 👋' : '👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 12),
              _LocationPill(
                city: city,
                onTap: onLocationTap,
                label: l10n.homeChangeLocation,
              ),
              const SizedBox(height: 16),
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
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: HomeDashboardColors.primaryDark,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Symbols.location_on,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    city,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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
                const Icon(
                  Symbols.search,
                  color: HomeDashboardColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hint,
                    style: const TextStyle(
                      color: HomeDashboardColors.textSecondary,
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
