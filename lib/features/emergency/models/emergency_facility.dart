import 'package:freezed_annotation/freezed_annotation.dart';

part 'emergency_facility.freezed.dart';
part 'emergency_facility.g.dart';

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
  }) = _EmergencyFacility;

  factory EmergencyFacility.fromJson(Map<String, dynamic> json) =>
      _$EmergencyFacilityFromJson(json);
}
