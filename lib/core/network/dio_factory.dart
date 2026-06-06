import 'package:dio/dio.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/network/dio_dev_certs_io.dart'
    if (dart.library.html) 'package:smarthealth_shep/core/network/dio_dev_certs_stub.dart';

BaseOptions apiBaseOptions() => BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    );

/// Shared Dio instance options for all API clients.
Dio createApiDio({BaseOptions? options}) {
  final dio = Dio(options ?? apiBaseOptions());
  if (AppConfig.trustDevCertificates) {
    applyDevCertificateBypass(dio);
  }
  return dio;
}
