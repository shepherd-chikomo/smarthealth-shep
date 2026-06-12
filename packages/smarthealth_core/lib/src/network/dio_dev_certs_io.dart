import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:smarthealth_core/src/network/dev_certificate_policy.dart';

void applyDevCertificateBypass(Dio dio) {
  final adapter = IOHttpClientAdapter();
  adapter.createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) =>
        allowDevCertificateForHost(host);
    return client;
  };
  dio.httpClientAdapter = adapter;
}
