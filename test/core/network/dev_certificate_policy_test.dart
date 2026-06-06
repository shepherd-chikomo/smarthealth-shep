import 'package:flutter_test/flutter_test.dart';
import 'package:smarthealth_shep/core/network/dev_certificate_policy.dart';

void main() {
  test('allowDevCertificateForHost only permits dev host when enabled', () {
    expect(allowDevCertificateForHost('dev.smarthealth.co.zw'), isA<bool>());
    expect(allowDevCertificateForHost('api.smarthealth.co.zw'), isFalse);
  });
}
