import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/auth/auth_repository.dart';

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
  });

  final bool isAuthenticated;
  final bool isLoading;
  final String? phone;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? phone,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      phone: phone ?? this.phone,
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
    final hasSession = await _auth.hasSession();
    state = state.copyWith(isAuthenticated: hasSession, isLoading: false);
    _refresh.notifyAuthChanged();
  }

  Future<void> completeSignIn(AuthSession session) async {
    state = AuthState(
      isAuthenticated: true,
      isLoading: false,
      phone: session.phone,
    );
    _refresh.notifyAuthChanged();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const AuthState(isAuthenticated: false, isLoading: false);
    _refresh.notifyAuthChanged();
  }
}
