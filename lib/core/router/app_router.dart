import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/features/appointments/appointments_placeholder.dart';
import 'package:smarthealth_shep/features/design_system/design_system_demo_screen.dart';
import 'package:smarthealth_shep/features/emergency/emergency_screen.dart';
import 'package:smarthealth_shep/features/home/home_screen.dart';
import 'package:smarthealth_shep/features/profile/settings_screen.dart';
import 'package:smarthealth_shep/features/provider_profile/provider_profile_screen.dart';
import 'package:smarthealth_shep/features/search/directory_results_screen.dart';
import 'package:smarthealth_shep/features/search/models/search_criteria.dart';
import 'package:smarthealth_shep/features/search/search_screen.dart';
import 'package:smarthealth_shep/features/splash/splash_screen.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/design-demo',
        builder: (context, state) => const DesignSystemDemoScreen(),
      ),
      GoRoute(
        path: '/provider/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProviderProfileScreen(providerId: id);
        },
      ),
      GoRoute(
        path: '/search/results',
        builder: (context, state) {
          final criteria = state.extra! as SearchCriteria;
          return DirectoryResultsScreen(criteria: criteria);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/emergency',
                builder: (context, state) => const EmergencyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (context, state) =>
                    const AppointmentsPlaceholder(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
