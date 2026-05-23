import 'package:smarthealth_shep/core/assets.dart';

/// Emergency service metadata aligned with bundled SVG icons.
class EmergencyServiceAsset {
  const EmergencyServiceAsset({
    required this.id,
    required this.phone,
    required this.iconAsset,
  });

  final String id;
  final String phone;
  final String iconAsset;
}

const emergencyServices = <EmergencyServiceAsset>[
  EmergencyServiceAsset(
    id: 'ambulance',
    phone: '994',
    iconAsset: AppAssets.emergencyAmbulance,
  ),
  EmergencyServiceAsset(
    id: 'police',
    phone: '995',
    iconAsset: AppAssets.emergencyPolice,
  ),
  EmergencyServiceAsset(
    id: 'fire',
    phone: '993',
    iconAsset: AppAssets.emergencyFire,
  ),
  EmergencyServiceAsset(
    id: 'rescue',
    phone: '112',
    iconAsset: AppAssets.emergencyRescue,
  ),
];

EmergencyServiceAsset? emergencyServiceById(String id) {
  for (final service in emergencyServices) {
    if (service.id == id) return service;
  }
  return null;
}
