import 'dart:async';

import 'package:geocoding/geocoding.dart';

/// Forward-geocodes an address string to coordinates using platform services.
class ForwardGeocoder {
  const ForwardGeocoder({this.timeout = const Duration(seconds: 8)});

  final Duration timeout;

  Future<({double lat, double lon})?> geocodeAddress(String address) async {
    if (address.trim().isEmpty) return null;

    try {
      final locations = await locationFromAddress(address).timeout(timeout);
      if (locations.isEmpty) return null;
      final first = locations.first;
      return (lat: first.latitude, lon: first.longitude);
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
