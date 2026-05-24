import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/sync/sync_manager.dart';

/// Boots [SyncManager] on app launch (queue, delta sync, background retry).
class SyncInitializer extends ConsumerStatefulWidget {
  const SyncInitializer({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncInitializer> createState() => _SyncInitializerState();
}

class _SyncInitializerState extends ConsumerState<SyncInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    await ref.read(syncManagerProvider.notifier).initialize();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
