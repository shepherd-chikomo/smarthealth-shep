import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/widgets/smart_image.dart';

class ProviderHeroImage extends StatelessWidget {
  const ProviderHeroImage({super.key, required this.provider});

  static const double height = 200;

  final ProviderModel provider;

  @override
  Widget build(BuildContext context) {
    final heroSource = provider.heroImageUrl ??
        provider.imageUrl ??
        AppAssets.providerHeroFor(provider.id);

    if (heroSource != null && heroSource.isNotEmpty) {
      return SmartImage(
        source: heroSource,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        memCacheWidth: 800,
        placeholder: Container(
          height: height,
          color: HomeDashboardColors.skeleton,
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: _MapHero(provider: provider),
      );
    }
    return _MapHero(provider: provider);
  }
}

class _MapHero extends StatelessWidget {
  const _MapHero({required this.provider});

  final ProviderModel provider;

  @override
  Widget build(BuildContext context) {
    if (provider.latitude == null || provider.longitude == null) {
      return Container(
        height: ProviderHeroImage.height,
        color: HomeDashboardColors.primary.withValues(alpha: 0.15),
        child: const Center(
          child: Icon(
            Icons.local_hospital,
            size: 64,
            color: HomeDashboardColors.primary,
          ),
        ),
      );
    }

    final point = LatLng(provider.latitude!, provider.longitude!);
    return SizedBox(
      height: ProviderHeroImage.height,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: point,
          initialZoom: 15,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.smarthealth.smarthealth_shep',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: point,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  size: 40,
                  color: HomeDashboardColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
