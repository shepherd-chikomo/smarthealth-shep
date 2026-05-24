import 'package:firebase_messaging/firebase_messaging.dart';

/// Top-level background handler — must not be in a class.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background delivery handled by OS; local notification shown if needed.
}
