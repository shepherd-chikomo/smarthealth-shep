import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/config/firebase_config.dart';
import 'package:smarthealth_shep/core/notifications/background_message_handler.dart';
import 'package:smarthealth_shep/features/notifications/data/notification_repository.dart';
import 'package:smarthealth_shep/features/notifications/services/deep_link_handler.dart';

class PushNotificationService {
  PushNotificationService(this._repository);

  final NotificationRepository _repository;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  GoRouter? _router;

  static const _androidChannel = AndroidNotificationChannel(
    'smarthealth_alerts',
    'SmartHealth Alerts',
    description: 'Appointment reminders, emergency alerts, and messages',
    importance: Importance.high,
  );

  Future<void> initialize({GoRouter? router}) async {
    _router = router;

    await _initLocalNotifications();

    if (!FirebaseConfig.isConfigured || kIsWeb) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    final token = await messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    messaging.onTokenRefresh.listen(_registerToken);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _onMessageOpened(message);
    });
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && _router != null) {
          DeepLinkHandler.navigate(_router!, actionUrl: payload);
        }
      },
    );
  }

  Future<void> _registerToken(String token) async {
    final platform = Platform.isIOS
        ? 'ios'
        : Platform.isAndroid
            ? 'android'
            : 'web';
    try {
      await _repository.registerPushToken(token: token, platform: platform);
    } catch (_) {
      // Auth may not be ready yet — retried on next launch.
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final actionUrl = message.data['actionUrl'] as String?;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: actionUrl,
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    if (_router == null) return;
    DeepLinkHandler.navigate(
      _router!,
      actionUrl: message.data['actionUrl'] as String?,
      data: message.data,
    );
  }
}
