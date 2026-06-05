import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds a maps search query and opens the device default maps app.
Future<void> openInMaps(String query) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
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
