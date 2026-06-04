import 'package:freezed_annotation/freezed_annotation.dart';

part 'facility_model.freezed.dart';
part 'facility_model.g.dart';

@freezed
abstract class FacilityModel with _$FacilityModel {
  const factory FacilityModel({
    required String id,
    required String name,
    required String slug,
    required String facilityType,
    String? description,
    String? addressLine1,
    required String city,
    required String province,
    String? phone,
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
}
