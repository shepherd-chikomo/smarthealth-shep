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
import 'package:smarthealth_shep/features/home/models/facility_load_mode.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/location/models/location_models.dart';
import 'package:smarthealth_shep/core/location/location_providers.dart';
import 'package:smarthealth_shep/shared/data/category_repository.dart';
import 'package:smarthealth_shep/shared/data/facility_repository.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/home/providers/home_medical_summary_provider.dart';
import 'package:smarthealth_shep/features/home/widgets/home_backup_restore_banner.dart';
import 'package:smarthealth_shep/features/home/widgets/home_header_card.dart';
import 'package:smarthealth_shep/features/home/widgets/home_provider_skeleton.dart';
import 'package:smarthealth_shep/features/home/widgets/service_category_grid.dart';
import 'package:smarthealth_shep/features/queue/models/queue_session.dart';
import 'package:smarthealth_shep/features/notifications/widgets/home_broadcast_banner.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/queue_card.dart';
import 'package:smarthealth_shep/shared/widgets/medical_texture_background.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';
import 'package:smarthealth_shep/shared/models/service_category_model.dart';
import 'package:smarthealth_shep/shared/widgets/facility_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearMeLabel = AppLocalizations.of(context).homeCategoryNearMe;
    return BlocProvider(
      create: (_) => HomeBloc(
        repository: HomeRepository(
          facilityRepository: ref.read(facilityRepositoryProvider),
          searchOrigin: ref.read(searchOriginResolverProvider),
        ),
        categoryRepository: ref.read(categoryRepositoryProvider),
      )..add(LoadHomeData(nearMeLabel: nearMeLabel)),
      child: _HomeDashboardView(),
    );
  }
}

class _HomeDashboardView extends ConsumerWidget {
  _HomeDashboardView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<SearchOriginChange>>(searchOriginChangesProvider,
        (previous, next) {
      next.whenData((change) {
        if (change.kind != SearchOriginChangeKind.gps) return;
        final bloc = context.read<HomeBloc>();
        final state = bloc.state;
        if (state is HomeLoaded && state.isRefreshing) return;
        bloc.add(const RefreshHomeData());
      });
    });

    final l10n = AppLocalizations.of(context);

    ref.watch(homeMedicalSummaryProvider);

