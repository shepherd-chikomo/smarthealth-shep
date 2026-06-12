import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

/// Staff/practitioner OTP context for MyPractice.
final myPracticeOtpContextProvider = Provider<String>((ref) => 'staff');

final myPracticeAuthRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
    otpContext: ref.watch(myPracticeOtpContextProvider),
  );
});

final facilityIdProvider = NotifierProvider<FacilityIdNotifier, String?>(
  FacilityIdNotifier.new,
);

class FacilityIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

/// Dio with X-Facility-Id header for facility-scoped calls.
final facilityDioProvider = Provider<Dio>((ref) {
  final facilityId = ref.watch(facilityIdProvider);
  final dio = createApiDio();
  dio.interceptors.add(
    AuthInterceptor(ref.watch(secureStorageProvider), dio),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (facilityId != null && facilityId.isNotEmpty) {
          options.headers['X-Facility-Id'] = facilityId;
        }
        handler.next(options);
      },
    ),
  );
  return dio;
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Override in main.dart');
});
