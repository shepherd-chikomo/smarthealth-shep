import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/remote/facility_api_client.dart';
import 'package:my_practice/data/remote/claims_api_client.dart';
import 'package:my_practice/data/sync/sync_engine.dart';
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

final claimsApiClientProvider = Provider<ClaimsApiClient>((ref) {
  return ClaimsApiClient(ref.watch(dioProvider));
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

final syncEngineProvider = Provider<SyncEngine?>((ref) {
  if (MyPracticeConfig.skipAuthForTesting) return null;

  final facilityId = ref.watch(facilityIdProvider);
  if (facilityId == null) return null;

  return SyncEngine(
    db: ref.watch(appDatabaseProvider),
    api: SyncApiClient(ref.watch(facilityDioProvider), facilityId: facilityId),
  );
});
