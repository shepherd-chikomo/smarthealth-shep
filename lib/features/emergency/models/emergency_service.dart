import 'package:freezed_annotation/freezed_annotation.dart';

part 'emergency_service.freezed.dart';
part 'emergency_service.g.dart';

enum EmergencyServiceKind {
  ambulance,
  police,
  fireRescue,
  rescueTeam,
}

@freezed
abstract class EmergencyService with _$EmergencyService {
  const factory EmergencyService({
    required String id,
    required String name,
    required EmergencyServiceKind kind,
    required String phone,
    required double nearestDistanceKm,
    String? nearestProviderName,
    double? nearestLatitude,
    double? nearestLongitude,
  }) = _EmergencyService;

  factory EmergencyService.fromJson(Map<String, dynamic> json) =>
      _$EmergencyServiceFromJson(json);
}
