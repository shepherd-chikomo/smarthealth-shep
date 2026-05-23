import 'package:smarthealth_shep/features/emergency/models/emergency_facility.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_hub_data.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_service.dart';

/// Hardcoded emergency numbers — always available offline as fallback.
abstract final class EmergencyFallbackData {
  static const ambulancePhone = '994';
  static const policePhone = '995';
  static const firePhone = '993';
  static const rescuePhone = '112';

  static EmergencyHubData hub({DateTime? cachedAt}) {
    final now = cachedAt ?? DateTime.now();
    return EmergencyHubData(
      cachedAt: now,
      services: const [
        EmergencyService(
          id: 'ambulance',
          name: 'Ambulance',
          kind: EmergencyServiceKind.ambulance,
          phone: ambulancePhone,
          nearestDistanceKm: 1.2,
          nearestProviderName: 'Parirenyatwa EMRAS Dispatch',
          nearestLatitude: -17.8252,
          nearestLongitude: 31.0335,
        ),
        EmergencyService(
          id: 'police',
          name: 'Police',
          kind: EmergencyServiceKind.police,
          phone: policePhone,
          nearestDistanceKm: 2.1,
          nearestProviderName: 'Harare Central Police',
          nearestLatitude: -17.8290,
          nearestLongitude: 31.0520,
        ),
        EmergencyService(
          id: 'fire_rescue',
          name: 'Fire & Rescue',
          kind: EmergencyServiceKind.fireRescue,
          phone: firePhone,
          nearestDistanceKm: 3.4,
          nearestProviderName: 'Harare Fire Station',
          nearestLatitude: -17.8315,
          nearestLongitude: 31.0455,
        ),
        EmergencyService(
          id: 'rescue_team',
          name: 'Rescue Team',
          kind: EmergencyServiceKind.rescueTeam,
          phone: rescuePhone,
          nearestDistanceKm: 1.8,
          nearestProviderName: 'Civil Protection Unit',
          nearestLatitude: -17.8200,
          nearestLongitude: 31.0400,
        ),
      ],
      facilities: const [
        EmergencyFacility(
          id: 'ef1',
          name: 'Parirenyatwa Hospital ER',
          type: 'Hospital Emergency',
          distanceKm: 1.2,
          phone: '+263242703831',
          latitude: -17.8252,
          longitude: 31.0335,
        ),
        EmergencyFacility(
          id: 'ef2',
          name: 'Avenues Clinic Emergency',
          type: 'Private ER',
          distanceKm: 2.8,
          phone: '+263242870111',
          latitude: -17.8194,
          longitude: 31.0522,
        ),
        EmergencyFacility(
          id: 'ef3',
          name: 'Wilkins Hospital',
          type: 'Infectious Disease ER',
          distanceKm: 4.5,
          phone: '+263242706077',
          latitude: -17.8420,
          longitude: 31.0180,
        ),
        EmergencyFacility(
          id: 'ef4',
          name: 'Borrowdale Trauma Centre',
          type: 'Trauma Unit',
          distanceKm: 5.2,
          phone: '+263242862000',
          latitude: -17.8100,
          longitude: 31.0900,
        ),
      ],
    );
  }
}

/// Simulated API payload that can override phone numbers and distances.
abstract final class EmergencyApiMock {
  static EmergencyHubData? fetchUpdate() {
    // Returns null when API unavailable; non-null merges updates.
    return EmergencyFallbackData.hub().copyWith(
      services: EmergencyFallbackData.hub().services.map((s) {
        return switch (s.kind) {
          EmergencyServiceKind.ambulance =>
            s.copyWith(nearestDistanceKm: 1.0),
          _ => s,
        };
      }).toList(),
    );
  }
}
