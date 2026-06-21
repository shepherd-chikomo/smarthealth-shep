import 'package:smarthealth_shep/core/backup/health_vault_backup_service.dart';

/// Holds the resolved post-login route while auth state transitions on OTP sign-in.
abstract final class PostAuthNavigation {
  static String? pendingRoute;

  static Future<String> resolveRoute() =>
      HealthVaultBackupService.resolvePostAuthRoute();

  /// Caches the route so [GoRouter] redirect can use it when OTP unmounts.
  static Future<String> resolveRouteForOtpSignIn() async {
    final route = await resolveRoute();
    pendingRoute = route;
    return route;
  }

  static String consumePendingRoute() {
    final route = pendingRoute ?? '/home';
    pendingRoute = null;
    return route;
  }

  static void clear() {
    pendingRoute = null;
  }
}
