import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

class ProviderHeroImage extends StatelessWidget {
  const ProviderHeroImage({super.key, required this.provider});

  static const double height = 200;

  final ProviderModel provider;

  @override
  Widget build(BuildContext context) {
    final heroUrl = provider.heroImageUrl ?? provider.imageUrl;
    if (heroUrl != null && heroUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: heroUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        memCacheWidth: 800,
        placeholder: (context, url) => Container(
          height: height,
          color: HomeDashboardColors.skeleton,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => _MapHero(provider: provider),
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
