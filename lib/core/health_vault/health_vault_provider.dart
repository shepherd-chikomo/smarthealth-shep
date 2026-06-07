import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_repository.dart';

final healthVaultRepositoryProvider = Provider<HealthVaultRepository>((ref) {
  return HealthVaultRepository();
});

final healthVaultBootstrapProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(healthVaultRepositoryProvider);
  await repo.migrateLegacyFamilyPhiIfNeeded();
});
