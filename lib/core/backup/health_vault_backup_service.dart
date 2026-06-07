import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_crypto.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_repository.dart';
import 'package:smarthealth_shep/core/security/audit_log.dart';

/// Encrypted `.healthvault` backup export and restore.
class HealthVaultBackupService {
  HealthVaultBackupService({
    HealthVaultRepository? vault,
    HealthVaultCrypto? crypto,
    AuditLog? auditLog,
  })  : _vault = vault ?? HealthVaultRepository(),
        _crypto = crypto ?? HealthVaultCrypto(),
        _auditLog = auditLog ?? AuditLog();

  final HealthVaultRepository _vault;
  final HealthVaultCrypto _crypto;
  final AuditLog _auditLog;

  Future<File> exportEncryptedFile() async {
    final snapshot = await _vault.exportSnapshot();
    final envelope = await _crypto.encryptJson(snapshot);
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/myhealth_backup_${DateTime.now().millisecondsSinceEpoch}.healthvault',
    );
    await file.writeAsString(envelope);
    await _auditLog.record(action: 'health_vault_backup_export');
    return file;
  }

  Future<void> shareBackup() async {
    final file = await exportEncryptedFile();
    await Share.shareXFiles([XFile(file.path)], text: 'MyHealth encrypted backup');
  }

  Future<void> importFromPicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['healthvault'],
    );
    final path = result?.files.single.path;
    if (path == null) return;
    final envelope = await File(path).readAsString();
    final snapshot = await _crypto.decryptJson(envelope);
    await _vault.importSnapshot(snapshot);
  }

  Future<void> importFromGoogleDrivePlaceholder() async {
    // Platform backup connectors (Google Drive / iCloud) hook in here.
    throw UnsupportedError(
      'Cloud backup connectors are configured per platform build flavor.',
    );
  }
}
