import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/sync/sync_notifier.dart';
import 'package:my_practice/domain/models/portal_profile.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

enum AuthStatus { unknown, unauthenticated, authenticated, needsFacility }

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.profile,
    this.error,
  });

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  final AuthStatus status;
  final AuthSession? session;
  final PortalProfile? profile;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    PortalProfile? profile,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

final authStateProvider =
    NotifierProvider<AuthStateNotifier, AuthState>(AuthStateNotifier.new);

class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(_bootstrap);
    return const AuthState.unknown();
  }

  Future<void> _bootstrap() async {
    if (MyPracticeConfig.skipAuthForTesting) {
      state = AuthState(
        status: AuthStatus.authenticated,
        session: const AuthSession(
          userId: 'dev-user',
          phone: '+263771234567',
          email: 'dev@smarthealth.co.zw',
          role: 'doctor',
        ),
        profile: PortalProfile(
          id: 'dev-user',
          role: 'doctor',
          firstName: 'Dev',
          lastName: 'Practitioner',
          email: 'dev@smarthealth.co.zw',
          facilities: const [
            FacilityMembership(
              id: 'seed-facility-001',
              name: 'Avenues Clinic (Seed)',
              role: 'doctor',
            ),
          ],
        ),
      );
      ref.read(facilityIdProvider.notifier).select('seed-facility-001');
      return;
    }

    final repo = ref.read(myPracticeAuthRepositoryProvider);
    if (!await repo.hasSession()) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    await loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get<Map<String, dynamic>>('/facility/me');
      final profile = PortalProfile.fromJson(
        res.data?['profile'] as Map<String, dynamic>? ?? res.data ?? {},
      );
      final facilityId = ref.read(facilityIdProvider);
      if (profile.facilities.isEmpty) {
        state = AuthState(
          status: AuthStatus.needsFacility,
          profile: profile,
          session: state.session,
        );
        return;
      }

      if (facilityId == null) {
        if (profile.facilities.length == 1) {
          await selectFacility(profile.facilities.first.id);
          return;
        }
        state = AuthState(
          status: AuthStatus.needsFacility,
          profile: profile,
          session: state.session,
        );
        return;
      }

      state = AuthState(
        status: AuthStatus.authenticated,
        profile: profile,
        session: state.session,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> selectFacility(String facilityId) async {
    ref.read(facilityIdProvider.notifier).select(facilityId);
    state = state.copyWith(status: AuthStatus.authenticated);
    if (!MyPracticeConfig.skipAuthForTesting) {
      await ref.read(syncNotifierProvider.notifier).syncNow();
    }
  }

  Future<void> signOut() async {
    await ref.read(myPracticeAuthRepositoryProvider).signOut();
    ref.read(facilityIdProvider.notifier).select(null);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
