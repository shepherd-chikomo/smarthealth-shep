import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/remote/claims_api_client.dart';
import 'package:my_practice/data/sync/sync_notifier.dart';
import 'package:my_practice/domain/models/portal_profile.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

enum AuthStatus { unknown, unauthenticated, authenticated, needsFacility }

/// Notifies [GoRouter] to re-run redirects without recreating the router.
final authRefreshListenableProvider = Provider<AuthRefreshListenable>((ref) {
  final listenable = AuthRefreshListenable();
  ref.onDispose(listenable.dispose);
  return listenable;
});

class AuthRefreshListenable extends ChangeNotifier {
  void notifyAuthChanged() => notifyListeners();
}

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
  AuthRefreshListenable get _routerRefresh =>
      ref.read(authRefreshListenableProvider);

  void _emit(AuthState next) {
    state = next;
    _routerRefresh.notifyAuthChanged();
  }

  @override
  AuthState build() {
    Future.microtask(_bootstrap);
    return const AuthState.unknown();
  }

  Future<void> _bootstrap() async {
    if (MyPracticeConfig.skipAuthForTesting) {
      _emit(AuthState(
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
      ));
      ref.read(facilityIdProvider.notifier).select('seed-facility-001');
      return;
    }

    final repo = ref.read(myPracticeAuthRepositoryProvider);
    if (!await repo.hasSession()) {
      _emit(const AuthState(status: AuthStatus.unauthenticated));
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
      await _applyProfile(profile);
    } on DioException catch (e) {
      final message = extractApiError(e) ??
          'This account does not have access to MyPractice.';
      _emit(AuthState(
        status: AuthStatus.unauthenticated,
        error: message,
        session: state.session,
      ));
    } catch (e) {
      _emit(AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
        session: state.session,
      ));
    }
  }

  Future<void> _applyProfile(PortalProfile profile) async {
    final facilityId = ref.read(facilityIdProvider);

    if (profile.facilities.isNotEmpty) {
      final hasClaimableLinked =
          profile.linkedFacilities.any((f) => f.canClaimOwnership);
      if (facilityId == null ||
          !profile.facilities.any((f) => f.id == facilityId)) {
        if (profile.facilities.length == 1 && !hasClaimableLinked) {
          await selectFacility(
            profile.facilities.first.id,
            profile: profile,
          );
          return;
        }
        _emit(AuthState(
          status: AuthStatus.needsFacility,
          profile: profile,
          session: state.session,
        ));
        return;
      }

      _emit(AuthState(
        status: AuthStatus.authenticated,
        profile: profile,
        session: state.session,
      ));
      return;
    }

    if (profile.isProviderMode || profile.linkedFacilities.isNotEmpty) {
      _emit(AuthState(
        status: AuthStatus.needsFacility,
        profile: profile,
        session: state.session,
      ));
      return;
    }

    _emit(AuthState(
      status: AuthStatus.needsFacility,
      profile: profile,
      session: state.session,
      error: 'No facilities linked to your account.',
    ));
  }

  Future<void> selectFacility(String facilityId, {PortalProfile? profile}) async {
    ref.read(facilityIdProvider.notifier).select(facilityId);
    _emit(state.copyWith(
      status: AuthStatus.authenticated,
      profile: profile ?? state.profile,
    ));
    if (!MyPracticeConfig.skipAuthForTesting) {
      await ref.read(syncNotifierProvider.notifier).syncNow();
    }
  }

  Future<void> signOut() async {
    await ref.read(myPracticeAuthRepositoryProvider).signOut();
    ref.read(facilityIdProvider.notifier).select(null);
    _emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void mergeLinkedFacilities(List<LinkedFacility> linked) {
    final profile = state.profile;
    if (profile == null || linked.isEmpty) return;
    _emit(state.copyWith(
      profile: PortalProfile(
        id: profile.id,
        role: profile.role,
        firstName: profile.firstName,
        lastName: profile.lastName,
        email: profile.email,
        phone: profile.phone,
        facilities: profile.facilities,
        linkedFacilities: linked,
        provider: profile.provider,
        portalMode: profile.portalMode,
      ),
    ));
  }
}
