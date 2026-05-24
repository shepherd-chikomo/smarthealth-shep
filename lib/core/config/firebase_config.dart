/// Firebase configuration — replace with FlutterFire CLI output for production.
/// Run: flutterfire configure
class FirebaseConfig {
  FirebaseConfig._();

  static const String projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'smarthealth-dev',
  );

  static const String apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyDevPlaceholder',
  );

  static const String appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:000000000000:android:placeholder',
  );

  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '000000000000',
  );

  static bool get isConfigured =>
      !apiKey.contains('Placeholder') && !appId.contains('placeholder');
}
