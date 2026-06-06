import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:url_launcher/url_launcher.dart';

const _logName = 'MapsLauncher';

/// Opens [query] in the device maps app (coords or address string).
///
/// Does not rely on [canLaunchUrl] — on Android 11+ that returns false for
/// https/geo intents unless `<queries>` are declared in the manifest.
Future<bool> openInMaps(String query) async {
  if (query.trim().isEmpty) return false;

  final encoded = Uri.encodeComponent(query);
  final candidates = [
    Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded'),
    Uri.parse('geo:0,0?q=$encoded'),
  ];

  for (final uri in candidates) {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    } catch (error, stackTrace) {
      developer.log(
        'Maps launch failed for $uri',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  if (kDebugMode) {
    developer.log('All maps launch attempts failed for: $query', name: _logName);
  }
  return false;
}

extension FacilityMapsX on FacilityModel {
  String? get mapsQuery {
    if (latitude != null && longitude != null) {
      return '$latitude,$longitude';
    }
    final parts = [
      addressLine1,
      city,
      province,
    ].whereType<String>().where((s) => s.isNotEmpty);
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }
}

extension ProviderMapsX on ProviderModel {
  String? get mapsQuery {
    if (latitude != null && longitude != null) {
      return '$latitude,$longitude';
    }
    return address;
  }
}
