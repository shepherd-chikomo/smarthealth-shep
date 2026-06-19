import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/design_system/screens/design_preview_screen.dart';
import 'package:my_practice/design_system/screens/design_system_screen.dart';
import 'package:my_practice/features/auth/facility_picker_screen.dart';
import 'package:my_practice/features/auth/login_screen.dart';
import 'package:my_practice/features/auth/otp_screen.dart';
import 'package:my_practice/features/calendar/calendar_screen.dart';
import 'package:my_practice/features/claims/claims_screen.dart';
import 'package:my_practice/features/clinical/encounter_screen.dart';
import 'package:my_practice/features/clinical/patient_chart_screen.dart';
import 'package:my_practice/features/dashboard/dashboard_screen.dart';
import 'package:my_practice/features/facility/facility_screen.dart';
import 'package:my_practice/features/future/future_module_screen.dart';
import 'package:my_practice/features/messaging/messaging_screen.dart';
import 'package:my_practice/features/patients/patient_search_screen.dart';
import 'package:my_practice/features/queue/queue_screen.dart';
import 'package:my_practice/features/reports/reports_screen.dart';
import 'package:my_practice/features/splash/splash_screen.dart';
import 'package:my_practice/shared/widgets/practice_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isAuthRoute = loc.startsWith('/login') || loc.startsWith('/otp');
      final isSplash = loc == '/splash';
      final isDesignRoute =
          loc.startsWith('/design-preview') || loc.startsWith('/design-system');

      if (isDesignRoute) return null;

      if (auth.status == AuthStatus.unknown || isSplash) return null;

      if (auth.status == AuthStatus.unauthenticated && !isAuthRoute) {
        return '/login';
      }

      if (auth.status == AuthStatus.needsFacility &&
          loc != '/facility-picker') {
        return '/facility-picker';
      }

      if (auth.status == AuthStatus.authenticated && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/design-preview',
        builder: (_, __) => const DesignPreviewScreen(),
      ),
      GoRoute(
        path: '/design-system',
        builder: (_, __) => const DesignSystemScreen(),
      ),
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/otp', builder: (_, __) => const OtpScreen()),
      GoRoute(
        path: '/facility-picker',
        builder: (_, __) => const FacilityPickerScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            PracticeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (_, __) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/queue', builder: (_, __) => const QueueScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (_, __) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patients',
                builder: (_, __) => const PatientSearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (_, __) => const FacilityScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/patients/:id/chart',
        builder: (_, state) =>
            PatientChartScreen(patientId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/encounter/:patientId',
        builder: (_, state) => EncounterScreen(
          patientId: state.pathParameters['patientId']!,
          consultationId: state.uri.queryParameters['consultationId'],
          queueEntryId: state.uri.queryParameters['queueEntryId'],
        ),
      ),
      GoRoute(path: '/facility', builder: (_, __) => const FacilityScreen()),
      GoRoute(path: '/claims', builder: (_, __) => const ClaimsScreen()),
      GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
      GoRoute(path: '/messages', builder: (_, __) => const MessagingScreen()),
      GoRoute(
        path: '/future/:module',
        builder: (_, state) => FutureModuleScreen(
          moduleKey: state.pathParameters['module']!,
        ),
      ),
    ],
  );
});
