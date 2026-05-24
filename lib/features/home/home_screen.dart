import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/data/categories.dart';
import 'package:smarthealth_shep/features/appointments/widgets/home_upcoming_appointment_banner.dart';
import 'package:smarthealth_shep/features/home/bloc/home_bloc.dart';
import 'package:smarthealth_shep/features/home/bloc/home_event.dart';
import 'package:smarthealth_shep/features/home/bloc/home_state.dart';
import 'package:smarthealth_shep/features/home/data/home_repository.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/home/widgets/home_provider_skeleton.dart';
import 'package:smarthealth_shep/features/notifications/widgets/notification_bell_button.dart';
import 'package:smarthealth_shep/features/queue/models/queue_session.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/queue_card.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';
import 'package:smarthealth_shep/shared/widgets/category_icon.dart';
import 'package:smarthealth_shep/shared/widgets/provider_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final categoryFilters = categories;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(repository: HomeRepository())
        ..add(const LoadHomeData()),
      child: const _HomeDashboardView(),
    );
  }
}

class _HomeDashboardView extends StatelessWidget {
  const _HomeDashboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppShellScaffold(
      backgroundColor: HomeDashboardColors.background,
      body: BlocBuilder<HomeBloc, HomeState>(
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _LocationPill(city: _cityFromState(state)),
                            ),
                            const SizedBox(width: 12),
                            const NotificationBellButton(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _HomeSearchBar(
                          hint: l10n.homeSearchHint,
                          onTap: () => context.go('/search'),
                        ),
                        const SizedBox(height: 16),
                        _CategoryChipsRow(
                          selectedId: _categoryFromState(state),
                          labels: _categoryLabels(l10n),
                        ),
                        const SizedBox(height: 16),
                        _EmergencyBanner(
                          title: l10n.homeEmergencyTitle,
                          subtitle: l10n.homeEmergencySubtitle,
                          onTap: () => context.go('/emergency'),
                        ),
                        if (_activeQueueFromState(state) != null) ...[
                          const SizedBox(height: 16),
                          _ActiveQueueBanner(
                            session: _activeQueueFromState(state)!,
                          ),
                        ],
                        const SizedBox(height: 16),
                        const HomeUpcomingAppointmentBanner(),
                        const SizedBox(height: 20),
                        _SectionHeader(
                          title: l10n.homeNearbyFacilities,
                          trailing: _LastUpdatedBadge(state: state),
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
    );
  }

  String _cityFromState(HomeState state) => switch (state) {
        HomeLoaded(:final city) => city,
        HomeOffline(:final city) => city,
        HomeError(:final city) => city ?? 'Harare',
        _ => 'Harare',
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
        'generalPractice': l10n.homeCategoryGeneralPractice,
        'pediatrics': l10n.homeCategoryPediatrics,
        'dental': l10n.homeCategoryDental,
        'cardiology': l10n.homeCategoryCardiology,
        'more': l10n.homeCategoryMore,
      };

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
      final isRefreshing =
          state is HomeLoaded && state.isRefreshing;

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
                      onTap: () =>
                          context.push('/provider/${provider.id}'),
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

class _LocationPill extends StatelessWidget {
  const _LocationPill({required this.city});

  final String city;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: l10n.homeChangeLocation,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: HomeDashboardColors.surface,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: () => _showCityPicker(context),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              constraints: const BoxConstraints(minHeight: AppConstants.minTapTarget),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE5E8EE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Symbols.location_on,
                    size: 18,
                    color: HomeDashboardColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    city,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: HomeDashboardColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Symbols.expand_more,
                    size: 18,
                    color: HomeDashboardColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCityPicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cities = ['Harare', 'Bulawayo', 'Mutare', 'Gweru'];
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
                trailing: c == city ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, c),
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
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hint,
      child: Material(
        color: HomeDashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: AppConstants.minTapTarget,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E8EE)),
            ),
            child: Row(
              children: [
                const Icon(
                  Symbols.search,
                  color: HomeDashboardColors.textSecondary,
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

class _CategoryChipsRow extends StatelessWidget {
  const _CategoryChipsRow({
    required this.selectedId,
    required this.labels,
  });

  final String? selectedId;
  final Map<String, String> labels;

  String _labelFor(AppCategory item) {
    return switch (item.labelKey) {
      'nearMe' => labels['nearMe'] ?? item.labelKey,
      'generalPractice' => labels['generalPractice'] ?? item.labelKey,
      'pediatrics' => labels['pediatrics'] ?? item.labelKey,
      'dental' => labels['dental'] ?? item.labelKey,
      'cardiology' => labels['cardiology'] ?? item.labelKey,
      'more' => labels['more'] ?? item.labelKey,
      _ => item.labelKey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: HomeScreen.categoryFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = HomeScreen.categoryFilters[index];
          final label = _labelFor(item);
          final selected = (selectedId ?? 'near_me') == item.id;

          return Semantics(
            button: true,
            selected: selected,
            label: label,
            child: FilterChip(
              avatar: CategoryIcon(
                assetPath: item.iconAsset,
                size: 16,
                color: selected
                    ? HomeDashboardColors.primary
                    : HomeDashboardColors.textSecondary,
              ),
              label: Text(label),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) {
                if (item.id == 'more') {
                  context.go('/search');
                  return;
                }
                context.read<HomeBloc>().add(
                      SelectHomeCategory(
                        item.id == 'near_me' ? null : item.id,
                      ),
                    );
              },
              selectedColor: HomeDashboardColors.primary.withValues(alpha: 0.12),
              labelStyle: TextStyle(
                color: selected
                    ? HomeDashboardColors.primary
                    : HomeDashboardColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: selected
                    ? HomeDashboardColors.primary
                    : const Color(0xFFE5E8EE),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        },
      ),
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
        color: HomeDashboardColors.emergencySoft,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: HomeDashboardColors.emergency.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: HomeDashboardColors.emergency,
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
                          color: HomeDashboardColors.emergency,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: HomeDashboardColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Symbols.chevron_right,
                  color: HomeDashboardColors.emergency,
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

class _LastUpdatedBadge extends StatelessWidget {
  const _LastUpdatedBadge({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final DateTime? updated = switch (state) {
      HomeOffline(:final lastUpdated) => lastUpdated,
      HomeLoaded(:final lastUpdated, :final isOffline) when isOffline =>
        lastUpdated,
      _ => null,
    };

    if (updated == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: HomeDashboardColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l10n.homeLastUpdated(formatLastUpdated(updated)),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: HomeDashboardColors.textSecondary,
        ),
      ),
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