import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/backup/health_vault_backup_service.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final _backup = HealthVaultBackupService();
  var _busy = false;
  String? _message;

  Future<void> _run(Future<void> Function() action, String success) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
      setState(() => _message = success);
    } catch (error) {
      setState(() => _message = error.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Your Health Vault is encrypted on this device. '
            'Backups use AES-256 in a .healthvault file.',
          ),
          const SizedBox(height: 16),
          if (_message != null) ...[
            Text(_message!),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: _busy
                ? null
                : () => _run(_backup.shareBackup, 'Backup file ready to share.'),
            child: const Text('Export encrypted backup'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy
                ? null
                : () => _run(_backup.importFromPicker, 'Backup restored successfully.'),
            child: const Text('Import backup file'),
          ),
        ],
      ),
    );
  }
}
