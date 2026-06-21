import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/location/models/location_models.dart';
import 'package:smarthealth_shep/core/location/location_providers.dart';
import 'package:smarthealth_shep/features/emergency/bloc/emergency_hub_bloc.dart';
import 'package:smarthealth_shep/features/emergency/bloc/emergency_hub_event.dart';
import 'package:smarthealth_shep/features/emergency/bloc/emergency_hub_state.dart';
import 'package:smarthealth_shep/features/emergency/data/emergency_hub_repository.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_facility.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_service.dart';
import 'package:smarthealth_shep/features/emergency/widgets/emergency_hub_widgets.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

enum _EmergencyServiceFilter { all, ambulances }

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmergencyHubBloc(
        repository: EmergencyHubRepository(
          searchOrigin: ref.read(searchOriginResolverProvider),
        ),
      ),
      child: const _EmergencyHubView(),
    );
  }
}

class _EmergencyHubView extends ConsumerStatefulWidget {
  const _EmergencyHubView();

  @override
  ConsumerState<_EmergencyHubView> createState() => _EmergencyHubViewState();
}

class _EmergencyHubViewState extends ConsumerState<_EmergencyHubView> {
  _EmergencyServiceFilter _filter = _EmergencyServiceFilter.all;

  Future<void> _call(String phone) async {
    if (phone.trim().isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  String? _sourceBadge(EmergencyFacility facility) {
    if (facility.pendingVerification) {
      return AppLocalizations.of(context).emergencyPendingVerification;
    }
    return switch (facility.source) {
      EmergencyFacilitySource.profileEmergency => 'Emergency dept',
      EmergencyFacilitySource.emergencyDirectory => null,
      EmergencyFacilitySource.governmentHospital => null,
      null => null,
    };
  }

  bool _isPendingVerificationBadge(EmergencyFacility facility) =>
      facility.pendingVerification;

  String _locationLabel(EmergencyHubState state) {
    final l10n = AppLocalizations.of(context);
    final origin =
        state.searchOrigin ?? ref.read(searchOriginResolverProvider).readCached();
    if (origin?.source == LocationSource.manual) {
      final city = origin?.cityName;
      return city != null && city.isNotEmpty
          ? l10n.emergencySelectedLocation(city)
          : l10n.emergencySelectedLocation('Harare');
    }
    return l10n.emergencyCurrentLocation;
  }

  bool _isManualLocation(EmergencyHubState state) {
    final origin =
        state.searchOrigin ?? ref.read(searchOriginResolverProvider).readCached();
    return origin?.source == LocationSource.manual;
  }

  List<EmergencyService> _visibleServices(EmergencyHubState state) {
    final data = state.data;
    if (data == null) return const [];

    if (_filter == _EmergencyServiceFilter.ambulances) {
      final gridAmbulance = data.services
          .where((s) => s.kind == EmergencyServiceKind.ambulance)
          .toList();
      final facilityAmbulance = data.ambulanceServices;
      return [...gridAmbulance, ...facilityAmbulance];
    }

    return data.services;
  }

  Future<void> _directions({
    required double? lat,
    required double? lng,
    required String? address,
  }) async {
    final query = lat != null && lng != null ? '$lat,$lng' : address;
    if (query == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _locationBar(BuildContext context, EmergencyHubState state) {
    final l10n = AppLocalizations.of(context);
    final isManual = _isManualLocation(state);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Icon(
            isManual ? Icons.place_outlined : Icons.my_location,
            size: 18,
            color: HomeDashboardColors.of(context).primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _locationLabel(state),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: HomeDashboardColors.of(context).textSecondary,
              ),
            ),
          ),
          if (isManual)
            TextButton(
              onPressed: () => context.read<EmergencyHubBloc>().add(
                    const RefreshEmergencyHub(useCurrentLocation: true),
                  ),
              child: Text(l10n.emergencyUseCurrentLocation),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SearchOriginChange>>(searchOriginChangesProvider,
        (previous, next) {
      next.whenData((change) {
        final bloc = context.read<EmergencyHubBloc>();
        if (change.kind == SearchOriginChangeKind.manualCity) {
          bloc.add(const RefreshEmergencyHub());
          return;
        }
        if (change.kind == SearchOriginChangeKind.gps &&
            bloc.state.status != EmergencyHubStatus.loading) {
          bloc.add(const RefreshEmergencyHub());
        }
      });
    });

    final l10n = AppLocalizations.of(context);

    return AppShellScaffold(
      backgroundColor: HomeDashboardColors.of(context).background,
      appBar: AppBar(
        title: BlocBuilder<EmergencyHubBloc, EmergencyHubState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.navEmergency),
                Text(
                  _locationLabel(state),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: HomeDashboardColors.of(context).textSecondary,
                  ),
                ),
              ],
            );
          },
        ),
        backgroundColor: HomeDashboardColors.of(context).background,
      ),
      body: BlocBuilder<EmergencyHubBloc, EmergencyHubState>(
        builder: (context, state) {
          if (state.status == EmergencyHubStatus.loading && state.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = state.data;
          if (data == null) {
            return Center(
              child: PrimaryButton(
                label: l10n.homeRetry,
                onPressed: () =>
                    context.read<EmergencyHubBloc>().add(const RefreshEmergencyHub()),
              ),
            );
          }

          final visibleServices = _visibleServices(state);

          return RefreshIndicator(
            color: HomeDashboardColors.of(context).primary,
            onRefresh: () async {
              context.read<EmergencyHubBloc>().add(const RefreshEmergencyHub());
              await context.read<EmergencyHubBloc>().stream.firstWhere(
                    (s) =>
                        s.status != EmergencyHubStatus.loading || s.data != null,
                  );
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                EmergencyWarningBanner(message: l10n.emergencyWarningBanner),
                _locationBar(context, state),
                if (data.locationRequired)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: EmergencyLocationPrompt(
                      message: l10n.emergencyLocationPrompt,
                      actionLabel: l10n.homeRetry,
                      onRequestLocation: () => context
                          .read<EmergencyHubBloc>()
                          .add(const RefreshEmergencyHub(useCurrentLocation: true)),
                    ),
                  ),
                if (state.isOffline)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      l10n.emergencyOfflineReady,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: HomeDashboardColors.of(context).textSecondary,
                      ),
                    ),
                  ),
                if (data.expandedSearch)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      l10n.emergencyExpandedSearchHint,
                      style: TextStyle(
                        fontSize: 13,
                        color: HomeDashboardColors.of(context).textSecondary,
                      ),
                    ),
                  ),
                if (data.services.isEmpty &&
                    data.ambulanceServices.isEmpty &&
                    !data.locationRequired)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      l10n.emergencyNoServicesNearby,
                      style: TextStyle(
                        fontSize: 13,
                        color: HomeDashboardColors.of(context).textSecondary,
                      ),
                    ),
                  ),
                if (data.services.isNotEmpty || data.ambulanceServices.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      l10n.emergencyNearestServicesTitle,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: HomeDashboardColors.of(context).textPrimary,
                      ),
                    ),
                  ),
                if (data.services.isNotEmpty || data.ambulanceServices.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: SegmentedButton<_EmergencyServiceFilter>(
                      segments: [
                        ButtonSegment(
                          value: _EmergencyServiceFilter.all,
                          label: Text(l10n.emergencyFilterAll),
                        ),
                        ButtonSegment(
                          value: _EmergencyServiceFilter.ambulances,
                          label: Text(l10n.emergencyFilterAmbulances),
                        ),
                      ],
                      selected: {_filter},
                      onSelectionChanged: (selection) {
                        setState(() => _filter = selection.first);
                      },
                    ),
                  ),
                if (visibleServices.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: visibleServices.length.clamp(0, 8),
                      itemBuilder: (context, index) {
                        final service = visibleServices[index];
                        return EmergencyServiceGridCard(
                          service: service,
                          distanceLabel: l10n.emergencyNearestDistance(
                            service.nearestDistanceKm,
                          ),
                          onTap: () => context.push(
                            '/emergency/service/${service.id}',
                            extra: service,
                          ),
                        );
                      },
                    ),
                  ),
                if (_filter == _EmergencyServiceFilter.ambulances &&
                    visibleServices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      l10n.emergencyNoServicesNearby,
                      style: TextStyle(
                        fontSize: 13,
                        color: HomeDashboardColors.of(context).textSecondary,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text(
                    l10n.emergencyHospitalsFacilitiesTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: HomeDashboardColors.of(context).textPrimary,
                    ),
                  ),
                ),
                if (data.facilities.isEmpty && !data.locationRequired)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      l10n.emergencyNoFacilitiesNearby,
                      style: TextStyle(
                        fontSize: 13,
                        color: HomeDashboardColors.of(context).textSecondary,
                      ),
                    ),
                  ),
                ...data.facilities.map((facility) {
                  final hasPhone = facility.phone.trim().isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: EmergencyFacilityCard(
                      name: facility.name,
                      type: facility.type,
                      sourceBadge: _sourceBadge(facility),
                      pendingVerification: _isPendingVerificationBadge(facility),
                      distanceLabel: l10n.homeDistanceKm(facility.distanceKm),
                      callLabel: l10n.emergencyCall,
                      directionsLabel: l10n.emergencyDirections,
                      onCall: hasPhone ? () => _call(facility.phone) : null,
                      onDirections: () => _directions(
                        lat: facility.latitude,
                        lng: facility.longitude,
                        address: facility.name,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
