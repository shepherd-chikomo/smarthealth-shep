import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/features/notifications/data/mock_notifications.dart';
import 'package:smarthealth_shep/features/notifications/models/notification_model.dart';

class NotificationRepository {
  NotificationRepository(this._dio);

  final Dio _dio;

  bool _useMock = false;

  bool get _mockEnabled => AppConfig.allowMockFallbacks && _useMock;

  Future<List<AppNotification>> listNotifications({
    int page = 1,
    int limit = 50,
    bool unreadOnly = false,
    String? category,
  }) async {
    if (_mockEnabled) {
      var items = MockNotifications.seed();
      if (unreadOnly) items = items.where((n) => n.isUnread).toList();
      if (category != null) {
        items = items.where((n) => n.category.value == category).toList();
      }
      return items;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (unreadOnly) 'unreadOnly': true,
          if (category != null) 'category': category,
        },
      );
      final list = response.data?['notifications'] as List<dynamic>? ?? [];
      return list
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (error) {
      if (AppConfig.allowMockFallbacks) {
        _useMock = true;
        return listNotifications(
          page: page,
          limit: limit,
          unreadOnly: unreadOnly,
          category: category,
        );
      }
      if (kDebugMode) {
        debugPrint('NotificationRepository.listNotifications failed: $error');
      }
      rethrow;
    }
  }

  Future<int> unreadCount() async {
    if (_mockEnabled) return MockNotifications.unreadCount();

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/notifications/unread-count',
      );
      return response.data?['count'] as int? ?? 0;
    } catch (error) {
      if (AppConfig.allowMockFallbacks) {
        _useMock = true;
        return MockNotifications.unreadCount();
      }
      if (kDebugMode) {
        debugPrint('NotificationRepository.unreadCount failed: $error');
      }
      return 0;
    }
  }

  Future<void> markRead(String id) async {
    if (_mockEnabled) {
      MockNotifications.markRead(id);
      return;
    }

    try {
      await _dio.patch('/notifications/$id/read');
    } catch (error) {
      if (AppConfig.allowMockFallbacks) {
        _useMock = true;
        MockNotifications.markRead(id);
        return;
      }
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    if (_mockEnabled) {
      MockNotifications.markAllRead();
      return;
    }

    try {
      await _dio.patch('/notifications/read-all');
    } catch (error) {
      if (AppConfig.allowMockFallbacks) {
        _useMock = true;
        MockNotifications.markAllRead();
        return;
      }
      rethrow;
    }
  }

  Future<void> registerPushToken({
    required String token,
    required String platform,
  }) async {
    await _dio.post(
      '/notifications/push-token',
      data: {'token': token, 'platform': platform},
    );
  }

  Future<void> deactivatePushToken(String token) async {
    await _dio.delete(
      '/notifications/push-token',
      data: {'token': token},
    );
  }

  Future<List<NotificationPreference>> listPreferences() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notifications/preferences',
    );
    final list = response.data?['preferences'] as List<dynamic>? ?? [];
    return list
        .map((e) => NotificationPreference.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updatePreference({
    required String channel,
    required String category,
    required bool isEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) async {
    await _dio.put(
      '/notifications/preferences',
      data: {
        'channel': channel,
        'category': category,
        'isEnabled': isEnabled,
        if (quietHoursStart != null) 'quietHoursStart': quietHoursStart,
        if (quietHoursEnd != null) 'quietHoursEnd': quietHoursEnd,
      },
    );
  }
}
