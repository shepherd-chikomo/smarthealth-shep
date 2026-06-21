import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/backup/backup_discovery_service.dart';
import 'package:smarthealth_shep/core/directory/directory_search_service.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_repository.dart';
import 'package:smarthealth_shep/core/sync/sync_manager.dart';
import 'package:smarthealth_shep/features/home/providers/home_medical_summary_provider.dart';
import 'package:smarthealth_shep/features/medications/services/medication_reminder_service.dart';

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
    await MedicationReminderService.instance.initialize();
    final vaultRepo = HealthVaultRepository();
    await vaultRepo.migrateLegacyFamilyPhiIfNeeded();
    await BackupDiscoveryService.markAwaitingRestoreIfNeeded(
      await vaultRepo.needsRestoreFromBackup(),
    );
    unawaited(DirectorySearchService().rebuildIndex());
    await ref.read(syncManagerProvider.notifier).initialize();
    unawaited(ref.read(medicationRemindersBootstrapProvider.future));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
