import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/location/location_providers.dart';
import 'package:smarthealth_shep/core/location/models/location_models.dart';
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

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class _EmergencyHubView extends StatefulWidget {
  const _EmergencyHubView();

  @override
  State<_EmergencyHubView> createState() => _EmergencyHubViewState();
}

class _EmergencyHubViewState extends State<_EmergencyHubView> {
  _EmergencyServiceFilter _filter = _EmergencyServiceFilter.all;

  Future<void> _call(String phone) async {
    if (phone.trim().isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  String? _sourceBadge(EmergencyFacility facility) {
    return switch (facility.source) {
      EmergencyFacilitySource.profileEmergency => 'Emergency dept',
      EmergencyFacilitySource.emergencyDirectory => 'ER directory',
      EmergencyFacilitySource.governmentHospital => null,
      null => null,
    };
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

  Widget _locationPill(BuildContext context, EmergencyHubState state) {
    final l10n = AppLocalizations.of(context);
    final origin = state.searchOrigin;
    final isManual = origin?.source == LocationSource.manual;
    final label = isManual
        ? l10n.emergencySelectedLocation(origin?.cityName ?? '')
        : l10n.emergencyCurrentLocation;

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
              label,
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
    final l10n = AppLocalizations.of(context);

    return AppShellScaffold(
      backgroundColor: HomeDashboardColors.of(context).background,
      appBar: AppBar(
        title: Text(l10n.navEmergency),
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
                if (!data.locationRequired) _locationPill(context, state),
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
                        childAspectRatio: 0.95,
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
                          onCall: service.phone.trim().isNotEmpty
                              ? () => _call(service.phone)
                              : null,
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
