import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/features/emergency/bloc/emergency_hub_bloc.dart';
import 'package:smarthealth_shep/features/emergency/bloc/emergency_hub_event.dart';
import 'package:smarthealth_shep/features/emergency/bloc/emergency_hub_state.dart';
import 'package:smarthealth_shep/features/emergency/data/emergency_hub_repository.dart';
import 'package:smarthealth_shep/features/emergency/widgets/emergency_hub_widgets.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmergencyHubBloc(repository: EmergencyHubRepository()),
      child: const _EmergencyHubView(),
    );
  }
}

class _EmergencyHubView extends StatelessWidget {
  const _EmergencyHubView();

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _directions({
    required double? lat,
    required double? lng,
    required String? address,
  }) async {
    final query = lat != null && lng != null
        ? '$lat,$lng'
        : address;
    if (query == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppShellScaffold(
      backgroundColor: HomeDashboardColors.background,
      appBar: AppBar(
        title: Text(l10n.navEmergency),
        backgroundColor: HomeDashboardColors.background,
      ),
      body: BlocBuilder<EmergencyHubBloc, EmergencyHubState>(
        builder: (context, state) {
          if (state.status == EmergencyHubStatus.loading &&
              state.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = state.data;
          if (data == null) {
            return Center(
              child: PrimaryButton(
                label: l10n.homeRetry,
                onPressed: () => context
                    .read<EmergencyHubBloc>()
                    .add(const RefreshEmergencyHub()),
              ),
            );
          }

          return RefreshIndicator(
            color: HomeDashboardColors.primary,
            onRefresh: () async {
              context.read<EmergencyHubBloc>().add(const RefreshEmergencyHub());
              await context.read<EmergencyHubBloc>().stream.firstWhere(
                    (s) => s.status != EmergencyHubStatus.loading ||
                        s.data != null,
                  );
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                EmergencyWarningBanner(message: l10n.emergencyWarningBanner),
                if (state.isOffline)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      l10n.emergencyOfflineReady,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: HomeDashboardColors.textSecondary,
                      ),
                    ),
                  ),
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
                      childAspectRatio: 1.05,
                    ),
                    itemCount: data.services.length,
                    itemBuilder: (context, index) {
                      final service = data.services[index];
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text(
                    l10n.emergencyNearbyFacilities,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: HomeDashboardColors.textPrimary,
                    ),
                  ),
                ),
                ...data.facilities.map((facility) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: EmergencyFacilityCard(
                      name: facility.name,
                      type: facility.type,
                      distanceLabel:
                          l10n.homeDistanceKm(facility.distanceKm),
                      callLabel: l10n.emergencyCall,
                      directionsLabel: l10n.emergencyDirections,
                      onCall: () => _call(facility.phone),
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
