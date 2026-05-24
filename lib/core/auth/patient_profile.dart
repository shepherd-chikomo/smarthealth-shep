import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/auth/auth_state.dart';
import 'package:smarthealth_shep/core/auth/dev_auth_bypass.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';

class PatientProfile {
  const PatientProfile({
    this.firstName,
    this.lastName,
    this.displayName,
    this.phone,
    this.email,
  });

  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? phone;
  final String? email;

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
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      displayName: json['displayName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }
}

final patientProfileProvider = FutureProvider<PatientProfile?>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (!auth.isAuthenticated) return null;

  if (AppConfig.skipAuthForTesting) {
    return DevAuthBypass.profile;
  }

  try {
    final dio = ref.watch(dioProvider);
    final response = await dio.get<Map<String, dynamic>>('/patients/me');
    final profileJson =
        response.data?['profile'] as Map<String, dynamic>? ?? const {};
    return PatientProfile.fromJson(profileJson);
  } on DioException {
    return null;
  }
});
