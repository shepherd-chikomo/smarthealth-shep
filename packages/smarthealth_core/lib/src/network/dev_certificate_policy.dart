import 'package:smarthealth_core/src/config/app_config.dart';

bool allowDevCertificateForHost(String host) {
  if (!AppConfig.trustDevCertificates) return false;
  return host == 'dev.smarthealth.co.zw';
}
