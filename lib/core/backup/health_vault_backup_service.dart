import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smarthealth_shep/core/platform/health_vault_folder_storage.dart';
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

  Future<HealthVaultSavedFile> saveBackupToDownloads({required String pin}) async {
    final file = await exportEncryptedFile(pin: pin);
    final fileName = file.uri.pathSegments.last;
    final content = await file.readAsString();

    if (Platform.isAndroid) {
      return HealthVaultFolderStorage.saveToPublicFolder(
        fileName: fileName,
        content: content,
      );
    }

    final vaultDir = await _localHealthVaultDirectory();
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    final target = File('${vaultDir.path}/$fileName');
    await target.writeAsString(content);
    return HealthVaultSavedFile(path: target.path);
  }

  Future<Directory> _localHealthVaultDirectory() async {
    final downloads = await getDownloadsDirectory();
    final base = downloads ?? await getApplicationDocumentsDirectory();
    return Directory('${base.path}/HealthVault');
  }

  String get publicFolderLabel => HealthVaultFolderStorage.publicFolderPath;

  Future<bool> openHealthVaultFolder() async {
    if (Platform.isAndroid) {
      return HealthVaultFolderStorage.openPublicFolder();
    }
    final dir = await _localHealthVaultDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return false;
  }

  Future<void> shareBackup({required String pin}) async {
    final file = await exportEncryptedFile(pin: pin);
    if (Platform.isAndroid) {
      await HealthVaultFolderStorage.saveToPublicFolder(
        fileName: file.uri.pathSegments.last,
        content: await file.readAsString(),
      );
    } else {
      final vaultDir = await _localHealthVaultDirectory();
      if (!await vaultDir.exists()) {
        await vaultDir.create(recursive: true);
      }
      final target = File('${vaultDir.path}/${file.uri.pathSegments.last}');
      await target.writeAsString(await file.readAsString());
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'MyHealth encrypted backup',
      ),
    );
  }

  Future<void> importFromPath(String path, {required String pin, String? uri}) async {
    final envelope = await _readBackupEnvelope(path: path, uri: uri);
    await _importEnvelope(envelope, pin: pin);
  }

  Future<void> importFromPicker({required String pin}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['healthvault', 'bin'],
      withData: true,
    );
    final picked = result?.files.single;
    if (picked == null) return;

    if (picked.bytes != null) {
      await _importEnvelope(utf8.decode(picked.bytes!), pin: pin);
      return;
    }

    final path = picked.path;
    if (path == null || path.isEmpty) {
      throw const FormatException('Could not read the selected backup file.');
    }
    await importFromPath(path, pin: pin);
  }

  Future<String> _readBackupEnvelope({required String path, String? uri}) async {
    if (Platform.isAndroid) {
      if (uri != null && uri.isNotEmpty) {
        return HealthVaultFolderStorage.readBackup(uri: uri, path: path);
      }

      final fileName = path.split('/').last;
      if (fileName.isNotEmpty && fileName.contains('.')) {
        final backups = await HealthVaultFolderStorage.listPublicBackups();
        for (final entry in backups) {
          if (entry.path == path ||
              entry.path.endsWith('/$fileName') ||
              entry.path.endsWith(fileName)) {
            if (entry.uri != null && entry.uri!.isNotEmpty) {
              return HealthVaultFolderStorage.readBackup(
                uri: entry.uri,
                path: entry.path,
              );
            }
          }
        }
      }

      if (path.startsWith('content://')) {
        return HealthVaultFolderStorage.readBackup(uri: path, path: path);
      }

      final file = File(path);
      if (await file.exists()) {
        return file.readAsString();
      }

      throw const FormatException(
        'Could not read backup file. Try Import backup file and select it from Download/HealthVault.',
      );
    }

    final file = File(path);
    if (!await file.exists()) {
      throw FormatException('Backup file not found: $path');
    }
    return file.readAsString();
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
    final files = await discoverLocalBackups();
    if (files.isEmpty) return false;
    final vaultNeedsRestore = await _vault.needsRestoreFromBackup();
    if (vaultNeedsRestore) {
      await BackupDiscoveryService.markAwaitingRestore();
    }
    return _discovery.shouldOfferImport(vaultNeedsRestore: vaultNeedsRestore);
  }

  static Future<String> resolvePostAuthRoute() async {
    final service = HealthVaultBackupService();
    if (await service.shouldOfferDiscoveredImport()) {
      return '/profile/backup?discovered=true';
    }
    return '/home';
  }

  Future<void> dismissDiscoveredImportPrompt() => _discovery.dismissPrompt();

  Future<void> importFromGoogleDrivePlaceholder() async {
    throw UnsupportedError(
      'Cloud backup connectors are configured per platform build flavor.',
    );
  }
}
