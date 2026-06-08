import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_facility.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_service.dart';

part 'emergency_hub_data.freezed.dart';
part 'emergency_hub_data.g.dart';

@freezed
abstract class EmergencyHubData with _$EmergencyHubData {
  const factory EmergencyHubData({
    required List<EmergencyService> services,
    required List<EmergencyFacility> facilities,
    @Default([]) List<EmergencyService> ambulanceServices,
    required DateTime cachedAt,
    @Default(false) bool locationRequired,
    @Default(false) bool expandedSearch,
  }) = _EmergencyHubData;

  factory EmergencyHubData.fromJson(Map<String, dynamic> json) =>
      _$EmergencyHubDataFromJson(json);
}
