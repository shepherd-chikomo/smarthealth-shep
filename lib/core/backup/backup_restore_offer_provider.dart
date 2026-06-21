import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/auth/auth_state.dart';
import 'package:smarthealth_shep/core/backup/health_vault_backup_service.dart';

/// Whether the user should be prompted to restore a local HealthVault backup.
final backupRestoreOfferProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (!auth.isAuthenticated || auth.isLoading) return false;

  // Let Home render before running native storage scans.
  await Future<void>.delayed(const Duration(seconds: 2));

  final service = HealthVaultBackupService();
  for (var attempt = 0; attempt < 3; attempt++) {
    if (await service.shouldOfferDiscoveredImport()) return true;
    if (attempt < 2) {
      await Future<void>.delayed(Duration(milliseconds: 600 * (attempt + 1)));
    }
  }
  return false;
});
