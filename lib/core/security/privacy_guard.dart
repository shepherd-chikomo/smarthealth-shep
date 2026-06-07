import 'dart:developer' as developer;

/// Prevents accidental PHI logging and marks sensitive screens.
abstract final class PrivacyGuard {
  static const sensitiveRoutes = {
    '/profile/emergency',
    '/profile/emergency/edit',
    '/family',
    '/profile/backup',
  };

  static void log(String message, {String name = 'App', Object? error}) {
    if (_containsPhiHint(message)) return;
    developer.log(message, name: name, error: error);
  }

  static bool _containsPhiHint(String message) {
    final lower = message.toLowerCase();
    const blocked = [
      'allerg',
      'medication',
      'blood group',
      'diagnosis',
      'condition',
      'health vault',
    ];
    return blocked.any(lower.contains);
  }
}
