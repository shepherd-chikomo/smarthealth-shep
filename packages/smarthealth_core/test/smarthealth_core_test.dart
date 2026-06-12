import 'package:flutter_test/flutter_test.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

void main() {
  test('AppConfig exposes api base url', () {
    expect(AppConfig.apiBaseUrl, isNotEmpty);
  });

  test('SecureStorage can be constructed', () {
    expect(SecureStorage(), isA<SecureStorage>());
  });
}
