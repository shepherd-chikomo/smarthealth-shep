import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarthealth_shep/core/auth/secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'read':
          return null;
        case 'write':
        case 'delete':
        case 'deleteAll':
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('SecureStorage', () {
    test('hasSession returns false when no token stored', () async {
      final storage = SecureStorage();
      await storage.clearTokens();
      expect(await storage.hasSession(), isFalse);
    });
  });
}
