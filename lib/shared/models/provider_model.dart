import 'package:freezed_annotation/freezed_annotation.dart';

part 'provider_model.freezed.dart';
part 'provider_model.g.dart';

@freezed
abstract class ProviderModel with _$ProviderModel {
  const factory ProviderModel({
    required String id,
    required String name,
    required String categoryId,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
    String? imageUrl,
    @Default(false) bool isVerified,
  }) = _ProviderModel;

  factory ProviderModel.fromJson(Map<String, dynamic> json) =>
      _$ProviderModelFromJson(json);
}
