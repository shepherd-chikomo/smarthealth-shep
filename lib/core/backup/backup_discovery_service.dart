import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscoveredBackupFile {
  const DiscoveredBackupFile({required this.path, required this.modifiedAt});

  final String path;
  final DateTime modifiedAt;
}

/// Scans user-accessible storage for SmartHealth backup files.
class BackupDiscoveryService {
  static const dismissedKey = 'backup_discovery_dismissed_v1';
  static const backupFilePrefix = 'myhealth_backup_';
  static const backupExtension = '.healthvault';

  Future<List<DiscoveredBackupFile>> findBackupFiles() async {
    final results = <DiscoveredBackupFile>[];
    final seen = <String>{};

    for (final dir in await _candidateDirectories()) {
      if (!await dir.exists()) continue;
      await for (final entity in dir.list(recursive: false, followLinks: false)) {
        if (entity is! File) continue;
        final name = entity.path.split(Platform.pathSeparator).last.toLowerCase();
        if (!name.endsWith(backupExtension)) continue;
        if (!name.startsWith(backupFilePrefix)) continue;
        if (seen.add(entity.path)) {
          final stat = await entity.stat();
          results.add(
            DiscoveredBackupFile(path: entity.path, modifiedAt: stat.modified),
          );
        }
      }
    }

    results.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return results;
  }

  Future<bool> shouldOfferImport({required bool vaultEmpty}) async {
    if (!vaultEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(dismissedKey) == true) return false;
    final files = await findBackupFiles();
    return files.isNotEmpty;
  }

  Future<void> dismissPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(dismissedKey, true);
  }

  Future<List<Directory>> _candidateDirectories() async {
    final dirs = <Directory>[];
    try {
      dirs.add(await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory());
    } catch (_) {}
    try {
      dirs.add(await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory());
    } catch (_) {}
    try {
      dirs.add(await getApplicationDocumentsDirectory());
    } catch (_) {}
    return dirs;
  }
}
