import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/features/notifications/data/notification_repository.dart';
import 'package:smarthealth_shep/features/notifications/services/push_notification_service.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationRepository(dio);
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.unreadCount();
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref.watch(notificationRepositoryProvider));
});
