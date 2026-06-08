import 'package:freezed_annotation/freezed_annotation.dart';

part 'emergency_facility.freezed.dart';
part 'emergency_facility.g.dart';

enum EmergencyFacilitySource {
  @JsonValue('emergency_directory')
  emergencyDirectory,
  @JsonValue('government_hospital')
  governmentHospital,
  @JsonValue('profile_emergency')
  profileEmergency,
}

@freezed
abstract class EmergencyFacility with _$EmergencyFacility {
  const factory EmergencyFacility({
    required String id,
    required String name,
    required String type,
    required double distanceKm,
    required String phone,
    double? latitude,
    double? longitude,
    @Default(true) bool is24Hours,
    EmergencyFacilitySource? source,
    String? referralLabel,
    @Default(false) bool pendingVerification,
  }) = _EmergencyFacility;

  factory EmergencyFacility.fromJson(Map<String, dynamic> json) =>
      _$EmergencyFacilityFromJson(json);
}
