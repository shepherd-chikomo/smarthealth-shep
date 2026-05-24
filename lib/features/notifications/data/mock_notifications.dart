import 'package:smarthealth_shep/features/notifications/models/notification_model.dart';

/// Seed notifications for offline/demo inbox UX.
abstract final class MockNotifications {
  static List<AppNotification>? _cache;

  static List<AppNotification> seed({DateTime? now}) {
    if (_cache != null) return List.unmodifiable(_cache!);

    final base = now ?? DateTime.now();
    _cache = [
      AppNotification(
        id: 'n1',
        title: "You're next",
        body: 'Please proceed to Room 3. Dr. Tendai Moyo is ready for you.',
        channel: 'in_app',
        status: 'delivered',
        category: NotificationCategory.queueUpdate,
        actionUrl: 'smarthealth:///queue/queue_demo_1',
        payload: const {
          'queueEvent': 'youre_next',
          'ticketNumber': '042',
          'sessionId': 'queue_demo_1',
        },
        createdAt: base.subtract(const Duration(minutes: 2)),
      ),
      AppNotification(
        id: 'n2',
        title: 'Appointment tomorrow',
        body: 'Dr. Rumbidzai Chiweshe · Avenues Clinic · 10:30 AM',
        channel: 'in_app',
        status: 'delivered',
        category: NotificationCategory.appointmentReminder,
        actionUrl: 'smarthealth:///bookings',
        payload: const {'appointmentEvent': 'tomorrow'},
        createdAt: base.subtract(const Duration(minutes: 18)),
      ),
      AppNotification(
        id: 'n3',
        title: 'Appointment confirmed',
        body: 'Your booking with Dr. Tendai Moyo is confirmed for today.',
        channel: 'in_app',
        status: 'delivered',
        category: NotificationCategory.appointmentConfirmed,
        actionUrl: 'smarthealth:///bookings',
        payload: const {'appointmentEvent': 'confirmed'},
        createdAt: base.subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'n4',
        title: 'Queue delayed',
        body: 'Estimated wait is now ~25 minutes due to high patient volume.',
        channel: 'in_app',
        status: 'delivered',
        category: NotificationCategory.queueUpdate,
        actionUrl: 'smarthealth:///queue/queue_demo_1',
        payload: const {
          'queueEvent': 'delayed',
          'ticketNumber': '042',
          'sessionId': 'queue_demo_1',
        },
        readAt: base.subtract(const Duration(minutes: 30)),
        createdAt: base.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'n5',
        title: 'Appointment rescheduled',
        body: 'Skin Health Harare moved your visit to Thu, 4:30 PM.',
        channel: 'in_app',
        status: 'delivered',
        category: NotificationCategory.appointmentRescheduled,
        actionUrl: 'smarthealth:///bookings',
        payload: const {'appointmentEvent': 'rescheduled'},
        readAt: base.subtract(const Duration(hours: 1)),
        createdAt: base.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'n6',
        title: 'Appointment cancelled',
        body: 'Smile Dental Centre cancelled your appointment for today.',
        channel: 'in_app',
        status: 'delivered',
        category: NotificationCategory.appointmentCancellation,
        actionUrl: 'smarthealth:///bookings',
        createdAt: base.subtract(const Duration(hours: 8)),
      ),
      AppNotification(
        id: 'n7',
        title: 'MDPCZ verification approved',
        body: 'Dr. Tendai Moyo is now MDPCZ verified on SmartHealth.',
        channel: 'in_app',
        status: 'delivered',
        category: NotificationCategory.verificationUpdate,
        actionUrl: 'smarthealth:///provider/p1',
        payload: const {'providerId': 'p1'},
        createdAt: base.subtract(const Duration(days: 1, hours: 2)),
      ),
      AppNotification(
        id: 'n8',
        title: 'Facility claim approved',
        body: 'Parirenyatwa Hospital ownership claim has been approved.',
        channel: 'in_app',
        status: 'delivered',
        category: NotificationCategory.claimApproval,
        actionUrl: 'smarthealth:///home',
        createdAt: base.subtract(const Duration(days: 2)),
      ),
      AppNotification(
        id: 'n9',
        title: 'Queue paused',
        body: 'The clinic queue is temporarily paused. You will be notified when it resumes.',
        channel: 'in_app',
        status: 'delivered',
        category: NotificationCategory.queueUpdate,
        payload: const {'queueEvent': 'paused', 'ticketNumber': '038'},
        readAt: base.subtract(const Duration(days: 1)),
        createdAt: base.subtract(const Duration(days: 3)),
      ),
      AppNotification(
        id: 'n10',
        title: 'Emergency services nearby',
        body: '24-hour emergency care is available 1.2 km from your location.',
        channel: 'in_app',
        status: 'delivered',
        category: NotificationCategory.emergencyAlert,
        actionUrl: 'smarthealth:///emergency',
        createdAt: base.subtract(const Duration(days: 4)),
      ),
    ];
    return List.unmodifiable(_cache!);
  }

  static void markRead(String id) {
    seed();
    final index = _cache!.indexWhere((n) => n.id == id);
    if (index == -1) return;
    final n = _cache![index];
    _cache![index] = AppNotification(
      id: n.id,
      title: n.title,
      body: n.body,
      channel: n.channel,
      status: n.status,
      category: n.category,
      actionUrl: n.actionUrl,
      payload: n.payload,
      readAt: DateTime.now(),
      createdAt: n.createdAt,
    );
  }

  static void markAllRead() {
    seed();
    final now = DateTime.now();
    _cache = _cache!
        .map(
          (n) => AppNotification(
            id: n.id,
            title: n.title,
            body: n.body,
            channel: n.channel,
            status: n.status,
            category: n.category,
            actionUrl: n.actionUrl,
            payload: n.payload,
            readAt: n.readAt ?? now,
            createdAt: n.createdAt,
          ),
        )
        .toList();
  }

  static int unreadCount() {
    return seed().where((n) => n.isUnread).length;
  }
}
