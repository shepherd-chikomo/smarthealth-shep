import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network connectivity snapshot for offline-first UI.
class NetworkState {
  const NetworkState({
    required this.isOnline,
    required this.connectivityResults,
    required this.lastChangedAt,
  });

  const NetworkState.initial()
      : isOnline = true,
        connectivityResults = const [ConnectivityResult.wifi],
        lastChangedAt = null;

  final bool isOnline;
  final List<ConnectivityResult> connectivityResults;
  final DateTime? lastChangedAt;

  bool get isOffline => !isOnline;

  NetworkState copyWith({
    bool? isOnline,
    List<ConnectivityResult>? connectivityResults,
    DateTime? lastChangedAt,
  }) {
    return NetworkState(
      isOnline: isOnline ?? this.isOnline,
      connectivityResults: connectivityResults ?? this.connectivityResults,
      lastChangedAt: lastChangedAt ?? this.lastChangedAt,
    );
  }
}

/// Monitors connectivity and exposes online/offline state to the sync engine.
class NetworkStateManager extends Notifier<NetworkState> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Connectivity? _connectivity;

  @override
  NetworkState build() {
    ref.onDispose(_dispose);
    _connectivity = ref.watch(connectivityProvider);
    _listen();
    _refresh();
    return const NetworkState.initial();
  }

  Future<void> _refresh() async {
    final results = await _connectivity!.checkConnectivity();
    _update(results);
  }

  void _listen() {
    _subscription?.cancel();
    _subscription = _connectivity!.onConnectivityChanged.listen(_update);
  }

  void _update(List<ConnectivityResult> results) {
    state = NetworkState(
      isOnline: results.any((r) => r != ConnectivityResult.none),
      connectivityResults: results,
      lastChangedAt: DateTime.now(),
    );
  }

  void _dispose() {
    _subscription?.cancel();
  }

  Future<bool> checkOnline() async {
    await _refresh();
    return state.isOnline;
  }
}

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkStateManagerProvider =
    NotifierProvider<NetworkStateManager, NetworkState>(
  NetworkStateManager.new,
);

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(networkStateManagerProvider).isOnline;
});
