import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_member_model.freezed.dart';
part 'family_member_model.g.dart';

@freezed
abstract class FamilyMemberModel with _$FamilyMemberModel {
  const factory FamilyMemberModel({
    required String id,
    required String name,
    required String relationship,
    String? dateOfBirth,
  }) = _FamilyMemberModel;

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberModelFromJson(json);
}
