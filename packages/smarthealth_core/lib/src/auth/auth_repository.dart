import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_core/src/auth/secure_storage.dart';
import 'package:smarthealth_core/src/network/dio_client.dart';
import 'package:smarthealth_core/src/security/secure_data_wipe.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
    otpContext: ref.watch(otpContextProvider),
  );
});

/// OTP context: `mobile` for patient app, `staff` or `practitioner` for MyPractice.
final otpContextProvider = Provider<String>((ref) => 'mobile');

enum OtpChannel { email, phone }

class OtpSendResult {
  const OtpSendResult({
    required this.channel,
    required this.destination,
  });

  final OtpChannel channel;
  final String destination;
}

class AuthRepository {
  AuthRepository(
    this._dio,
    this._storage, {
    this.otpContext = 'mobile',
    SecureDataWipe? secureWipe,
  }) : _secureWipe = secureWipe ?? SecureDataWipe();

  final Dio _dio;
  final SecureStorage _storage;
  final String otpContext;
  final SecureDataWipe _secureWipe;

  Future<OtpSendResult> sendOtp({
    required OtpChannel channel,
    String? email,
    String? phone,
    String? context,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/otp/send',
      data: {
        'context': context ?? otpContext,
        'channel': channel.name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      },
    );
    final data = response.data ?? const <String, dynamic>{};
    final apiChannel = data['channel'] as String? ?? channel.name;
    return OtpSendResult(
      channel: apiChannel == 'sms' ? OtpChannel.phone : OtpChannel.email,
      destination: data['destination'] as String? ?? email ?? phone ?? '',
    );
  }

  Future<VerifyOtpResult> verifyOtp({
    required OtpChannel channel,
    required String otp,
    String? email,
    String? phone,
    String? context,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/otp/verify',
      data: {
        'context': context ?? otpContext,
        'channel': channel.name,
        'otp': otp,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      },
    );
    final data = response.data ?? const <String, dynamic>{};
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    if (accessToken == null || refreshToken == null) {
      throw const AuthException('Invalid authentication response');
    }

    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    final user = data['user'] as Map<String, dynamic>? ?? const {};
    return VerifyOtpResult(
      session: AuthSession(
        userId: user['id'] as String? ?? '',
        phone: user['phone'] as String? ?? phone ?? '',
        email: user['email'] as String? ?? email,
        role: user['role'] as String?,
      ),
      practitionerClaim: data['practitionerClaim'] as Map<String, dynamic>?,
    );
  }

  Future<void> signOut() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _dio.post<Map<String, dynamic>>(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      } catch (_) {}
    }
    await _storage.clearTokens();
    await _secureWipe.onSignOut();
  }

  Future<bool> hasSession() => _storage.hasSession();
}

class VerifyOtpResult {
  const VerifyOtpResult({
    required this.session,
    this.practitionerClaim,
  });

  final AuthSession session;
  final Map<String, dynamic>? practitionerClaim;
}

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.phone,
    this.email,
    this.role,
  });

  final String userId;
  final String phone;
  final String? email;
  final String? role;
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

String normalizeZimbabwePhone(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('263')) {
    return '+$digits';
  }
  if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  if (digits.length == 9) {
    return '+263$digits';
  }
  if (input.startsWith('+')) {
    return input.trim();
  }
  return '+263$digits';
}

String? validateZimbabwePhone(String input) {
  final normalized = normalizeZimbabwePhone(input);
  if (!RegExp(r'^\+263[0-9]{9}$').hasMatch(normalized)) {
    return 'Enter a valid Zimbabwe mobile number';
  }
  return null;
}

String? validateEmail(String? input) {
  final value = input?.trim() ?? '';
  if (value.isEmpty) {
    return 'Enter your email address';
  }
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}
