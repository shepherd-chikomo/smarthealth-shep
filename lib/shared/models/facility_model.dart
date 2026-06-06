import 'package:freezed_annotation/freezed_annotation.dart';

part 'facility_model.freezed.dart';
part 'facility_model.g.dart';

@freezed
abstract class FacilityModel with _$FacilityModel {
  const FacilityModel._();

  const factory FacilityModel({
    required String id,
    required String name,
    required String slug,
    required String facilityType,
    @Default([]) List<String> facilityTypes,
    String? description,
    String? addressLine1,
    required String city,
    required String province,
    String? phone,
    String? whatsappPhone,
    String? email,
    String? website,
    double? latitude,
    double? longitude,
    double? distanceKm,
    @Default(false) bool isVerified,
    String? logoPath,
  }) = _FacilityModel;

  factory FacilityModel.fromJson(Map<String, dynamic> json) =>
      _$FacilityModelFromJson(json);

  bool matchesCategory(String categoryId) {
    if (facilityTypes.isNotEmpty) {
      return facilityTypes.contains(categoryId);
    }
    return facilityType == categoryId;
  }
}
