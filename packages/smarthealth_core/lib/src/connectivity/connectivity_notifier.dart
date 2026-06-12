import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider =
    NotifierProvider<ConnectivityNotifier, bool>(ConnectivityNotifier.new);

class ConnectivityNotifier extends Notifier<bool> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  bool build() {
    ref.onDispose(() => _subscription?.cancel());
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
    _refresh();
    return true;
  }

  Future<void> _refresh() async {
    final results = await _connectivity.checkConnectivity();
    _onChanged(results);
  }

  void _onChanged(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (state != online) {
      state = online;
    }
  }
}
