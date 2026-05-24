import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/appointments/widgets/home_upcoming_appointment_banner.dart';
import 'package:smarthealth_shep/features/home/bloc/home_bloc.dart';
import 'package:smarthealth_shep/features/home/bloc/home_event.dart';
import 'package:smarthealth_shep/features/home/bloc/home_state.dart';
import 'package:smarthealth_shep/features/home/data/home_repository.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/home/widgets/home_header_card.dart';
import 'package:smarthealth_shep/features/home/widgets/home_provider_skeleton.dart';
import 'package:smarthealth_shep/features/home/widgets/service_category_grid.dart';
import 'package:smarthealth_shep/features/queue/models/queue_session.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/queue_card.dart';
import 'package:smarthealth_shep/shared/widgets/medical_texture_background.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';
import 'package:smarthealth_shep/shared/widgets/provider_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(repository: HomeRepository())
        ..add(const LoadHomeData()),
      child: const _HomeDashboardView(),
    );
  }
}

class _HomeDashboardView extends ConsumerWidget {
  const _HomeDashboardView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AppShellScaffold(
      backgroundColor: HomeDashboardColors.background,
      body: MedicalTextureBackground(
        baseColor: HomeDashboardColors.background,
        patternOpacity: HomeDashboardColors.textureOpacityBody,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: HomeDashboardColors.primary,
              onRefresh: () async {
                context.read<HomeBloc>().add(const RefreshHomeData());
                await context.read<HomeBloc>().stream.firstWhere(
                      (s) =>
                          s is HomeLoaded && !s.isRefreshing ||
                          s is HomeOffline ||
                          s is HomeError,
                    );
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: HomeHeaderCard(
                      city: _cityFromState(state),
                      searchHint: l10n.homeSearchHint,
                      onSearchTap: () => context.go('/search'),
                      onLocationTap: () => _showCityPicker(context, state),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ServiceCategoryGrid(
                            selectedId: _categoryFromState(state),
                            labels: _categoryLabels(l10n),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _EmergencyBanner(
                              title: l10n.homeEmergencyTitle,
                              subtitle: l10n.homeEmergencySubtitle,
                              onTap: () => context.go('/emergency'),
                            ),
                          ),
                          if (_activeQueueFromState(state) != null) ...[
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _ActiveQueueBanner(
                                session: _activeQueueFromState(state)!,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: HomeUpcomingAppointmentBanner(),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _SectionHeader(
                              title: l10n.homeNearbyProviders,
                              trailing: TextButton(
                                onPressed: () => context.go('/search'),
                                child: Text(l10n.homeSeeAll),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ..._bodySlivers(context, state),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _cityFromState(HomeState state) => switch (state) {
        HomeLoaded(:final city) => city,
        HomeOffline(:final city) => city,
        HomeError(:final city) => city ?? 'Harare, Zimbabwe',
        _ => 'Harare, Zimbabwe',
      };

  String? _categoryFromState(HomeState state) => switch (state) {
        HomeLoaded(:final selectedCategoryId) => selectedCategoryId,
        HomeOffline(:final selectedCategoryId) => selectedCategoryId,
        _ => null,
      };

  QueueSession? _activeQueueFromState(HomeState state) => switch (state) {
        HomeLoaded(:final activeQueue) => activeQueue,
        HomeOffline(:final activeQueue) => activeQueue,
        _ => null,
      };

  Map<String, String> _categoryLabels(AppLocalizations l10n) => {
        'nearMe': l10n.homeCategoryNearMe,
        'general': l10n.homeCategoryGeneral,
        'dental': l10n.homeCategoryDental,
        'pharmacy': l10n.homeCategoryPharmacy,
        'lab': l10n.homeCategoryLaboratory,
        'pediatrics': l10n.homeCategoryPediatrics,
        'specialist': l10n.homeCategorySpecialists,
      };

  Future<void> _showCityPicker(BuildContext context, HomeState state) async {
    final l10n = AppLocalizations.of(context);
    final city = _cityFromState(state).split(',').first.trim();
    const cities = [
      'Harare, Zimbabwe',
      'Bulawayo, Zimbabwe',
      'Mutare, Zimbabwe',
      'Gweru, Zimbabwe',
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.homeChangeLocation,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...cities.map(
              (c) => ListTile(
                title: Text(c),
                trailing: c.startsWith(city) ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, c.split(',').first.trim()),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null && context.mounted) {
      context.read<HomeBloc>().add(ChangeHomeCity(selected));
    }
  }

  List<Widget> _bodySlivers(BuildContext context, HomeState state) {
    if (state is HomeInitial || state is HomeLoading) {
      return const [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: HomeProviderSkeleton()),
        ),
      ];
    }

    if (state is HomeError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _HomeErrorView(message: state.message),
        ),
      ];
    }

    if (state is HomeLoaded || state is HomeOffline) {
      final providers = state is HomeLoaded
          ? state.visibleProviders
          : (state as HomeOffline).visibleProviders;
      final isRefreshing = state is HomeLoaded && state.isRefreshing;

      return [
        if (isRefreshing)
          const SliverToBoxAdapter(
            child: LinearProgressIndicator(
              minHeight: 2,
              color: HomeDashboardColors.primary,
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: providers.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      AppLocalizations.of(context).homeNoProviders,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: HomeDashboardColors.textSecondary,
                      ),
                    ),
                  ),
                )
              : SliverList.separated(
                  itemCount: providers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    return ProviderCard(
                      provider: provider,
                      onTap: () => context.push('/provider/${provider.id}'),
                    );
                  },
                ),
        ),
      ];
    }

    return const [];
  }
}

class _ActiveQueueBanner extends StatelessWidget {
  const _ActiveQueueBanner({required this.session});

  final QueueSession session;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Your Queue',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: HomeDashboardColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        QueueCard.fromSession(
          session,
          compact: true,
          showLiveIndicator: true,
          onTap: () => context.push('/queue/${session.id}'),
        ),
      ],
    );
  }
}

class _EmergencyBanner extends StatelessWidget {
  const _EmergencyBanner({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: HomeDashboardColors.emergency,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Symbols.emergency,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Symbols.chevron_right,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: HomeDashboardColors.textPrimary,
              letterSpacing: -0.17,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Symbols.error_outline,
            size: 48,
            color: HomeDashboardColors.emergency,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.homeErrorTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: HomeDashboardColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: HomeDashboardColors.textSecondary),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: l10n.homeRetry,
            onPressed: () =>
                context.read<HomeBloc>().add(const LoadHomeData()),
          ),
        ],
      ),
    );
  }
}
