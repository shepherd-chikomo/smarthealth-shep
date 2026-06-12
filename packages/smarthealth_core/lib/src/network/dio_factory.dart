import 'package:dio/dio.dart';
import 'package:smarthealth_core/src/config/app_config.dart';
import 'package:smarthealth_core/src/network/dio_dev_certs_io.dart'
    if (dart.library.html) 'package:smarthealth_core/src/network/dio_dev_certs_stub.dart';

BaseOptions apiBaseOptions() => BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    );

Dio createApiDio({BaseOptions? options}) {
  final dio = Dio(options ?? apiBaseOptions());
  if (AppConfig.trustDevCertificates) {
    applyDevCertificateBypass(dio);
  }
  return dio;
}
