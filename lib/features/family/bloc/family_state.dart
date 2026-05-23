import 'package:equatable/equatable.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

enum FamilyStatus { initial, loading, loaded, saving, error }

class FamilyState extends Equatable {
  const FamilyState({
    this.status = FamilyStatus.initial,
    this.members = const [],
    this.isOffline = false,
    this.pendingSync = false,
    this.errorMessage,
  });

  final FamilyStatus status;
  final List<FamilyMemberModel> members;
  final bool isOffline;
  final bool pendingSync;
  final String? errorMessage;

  FamilyState copyWith({
    FamilyStatus? status,
    List<FamilyMemberModel>? members,
    bool? isOffline,
    bool? pendingSync,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FamilyState(
      status: status ?? this.status,
      members: members ?? this.members,
      isOffline: isOffline ?? this.isOffline,
      pendingSync: pendingSync ?? this.pendingSync,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, members, isOffline, pendingSync, errorMessage];
}
