import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/provider_profile/bloc/provider_profile_bloc.dart';
import 'package:smarthealth_shep/features/provider_profile/bloc/provider_profile_event.dart';
import 'package:smarthealth_shep/features/provider_profile/bloc/provider_profile_state.dart';
import 'package:smarthealth_shep/features/provider_profile/data/provider_profile_repository.dart';
import 'package:smarthealth_shep/features/provider_profile/provider_profile_utils.dart';
import 'package:smarthealth_shep/features/provider_profile/widgets/provider_hero_image.dart';
import 'package:smarthealth_shep/features/provider_profile/widgets/provider_profile_card.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/models/operational_status.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/widgets/claim_listing_cta.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/operating_hours_card.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/provider_availability_section.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key, required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProviderProfileBloc(
        providerId: providerId,
        repository: ProviderProfileRepository(),
      ),
      child: _ProviderProfileView(providerId: providerId),
    );
  }
}

class _ProviderProfileView extends StatelessWidget {
  const _ProviderProfileView({required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: HomeDashboardColors.background,
      body: BlocBuilder<ProviderProfileBloc, ProviderProfileState>(
        builder: (context, state) {
          return switch (state.status) {
            ProviderProfileStatus.initial ||
            ProviderProfileStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            ProviderProfileStatus.notFound => _NotFoundView(
                providerId: providerId,
                onBack: () => context.pop(),
              ),
            ProviderProfileStatus.error => _ErrorView(
                message: state.errorMessage ?? l10n.profileErrorGeneric,
                onRetry: () => context
                    .read<ProviderProfileBloc>()
                    .add(const ReloadProviderProfile()),
                onBack: () => context.pop(),
              ),
            ProviderProfileStatus.loaded => _LoadedProfileView(
                provider: state.provider!,
                isOffline: state.isOffline,
              ),
          };
        },
      ),
    );
  }
}

class _LoadedProfileView extends StatelessWidget {
  const _LoadedProfileView({
    required this.provider,
    required this.isOffline,
  });

  final ProviderModel provider;
  final bool isOffline;

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _directions(ProviderModel p) async {
    final query = p.mapsQuery;
    if (query == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static ClaimOperationalStatus _claimStatusFor(ProviderModel provider) {
    const facilityCategories = {'hospital', 'clinic', 'pharmacy', 'ambulance'};
    final isFacility = facilityCategories.contains(provider.categoryId);
    if (provider.isVerified && isFacility) {
      return ClaimOperationalStatus.verifiedFacility;
    }
    if (provider.isVerified) {
      return ClaimOperationalStatus.verifiedPractitioner;
    }
    if (provider.isClaimed) {
      return ClaimOperationalStatus.claimPending;
    }
    return ClaimOperationalStatus.unclaimed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: HomeDashboardColors.surface,
          foregroundColor: HomeDashboardColors.textPrimary,
          leading: Semantics(
            button: true,
            label: 'Back',
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          title: Text(
            provider.facilityName ?? provider.name,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isOffline)
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              color: HomeDashboardColors.warning.withValues(alpha: 0.15),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.profileOfflineHint,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: HomeDashboardColors.textSecondary,
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ProviderHeroImage(provider: provider),
              Positioned(
                left: 16,
                right: 16,
                bottom: -48,
                child: ProviderProfileCard(provider: provider),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 56)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ProviderActionButtons(
                provider: provider,
                callLabel: l10n.profileCallNow,
                directionsLabel: l10n.profileGetDirections,
                onCall: () {
                  if (provider.phone != null) _call(provider.phone!);
                },
                onDirections: () => _directions(provider),
              ),
              const SizedBox(height: 24),
              ProviderAvailabilitySection.fromProvider(provider),
              const SizedBox(height: 24),
              _AboutSection(
                title: l10n.profileAbout,
                text: provider.about ?? l10n.profileAboutEmpty,
              ),
              const SizedBox(height: 24),
              _ServicesSection(
                title: l10n.profileServices,
                services: provider.services,
                emptyLabel: l10n.profileServicesEmpty,
              ),
              const SizedBox(height: 24),
              OperatingHoursCard(
                title: l10n.profileWorkingHours,
                hours: provider.weeklyHours,
                closedLabel: l10n.profileClosed,
              ),
              const SizedBox(height: 24),
              Semantics(
                button: true,
                label: l10n.profileBookAppointment,
                child: FilledButton(
                  onPressed: () {
                    context.push('/booking/${provider.id}');
                  },
                  style: FilledButton.styleFrom(
                    minimumSize:
                        const Size.fromHeight(AppConstants.minTapTarget),
                    backgroundColor: HomeDashboardColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.profileBookAppointment,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (provider.hasQueue == true ||
                  provider.acceptsWalkIns == true) ...[
                const SizedBox(height: 12),
                Semantics(
                  button: true,
                  label: 'Join Queue',
                  child: OutlinedButton(
                    onPressed: () {
                      context.push('/queue/join/${provider.id}');
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize:
                          const Size.fromHeight(AppConstants.minTapTarget),
                      foregroundColor: HomeDashboardColors.primary,
                      side: const BorderSide(color: HomeDashboardColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Join Queue',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
              ClaimListingCta(
                targetId: provider.id,
                claimType: 'provider',
                claimStatus: _claimStatusFor(provider),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatefulWidget {
  const _AboutSection({required this.title, required this.text});

  final String title;
  final String text;

  @override
  State<_AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<_AboutSection> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = const TextStyle(
      fontSize: 14,
      height: 1.5,
      color: HomeDashboardColors.textSecondary,
    );

    return _SectionCard(
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: style,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? null : TextOverflow.ellipsis,
          ),
          if (widget.text.length > 120)
            TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(_expanded ? l10n.profileShowLess : l10n.profileShowMore),
            ),
        ],
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({
    required this.title,
    required this.services,
    required this.emptyLabel,
  });

  final String title;
  final List<String> services;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: services.isEmpty
          ? Text(
              emptyLabel,
              style: const TextStyle(color: HomeDashboardColors.textSecondary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: services
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '•  ',
                            style: TextStyle(
                              fontSize: 16,
                              color: HomeDashboardColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 14,
                                color: HomeDashboardColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeDashboardColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: HomeDashboardColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView({required this.providerId, required this.onBack});

  final String providerId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.person_off_outlined,
              size: 56,
              color: HomeDashboardColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.profileNotFoundTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profileNotFoundBody(providerId),
              textAlign: TextAlign.center,
              style: const TextStyle(color: HomeDashboardColors.textSecondary),
            ),
            const Spacer(),
            PrimaryButton(label: l10n.profileGoBack, onPressed: onBack),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.error_outline,
              size: 56,
              color: HomeDashboardColors.emergency,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.profileErrorTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: HomeDashboardColors.textSecondary),
            ),
            const Spacer(),
            PrimaryButton(label: l10n.homeRetry, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
