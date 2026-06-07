import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthealth_shep/core/cloud/cloud_account_dao.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_repository.dart';
import 'package:smarthealth_shep/core/patient_id/patient_identity_service.dart';
import 'package:smarthealth_shep/core/security/audit_log.dart';
import 'package:smarthealth_shep/core/storage/hive_boxes.dart';

/// Session sign-out clears cloud session data; account deletion wipes vault too.
class SecureDataWipe {
  SecureDataWipe({
    CloudAccountDao? cloudDao,
    HealthVaultRepository? vault,
    PatientIdentityService? identity,
    AuditLog? auditLog,
  })  : _cloudDao = cloudDao ?? CloudAccountDao(),
        _vault = vault ?? HealthVaultRepository(),
        _identity = identity ?? PatientIdentityService(),
        _auditLog = auditLog ?? AuditLog();

  final CloudAccountDao _cloudDao;
  final HealthVaultRepository _vault;
  final PatientIdentityService _identity;
  final AuditLog _auditLog;

  /// Sign-out: remove auth-linked cloud cache, keep Health Vault on device.
  Future<void> onSignOut() async {
    await _cloudDao.clear();
    await _clearHttpCache();
  }

  /// Account deletion: wipe all local PHI and identifiers.
  Future<void> onAccountDeletion() async {
    await _vault.wipeAll();
    await _cloudDao.clear();
    await _identity.wipe();
    await _auditLog.wipe();
    await _clearHttpCache();
    for (final boxName in [
      HiveBoxes.facilities,
      HiveBoxes.emergency,
      HiveBoxes.syncQueue,
    ]) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      }
    }
  }

  Future<void> _clearHttpCache() async {
    if (Hive.isBoxOpen(HiveBoxes.providers)) {
      await Hive.box(HiveBoxes.providers).clear();
    }
  }
}
