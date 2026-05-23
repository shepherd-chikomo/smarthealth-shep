import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// OpenStreetMap provider map (low-bandwidth tiles).
class SearchMapScreen extends StatelessWidget {
  const SearchMapScreen({super.key});

  static const _harare = LatLng(-17.8252, 31.0335);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: _harare,
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.smarthealth.smarthealth_shep',
          ),
          const MarkerLayer(
            markers: [
              Marker(
                point: _harare,
                width: 40,
                height: 40,
                child: Icon(Icons.location_on, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
