import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/backup/backup_discovery_service.dart';
import 'package:smarthealth_shep/core/backup/health_vault_backup_crypto.dart';
import 'package:smarthealth_shep/core/backup/health_vault_backup_service.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key, this.discovered = false});

  final bool discovered;

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final _backup = HealthVaultBackupService();
  var _busy = false;
  String? _message;
  List<DiscoveredBackupFile> _discovered = const [];

  @override
  void initState() {
    super.initState();
    _loadDiscovered();
  }

  Future<void> _loadDiscovered() async {
    final files = await _backup.discoverLocalBackups();
    if (!mounted) return;
    setState(() => _discovered = files);
  }

  Future<String?> _promptPin({required bool confirm}) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(confirm ? 'Set backup PIN' : 'Enter backup PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: const InputDecoration(
                  labelText: 'PIN (4–8 digits)',
                  counterText: '',
                ),
              ),
              if (confirm) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  decoration: const InputDecoration(
                    labelText: 'Confirm PIN',
                    counterText: '',
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final pin = pinController.text.trim();
                if (pin.length < 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN must be at least 4 digits.')),
                  );
                  return;
                }
                if (confirm && pin != confirmController.text.trim()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PINs do not match.')),
                  );
                  return;
                }
                Navigator.pop(context, pin);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
      setState(() => _message = success);
    } on FormatException catch (error) {
      setState(() => _message = error.message);
    } catch (error) {
      setState(() => _message = error.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _saveToDownloads() async {
    final pin = await _promptPin(confirm: true);
    if (pin == null) return;
    await _run(() async {
      final file = await _backup.saveBackupToDownloads(pin: pin);
      setState(() => _message = 'Saved to ${file.path}');
    }, 'Backup saved to Downloads.');
  }

  Future<void> _shareBackup() async {
    final pin = await _promptPin(confirm: true);
    if (pin == null) return;
    await _run(
      () => _backup.shareBackup(pin: pin),
      'Backup file ready to share.',
    );
  }

  Future<void> _importBackup({String? path}) async {
    final pin = await _promptPin(confirm: false);
    if (pin == null) return;
    await _run(() async {
      if (path != null) {
        await _backup.importFromPath(path, pin: pin);
      } else {
        await _backup.importFromPicker(pin: pin);
      }
      await _backup.dismissDiscoveredImportPrompt();
      if (mounted && widget.discovered) context.go('/home');
    }, 'Backup restored successfully.');
  }

  Future<void> _skipDiscovered() async {
    await _backup.dismissDiscoveredImportPrompt();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        actions: [
          if (widget.discovered)
            TextButton(
              onPressed: _busy ? null : _skipDiscovered,
              child: const Text('Skip'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Your Health Vault is encrypted on this device. '
            'Portable backups use a PIN-protected AES-256 .healthvault file.',
          ),
          if (widget.discovered && _discovered.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We found ${_discovered.length} backup file(s) on this device.',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Restore your health profile with the PIN you set when exporting.',
                    ),
                    const SizedBox(height: 12),
                    ..._discovered.take(3).map(
                      (file) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(file.path.split('/').last),
                        subtitle: Text(file.modifiedAt.toLocal().toString()),
                        trailing: FilledButton(
                          onPressed: _busy ? null : () => _importBackup(path: file.path),
                          child: const Text('Restore'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_message != null) ...[
            Text(_message!),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: _busy ? null : _saveToDownloads,
            child: const Text('Save to Downloads'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _shareBackup,
            child: const Text('Share backup'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : () => _importBackup(),
            child: const Text('Import backup file'),
          ),
          const SizedBox(height: 12),
          Text(
            HealthVaultBackupCrypto.wrongPinMessage,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
