import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth_shep/core/platform/health_vault_folder_storage.dart';

class DiscoveredBackupFile {
  const DiscoveredBackupFile({
    required this.path,
    required this.modifiedAt,
    this.uri,
  });

  final String path;
  final DateTime modifiedAt;
  final String? uri;
}

/// Scans user-accessible storage for SmartHealth backup files.
class BackupDiscoveryService {
  static const dismissedKey = 'backup_discovery_dismissed_v1';
  static const awaitingRestoreKey = 'backup_awaiting_restore_v1';
  static const backupFilePrefix = 'myhealth_backup_';
  static const backupExtension = '.healthvault';

  Future<List<DiscoveredBackupFile>> findBackupFiles({int maxAttempts = 2}) async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final results = await _scanOnce();
      if (results.isNotEmpty) return results;
      if (attempt < maxAttempts - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }
    return const [];
  }

  Future<List<DiscoveredBackupFile>> _scanOnce() async {
    final results = <DiscoveredBackupFile>[];
    final seen = <String>{};

    if (Platform.isAndroid) {
      for (final entry in await HealthVaultFolderStorage.listPublicBackups()) {
        final key = _dedupeKey(entry.path, entry.uri);
        if (seen.add(key)) {
          results.add(
            DiscoveredBackupFile(
              path: entry.path,
              modifiedAt: entry.modifiedAt,
              uri: entry.uri,
            ),
          );
        }
      }
    }

    for (final dir in await _candidateDirectories()) {
      if (!await dir.exists()) continue;
      try {
        await for (final entity in dir.list(recursive: false, followLinks: false)) {
          if (entity is! File) continue;
          final name = entity.path.split(Platform.pathSeparator).last;
          if (!_looksLikeBackupFile(name)) continue;
          final key = _dedupeKey(entity.path, null);
          if (seen.add(key)) {
            final stat = await entity.stat();
            results.add(
              DiscoveredBackupFile(path: entity.path, modifiedAt: stat.modified),
            );
          }
        }
      } catch (_) {}
    }

    results.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return results;
  }

  Future<bool> shouldOfferImport({required bool vaultNeedsRestore}) async {
    final prefs = await SharedPreferences.getInstance();
    final awaiting = prefs.getBool(awaitingRestoreKey) ?? false;
    if (!vaultNeedsRestore && !awaiting) return false;

    final files = await findBackupFiles();
    if (files.isEmpty) return false;

    await prefs.remove(dismissedKey);
    return true;
  }

  Future<void> dismissPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(dismissedKey, true);
    await prefs.setBool(awaitingRestoreKey, false);
  }

  static Future<void> markAwaitingRestore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(awaitingRestoreKey, true);
    await prefs.remove(dismissedKey);
  }

  static Future<void> markAwaitingRestoreIfNeeded(bool needsRestore) async {
    if (!needsRestore) return;
    await markAwaitingRestore();
  }

  static bool _looksLikeBackupFile(String name) {
    final lower = name.toLowerCase();
    if (lower == 'healthvault_catalog.json') return false;
    if (lower.startsWith(backupFilePrefix)) return true;
    if (lower.endsWith(backupExtension)) return true;
    return lower.contains('healthvault') &&
        (lower.startsWith('myhealth') || lower.contains('backup'));
  }

  static String _dedupeKey(String path, String? uri) {
    if (uri != null && uri.isNotEmpty) return uri;
    return path.toLowerCase();
  }

  Future<List<Directory>> _candidateDirectories() async {
    final dirs = <Directory>[];
    try {
      final downloads =
          await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      dirs.add(downloads);
      dirs.add(Directory('${downloads.path}/HealthVault'));
    } catch (_) {}
    try {
      dirs.add(await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory());
    } catch (_) {}
    try {
      dirs.add(await getApplicationDocumentsDirectory());
    } catch (_) {}
    if (Platform.isAndroid) {
      dirs.add(Directory('/storage/emulated/0/Download/HealthVault'));
      dirs.add(Directory('/storage/emulated/0/Downloads/HealthVault'));
    }
    return dirs;
  }
}
