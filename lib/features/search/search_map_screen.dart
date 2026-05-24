import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/search/models/search_criteria.dart';
import 'package:smarthealth_shep/features/search/widgets/search_map_marker.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/widgets/provider_card.dart';

/// OpenStreetMap search results with operational marker styling.
class SearchMapScreen extends StatefulWidget {
  const SearchMapScreen({super.key, required this.criteria});

  final SearchCriteria criteria;

  static const _harare = LatLng(-17.8252, 31.0335);

  @override
  State<SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen> {
  String? _selectedId;

  List<ProviderModel> get _mappableProviders => widget.criteria.results
      .where((p) => p.latitude != null && p.longitude != null)
      .toList();

  LatLng get _center {
    final providers = _mappableProviders;
    if (providers.isEmpty) return SearchMapScreen._harare;

    final lat =
        providers.map((p) => p.latitude!).reduce((a, b) => a + b) /
            providers.length;
    final lon =
        providers.map((p) => p.longitude!).reduce((a, b) => a + b) /
            providers.length;
    return LatLng(lat, lon);
  }

  ProviderModel? get _selectedProvider {
    if (_selectedId == null) return null;
    for (final provider in widget.criteria.results) {
      if (provider.id == _selectedId) return provider;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _selectedProvider;

    return Scaffold(
      backgroundColor: HomeDashboardColors.background,
      appBar: AppBar(
        title: Text(l10n.searchMapView),
        backgroundColor: HomeDashboardColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 12,
              onTap: (_, _) => setState(() => _selectedId = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.smarthealth.smarthealth_shep',
              ),
              MarkerLayer(
                markers: [
                  for (final provider in _mappableProviders)
                    Marker(
                      point: LatLng(provider.latitude!, provider.longitude!),
                      width: 44,
                      height: 44,
                      child: SearchMapMarker(
                        provider: provider,
                        selected: provider.id == _selectedId,
                        onTap: () =>
                            setState(() => _selectedId = provider.id),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (selected != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: ProviderCard(
                provider: selected,
                onTap: () => context.push('/provider/${selected.id}'),
              ),
            ),
        ],
      ),
    );
  }
}
