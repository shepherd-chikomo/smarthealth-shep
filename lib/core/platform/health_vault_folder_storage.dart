import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Saves and opens the public Downloads/HealthVault folder on Android.
class HealthVaultFolderStorage {
  static const _channel = MethodChannel('dev.smarthealth.smarthealth_shep/files');

  static const publicFolderPath = 'Download/HealthVault';

  static Future<HealthVaultSavedFile> saveToPublicFolder({
    required String fileName,
    required String content,
  }) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Public HealthVault folder is Android-only.');
    }
    final result = await _channel.invokeMethod<Map<Object?, Object?>>(
      'saveToHealthVault',
      {
        'fileName': fileName,
        'content': content,
      },
    );
    if (result == null) {
      throw StateError('Failed to save backup to Downloads/HealthVault.');
    }
    return HealthVaultSavedFile(
      path: result['path'] as String? ?? '$publicFolderPath/$fileName',
      uri: result['uri'] as String?,
    );
  }

  static Future<bool> openPublicFolder() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final opened = await _channel.invokeMethod<bool>('openHealthVaultFolder');
      return opened ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<List<HealthVaultBackupEntry>> listPublicBackups() async {
    if (kIsWeb || !Platform.isAndroid) return const [];
    try {
      final raw = await _channel.invokeMethod<List<Object?>>(
        'listHealthVaultBackups',
      );
      if (raw == null) return const [];
      return raw
          .whereType<Map<Object?, Object?>>()
          .map(
            (entry) => HealthVaultBackupEntry(
              path: entry['path'] as String? ?? '',
              uri: entry['uri'] as String?,
              modifiedAt: DateTime.fromMillisecondsSinceEpoch(
                (entry['modifiedAt'] as num?)?.toInt() ?? 0,
                isUtc: true,
              ).toLocal(),
            ),
          )
          .where((entry) => entry.path.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<String> readBackup({
    String? uri,
    String? path,
  }) async {
    if (!Platform.isAndroid) {
      if (path == null) {
        throw StateError('Backup path required on this platform.');
      }
      return File(path).readAsString();
    }
    final content = await _channel.invokeMethod<String>(
      'readHealthVaultFile',
      {
        if (uri != null) 'uri': uri,
        if (path != null) 'path': path,
      },
    );
    if (content == null) {
      throw StateError('Could not read backup file.');
    }
    return content;
  }
}

class HealthVaultSavedFile {
  const HealthVaultSavedFile({required this.path, this.uri});

  final String path;
  final String? uri;
}

class HealthVaultBackupEntry {
  const HealthVaultBackupEntry({
    required this.path,
    required this.modifiedAt,
    this.uri,
  });

  final String path;
  final String? uri;
  final DateTime modifiedAt;
}
