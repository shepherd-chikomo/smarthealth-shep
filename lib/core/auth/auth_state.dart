import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/auth/auth_repository.dart';
import 'package:smarthealth_shep/core/auth/dev_auth_bypass.dart';
import 'package:smarthealth_shep/core/backup/backup_discovery_service.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_repository.dart';

/// Notifies [GoRouter] when authentication state changes.
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
    this.isAuthenticated = false,
    this.isLoading = true,
    this.phone,
    this.firstName,
    this.email,
    this.isDevBypass = false,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final String? phone;
  final String? firstName;
  final String? email;
  /// True when signed in via [AppConfig.skipAuthForTesting] (debug only).
  final bool isDevBypass;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? phone,
    String? firstName,
    String? email,
    bool? isDevBypass,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      isDevBypass: isDevBypass ?? this.isDevBypass,
    );
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  AuthRepository get _auth => ref.read(authRepositoryProvider);
  AuthRefreshListenable get _refresh =>
      ref.read(authRefreshListenableProvider);

  @override
  AuthState build() {
    Future.microtask(refresh);
    return const AuthState(isLoading: true);
  }

  Future<void> refresh() async {
    if (AppConfig.skipAuthForTesting) {
      state = const AuthState(
        isAuthenticated: true,
        isLoading: false,
        phone: DevAuthBypass.phone,
        firstName: DevAuthBypass.firstName,
        email: DevAuthBypass.email,
        isDevBypass: true,
      );
      _refresh.notifyAuthChanged();
      return;
    }

    final hasSession = await _auth.hasSession();
    state = state.copyWith(isAuthenticated: hasSession, isLoading: false);
    _refresh.notifyAuthChanged();
  }

  Future<void> completeSignIn(AuthSession session) async {
    if (!AppConfig.skipAuthForTesting) {
      final needsRestore = await HealthVaultRepository().needsRestoreFromBackup();
      if (needsRestore) {
        await BackupDiscoveryService.markAwaitingRestore();
      }
    }

    state = AuthState(
      isAuthenticated: true,
      isLoading: false,
      phone: session.phone,
      email: session.email,
    );
    _refresh.notifyAuthChanged();
  }

  Future<void> signOut() async {
    if (AppConfig.skipAuthForTesting) {
      state = const AuthState(isAuthenticated: false, isLoading: false);
      _refresh.notifyAuthChanged();
      return;
    }
    await _auth.signOut();
    state = const AuthState(isAuthenticated: false, isLoading: false);
    _refresh.notifyAuthChanged();
  }
}
