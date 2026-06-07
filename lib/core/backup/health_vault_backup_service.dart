import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smarthealth_shep/core/backup/backup_discovery_service.dart';
import 'package:smarthealth_shep/core/backup/health_vault_backup_crypto.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_crypto.dart';
import 'package:smarthealth_shep/core/health_vault/health_vault_repository.dart';
import 'package:smarthealth_shep/core/security/audit_log.dart';

/// Encrypted `.healthvault` backup export and restore.
class HealthVaultBackupService {
  HealthVaultBackupService({
    HealthVaultRepository? vault,
    HealthVaultCrypto? crypto,
    HealthVaultBackupCrypto? backupCrypto,
    BackupDiscoveryService? discovery,
    AuditLog? auditLog,
  })  : _vault = vault ?? HealthVaultRepository(),
        _crypto = crypto ?? HealthVaultCrypto(),
        _backupCrypto = backupCrypto ?? HealthVaultBackupCrypto(),
        _discovery = discovery ?? BackupDiscoveryService(),
        _auditLog = auditLog ?? AuditLog();

  final HealthVaultRepository _vault;
  final HealthVaultCrypto _crypto;
  final HealthVaultBackupCrypto _backupCrypto;
  final BackupDiscoveryService _discovery;
  final AuditLog _auditLog;

  Future<File> exportEncryptedFile({required String pin}) async {
    final snapshot = await _vault.exportSnapshot();
    final envelope = await _backupCrypto.encryptJson(snapshot, pin);
    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/myhealth_backup_$stamp.healthvault');
    await file.writeAsString(envelope);
    await _auditLog.record(action: 'health_vault_backup_export');
    return file;
  }

  Future<File> saveBackupToDownloads({required String pin}) async {
    final file = await exportEncryptedFile(pin: pin);
    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      final target = File('${downloads.path}/${file.uri.pathSegments.last}');
      await target.writeAsString(await file.readAsString());
      return target;
    }
    return file;
  }

  Future<void> shareBackup({required String pin}) async {
    final file = await saveBackupToDownloads(pin: pin);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'MyHealth encrypted backup',
    );
  }

  Future<void> importFromPath(String path, {required String pin}) async {
    final envelope = await File(path).readAsString();
    await _importEnvelope(envelope, pin: pin);
  }

  Future<void> importFromPicker({required String pin}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['healthvault'],
    );
    final path = result?.files.single.path;
    if (path == null) return;
    await importFromPath(path, pin: pin);
  }

  Future<void> _importEnvelope(String envelope, {required String pin}) async {
    final trimmed = envelope.trim();
    if (!trimmed.startsWith('{')) {
      throw const FormatException('Invalid backup file.');
    }

    final parsed = jsonDecode(trimmed) as Map<String, dynamic>;
    final version = parsed['v'] as int? ?? 1;
    final Map<String, dynamic> snapshot;
    if (version == HealthVaultBackupCrypto.envelopeVersion) {
      snapshot = await _backupCrypto.decryptJson(trimmed, pin);
    } else if (version == 1 && parsed['format'] == null) {
      snapshot = await _crypto.decryptJson(trimmed);
    } else {
      throw FormatException(HealthVaultBackupCrypto.wrongPinMessage);
    }

    await _vault.importSnapshot(snapshot);
    await _auditLog.record(action: 'health_vault_restore');
  }

  Future<List<DiscoveredBackupFile>> discoverLocalBackups() =>
      _discovery.findBackupFiles();

  Future<bool> shouldOfferDiscoveredImport() async {
    final records = await _vault.exportSnapshot();
    final vaultEmpty = (records['records'] as List<dynamic>? ?? []).isEmpty;
    return _discovery.shouldOfferImport(vaultEmpty: vaultEmpty);
  }

  Future<void> dismissDiscoveredImportPrompt() => _discovery.dismissPrompt();

  Future<void> importFromGoogleDrivePlaceholder() async {
    throw UnsupportedError(
      'Cloud backup connectors are configured per platform build flavor.',
    );
  }
}
