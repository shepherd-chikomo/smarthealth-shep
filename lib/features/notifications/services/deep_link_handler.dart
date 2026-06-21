import 'package:go_router/go_router.dart';

/// Resolves notification [actionUrl] and FCM data payloads to GoRouter locations.
class DeepLinkHandler {
  const DeepLinkHandler._();

  static String? resolve({
    String? actionUrl,
    Map<String, dynamic>? data,
  }) {
    final url = actionUrl ?? data?['actionUrl'] as String?;
    if (url == null || url.isEmpty) {
      return _fromCategory(data?['category'] as String?, data);
    }

    if (url.startsWith('smarthealth://')) {
      return _normalizePath(url.replaceFirst('smarthealth://', '/'));
    }

    if (url.startsWith('/')) return _normalizePath(url);
    return _normalizePath('/$url');
  }

  static void navigate(GoRouter router, {String? actionUrl, Map<String, dynamic>? data}) {
    final location = resolve(actionUrl: actionUrl, data: data);
    if (location == null || location.isEmpty || !isRoutable(location)) {
      return;
    }
    router.go(location);
  }

  /// Rejects notification payloads that are not valid app routes.
  static bool isRoutable(String location) {
    if (location.contains('|')) return false;
    const roots = [
      '/',
      '/home',
      '/search',
      '/emergency',
      '/bookings',
      '/profile',
      '/notifications',
      '/login',
      '/onboarding',
      '/provider/',
      '/facility/',
      '/queue/',
      '/booking/',
    ];
    return roots.any(
      (root) => location == root || location.startsWith(root),
    );
  }

  static String? _fromCategory(String? category, Map<String, dynamic>? data) {
    switch (category) {
      case 'appointment_reminder':
      case 'appointment_cancellation':
      case 'appointment_confirmed':
      case 'appointment_rescheduled':
        return '/bookings';
      case 'emergency_alert':
        return '/emergency';
      case 'verification_update':
        final providerId = data?['providerId'] as String?;
        if (providerId != null) return '/provider/$providerId';
        return '/home';
      case 'claim_approval':
        return '/home';
      case 'provider_message':
        final providerId = data?['providerId'] as String?;
        if (providerId != null) return '/provider/$providerId';
        return '/home';
      case 'facility_announcement':
        return '/home';
      case 'queue_update':
        final sessionId = data?['sessionId'] as String?;
        if (sessionId != null) return '/queue/$sessionId';
        return '/home';
      default:
        return '/notifications';
    }
  }

  static String _normalizePath(String path) {
    // Map legacy paths
    if (path == '/appointments') return '/bookings';
    return path.split('?').first;
  }
}
