import 'package:smarthealth_shep/core/config/app_config.dart';

/// Hosts allowed to use self-signed TLS in debug builds only.
bool allowDevCertificateForHost(String host) {
  if (!AppConfig.trustDevCertificates) return false;
  return host == 'dev.smarthealth.co.zw';
}
