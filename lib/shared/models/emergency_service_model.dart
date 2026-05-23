import 'package:freezed_annotation/freezed_annotation.dart';

part 'emergency_service_model.freezed.dart';
part 'emergency_service_model.g.dart';

@freezed
abstract class EmergencyServiceModel with _$EmergencyServiceModel {
  const factory EmergencyServiceModel({
    required String id,
    required String name,
    required String phone,
    String? whatsapp,
    @Default(false) bool is24Hours,
  }) = _EmergencyServiceModel;

  factory EmergencyServiceModel.fromJson(Map<String, dynamic> json) =>
      _$EmergencyServiceModelFromJson(json);
}
