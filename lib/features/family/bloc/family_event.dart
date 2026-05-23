import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

sealed class FamilyEvent extends Equatable {
  const FamilyEvent();

  @override
  List<Object?> get props => [];
}

final class LoadMembers extends FamilyEvent {
  const LoadMembers();
}

final class AddMember extends FamilyEvent {
  const AddMember(this.member);

  final FamilyMemberModel member;

  @override
  List<Object?> get props => [member];
}

final class UpdateMember extends FamilyEvent {
  const UpdateMember(this.member);

  final FamilyMemberModel member;

  @override
  List<Object?> get props => [member];
}

final class DeleteMember extends FamilyEvent {
  const DeleteMember(this.memberId);

  final String memberId;

  @override
  List<Object?> get props => [memberId];
}