    return AppShellScaffold(
      backgroundColor: HomeDashboardColors.of(context).background,
      body: Stack(
        children: [
          MedicalTextureBackground(
        baseColor: HomeDashboardColors.of(context).background,
        patternOpacity: HomeDashboardColors.textureOpacityBody,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: HomeDashboardColors.of(context).primary,
              onRefresh: () async {
                context.read<HomeBloc>().add(
                      const RefreshHomeData(refreshOrigin: true),
                    );
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
                            categories: _categoriesFromState(state),
                            selectedId: _categoryFromState(state),
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
                          const HomeBackupRestoreBanner(),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: HomeUpcomingAppointmentBanner(),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _SectionHeader(
                              title: l10n.homeNearbyFacilities,
                              trailing: TextButton(
                                onPressed: () => context.go('/search'),
                                child: Text(l10n.homeSeeAll),
                              ),
                            ),
                          ),
                          if (_cityFallbackHint(state, l10n) != null)
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Text(
                                _cityFallbackHint(state, l10n)!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: HomeDashboardColors.of(context).textSecondary,
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
          const HomeBroadcastBanner(),
        ],
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

  List<ServiceCategoryModel> _categoriesFromState(HomeState state) =>
      switch (state) {
        HomeLoading(:final categories) => categories,
        HomeLoaded(:final categories) => categories,
        HomeOffline(:final categories) => categories,
        HomeError(:final categories) => categories,
        _ => const [],
      };

  String? _cityFallbackHint(HomeState state, AppLocalizations l10n) {
    final (mode, city) = switch (state) {
      HomeLoaded(:final loadMode, :final fallbackCity) =>
        (loadMode, fallbackCity),
      HomeOffline(:final loadMode, :final fallbackCity) =>
        (loadMode, fallbackCity),
      _ => (FacilityLoadMode.geo, null),
    };
    if (mode != FacilityLoadMode.cityFallback || city == null) return null;
    return l10n.homeCityFallbackHint(city);
  }

  String? _fallbackCityFromState(HomeState state) => switch (state) {
        HomeLoaded(:final fallbackCity) => fallbackCity,
        HomeOffline(:final fallbackCity) => fallbackCity,
        _ => null,
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
      final facilities = state is HomeLoaded
          ? state.visibleFacilities
          : (state as HomeOffline).visibleFacilities;
      final isRefreshing = state is HomeLoaded && state.isRefreshing;

      return [
        if (isRefreshing)
          SliverToBoxAdapter(
            child: LinearProgressIndicator(
              minHeight: 2,
              color: HomeDashboardColors.of(context).primary,
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: facilities.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _HomeEmptyFacilities(
                      state: state,
                      onRetry: () => context
                          .read<HomeBloc>()
                          .add(const RefreshHomeData()),
                      onCityFallback: _fallbackCityFromState(state) != null
                          ? () => context
                              .read<HomeBloc>()
                              .add(const LoadHomeCityFallback())
                          : null,
                    ),
                  ),
                )
              : SliverList.separated(
                  itemCount: facilities.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final facility = facilities[index];
                    return FacilityCard(
                      facility: facility,
                      onTap: () => context.push('/facility/${facility.id}?tab=0'),
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
  _ActiveQueueBanner({required this.session});

  final QueueSession session;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Your Queue',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: HomeDashboardColors.of(context).textPrimary,
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

class _HomeEmptyFacilities extends StatelessWidget {
  const _HomeEmptyFacilities({
    required this.state,
    required this.onRetry,
    this.onCityFallback,
  });

  final HomeState state;
  final VoidCallback onRetry;
  final VoidCallback? onCityFallback;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loadError = switch (state) {
      HomeLoaded(:final loadError) => loadError,
      _ => null,
    };
    final fallbackCity = switch (state) {
      HomeLoaded(:final fallbackCity) => fallbackCity,
      HomeOffline(:final fallbackCity) => fallbackCity,
      _ => null,
    };
    final loadMode = switch (state) {
      HomeLoaded(:final loadMode) => loadMode,
      HomeOffline(:final loadMode) => loadMode,
      _ => FacilityLoadMode.geo,
    };

    return Column(
      children: [
        Text(
          loadError != null
              ? 'Could not reach the server.\n${AppConfig.apiBaseUrl}'
              : l10n.homeNoProviders,
          textAlign: TextAlign.center,
          style: TextStyle(color: HomeDashboardColors.of(context).textSecondary),
        ),
        if (loadError != null) ...[
          SizedBox(height: 8),
          Text(
            loadError,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: HomeDashboardColors.of(context).textSecondary,
            ),
          ),
        ],
        if (loadMode == FacilityLoadMode.geo &&
            fallbackCity != null &&
            onCityFallback != null &&
            loadError == null) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: onCityFallback,
            child: Text(l10n.homeShowAllInCity(fallbackCity)),
          ),
        ],
        const SizedBox(height: 16),
        PrimaryButton(label: l10n.homeRetry, onPressed: onRetry),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: HomeDashboardColors.of(context).textPrimary,
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
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.error_outline,
            size: 48,
            color: HomeDashboardColors.of(context).emergency,
          ),
          SizedBox(height: 16),
          Text(
            l10n.homeErrorTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: HomeDashboardColors.of(context).textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: HomeDashboardColors.of(context).textSecondary),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: l10n.homeRetry,
            onPressed: () => context
                .read<HomeBloc>()
                .add(const RefreshHomeData()),
          ),
        ],
      ),
    );
  }
}
