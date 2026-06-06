import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/auth/auth_repository.dart';
import 'package:smarthealth_shep/core/auth/auth_state.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/features/appointments/screens/appointment_detail_screen.dart';
import 'package:smarthealth_shep/features/appointments/screens/appointments_screen.dart';
import 'package:smarthealth_shep/features/appointments/screens/check_in_screen.dart';
import 'package:smarthealth_shep/features/appointments/screens/reschedule_screen.dart';
import 'package:smarthealth_shep/features/auth/login_screen.dart';
import 'package:smarthealth_shep/features/auth/otp_screen.dart';
import 'package:smarthealth_shep/features/booking/booking_flow_host.dart';
import 'package:smarthealth_shep/features/design_system/design_system_demo_screen.dart';
import 'package:smarthealth_shep/features/emergency/emergency_screen.dart';
import 'package:smarthealth_shep/features/emergency/emergency_service_detail_screen.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_service.dart';
import 'package:smarthealth_shep/features/family/screens/family_members_screen.dart';
import 'package:smarthealth_shep/features/home/home_screen.dart';
import 'package:smarthealth_shep/features/notifications/screens/notification_preferences_screen.dart';
import 'package:smarthealth_shep/features/notifications/screens/notifications_screen.dart';
import 'package:smarthealth_shep/features/onboarding/onboarding_screen.dart';
import 'package:smarthealth_shep/features/profile/settings_screen.dart';
import 'package:smarthealth_shep/features/facility/facility_detail_screen.dart';
import 'package:smarthealth_shep/features/facility/facility_service_picker_screen.dart';
import 'package:smarthealth_shep/features/provider_profile/provider_profile_screen.dart';
import 'package:smarthealth_shep/features/queue/queue_flow_host.dart';
import 'package:smarthealth_shep/features/queue/queue_status_host.dart';
import 'package:smarthealth_shep/features/search/directory_results_screen.dart';
import 'package:smarthealth_shep/features/search/models/search_criteria.dart';
import 'package:smarthealth_shep/features/search/search_map_screen.dart';
import 'package:smarthealth_shep/features/search/search_screen.dart';
import 'package:smarthealth_shep/features/splash/splash_screen.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell.dart';

const _authRequiredPrefixes = [
  '/bookings',
  '/family',
  '/notifications',
  '/booking/',
  '/queue/join/',
];

bool _requiresAuth(String location) {
  for (final prefix in _authRequiredPrefixes) {
    if (location.startsWith(prefix)) return true;
  }
  return false;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRefresh = ref.watch(authRefreshListenableProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (auth.isLoading) return null;

      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location.startsWith('/otp');
      final isPublicEntry =
          location == '/' || location == '/onboarding' || isAuthRoute;

      if (!auth.isAuthenticated && _requiresAuth(location)) {
        return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
      }

      if (auth.isAuthenticated && isAuthRoute) {
        return '/home';
      }

      if (AppConfig.skipAuthForTesting && isAuthRoute) {
        return '/home';
      }

      if (!auth.isAuthenticated && !isPublicEntry && location != '/home') {
        // Allow guest browsing of home, search, emergency, provider profiles.
        if (_requiresAuth(location)) return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final channelName = state.uri.queryParameters['channel'];
          final destination = state.uri.queryParameters['destination'];
          final channel = channelName == 'phone' ? OtpChannel.phone : OtpChannel.email;
          if (destination == null || destination.isEmpty) {
            return const LoginScreen();
          }
          return OtpScreen(
            channel: channel,
            destination: destination,
            email: state.uri.queryParameters['email'],
            phone: state.uri.queryParameters['phone'],
          );
        },
      ),
      if (kDebugMode)
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
        path: '/facility/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
          final distanceKm = double.tryParse(state.uri.queryParameters['distanceKm'] ?? '');
          return FacilityDetailScreen(
            facilityId: id,
            parentTabIndex: tab,
            distanceKm: distanceKm,
          );
        },
        routes: [
          GoRoute(
            path: 'book',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return FacilityServicePickerScreen(facilityId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/booking/:providerId',
        redirect: (context, state) {
          final auth = ref.read(authControllerProvider);
          if (!auth.isAuthenticated) {
            return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
          }
          return null;
        },
        builder: (context, state) {
          final providerId = state.pathParameters['providerId']!;
          final serviceId = state.uri.queryParameters['serviceId'];
          final facilityId = state.uri.queryParameters['facilityId'];
          return BookingFlowHost(
            providerId: providerId,
            facilityId: facilityId,
            serviceId: serviceId,
          );
        },
      ),
      GoRoute(
        path: '/queue/join/:providerId',
        redirect: (context, state) {
          final auth = ref.read(authControllerProvider);
          if (!auth.isAuthenticated) {
            return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
          }
          return null;
        },
        builder: (context, state) {
          final providerId = state.pathParameters['providerId']!;
          return QueueFlowHost(providerId: providerId);
        },
      ),
      GoRoute(
        path: '/queue/:sessionId',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return QueueStatusHost(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/notifications/preferences',
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: '/family',
        builder: (context, state) => const FamilyMembersScreen(),
      ),
      GoRoute(
        path: '/search/results',
        builder: (context, state) {
          final criteria = state.extra! as SearchCriteria;
          return DirectoryResultsScreen(criteria: criteria);
        },
      ),
      GoRoute(
        path: '/search/map',
        builder: (context, state) {
          final criteria = state.extra! as SearchCriteria;
          return SearchMapScreen(criteria: criteria);
        },
      ),
      GoRoute(
        path: '/appointments/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final staffMode = state.uri.queryParameters['staff'] == '1';
          return AppointmentDetailScreen(
            appointmentId: id,
            staffMode: staffMode,
          );
        },
        routes: [
          GoRoute(
            path: 'check-in',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CheckInScreen(appointmentId: id);
            },
          ),
          GoRoute(
            path: 'reschedule',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return RescheduleScreen(appointmentId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/emergency/service/:id',
        builder: (context, state) {
          final service = state.extra! as EmergencyService;
          return EmergencyServiceDetailScreen(service: service);
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
                builder: (context, state) => const AppointmentsScreen(),
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
