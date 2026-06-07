import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/auth/auth_state.dart';
import 'package:smarthealth_shep/core/auth/dev_auth_bypass.dart';
import 'package:smarthealth_shep/core/cloud/cloud_account_repository.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';

class PatientProfile {
  const PatientProfile({
    this.id,
    this.smarthealthPatientId,
    this.firstName,
    this.lastName,
    this.displayName,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.gender,
  });

  final String? id;
  final String? smarthealthPatientId;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? phone;
  final String? email;
  final String? dateOfBirth;
  final String? gender;

  String? get greetingName {
    final first = firstName?.trim();
    if (first != null && first.isNotEmpty) return first;
    final display = displayName?.trim();
    if (display != null && display.isNotEmpty) {
      return display.split(RegExp(r'\s+')).first;
    }
    return null;
  }

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as String?,
      smarthealthPatientId: json['smarthealthPatientId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      displayName: json['displayName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
    );
  }
}

final patientProfileProvider = FutureProvider<PatientProfile?>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (!auth.isAuthenticated) return null;

  if (AppConfig.skipAuthForTesting) {
    return DevAuthBypass.profile;
  }

  final cloudRepo = ref.watch(cloudAccountRepositoryProvider);
  final account = await cloudRepo.fetchAndCache();
  if (account == null) return null;
  return PatientProfile(
    id: account.accountUuid,
    smarthealthPatientId: account.smarthealthPatientId,
    firstName: account.firstName,
    lastName: account.lastName,
    displayName: account.displayName,
    phone: account.phone,
    email: account.email,
    dateOfBirth: account.dateOfBirth,
    gender: account.gender,
  );
});
