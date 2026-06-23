import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smarthealth_shep/shared/models/working_hours_entry.dart';

part 'provider_model.freezed.dart';
part 'provider_model.g.dart';

@freezed
abstract class ProviderModel with _$ProviderModel {
  const factory ProviderModel({
    required String id,
    required String name,
    required String categoryId,
    String? specialty,
    String? specialtyId,
    String? facilityId,
    String? facilityName,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
    double? distanceKm,
    String? hours,
    String? imageUrl,
    String? heroImageUrl,
    @Default(false) bool isVerified,
    String? mdpczNumber,
    String? about,
    @Default([]) List<String> services,
    @Default([]) List<WorkingHoursEntry> weeklyHours,
    @Default([]) List<String> conditions,
    @Default([]) List<String> ageGroups,
    bool? isOpenNow,
    bool? isClosingSoon,
    bool? emergencyAvailable,
    bool? acceptsWalkIns,
    bool? hasQueue,
    int? queueLength,
    int? waitEstimateMinutes,
    DateTime? nextAvailableSlot,
    bool? availableToday,
    double? rating,
    int? reviewCount,
    String? verificationSource,
    @Default(false) bool isClaimed,
  }) = _ProviderModel;

  factory ProviderModel.fromJson(Map<String, dynamic> json) =>
      _$ProviderModelFromJson(json);
}
