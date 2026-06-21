import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/backup/backup_restore_offer_provider.dart';
import 'package:smarthealth_shep/core/backup/backup_discovery_service.dart';
import 'package:smarthealth_shep/core/backup/health_vault_backup_crypto.dart';
import 'package:smarthealth_shep/core/backup/health_vault_backup_service.dart';
import 'package:smarthealth_shep/features/home/providers/home_medical_summary_provider.dart';
import 'package:smarthealth_shep/features/medications/services/medication_reminder_service.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key, this.discovered = false});

  final bool discovered;

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  final _backup = HealthVaultBackupService();
  var _busy = false;
  String? _message;
  var _restoreSucceeded = false;
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
      _restoreSucceeded = false;
    });
    try {
      await action();
      if (mounted) setState(() => _message = success);
    } on FormatException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refreshProfileAfterRestore() async {
    invalidateFamilyProfileProviders(ref);
    try {
      final members = await ref.read(familyMembersProvider.future);
      await MedicationReminderService.instance.resyncAllFromMembers(members);
    } catch (_) {
      // Restore succeeded; profile refresh can retry on next screen.
    }
  }

  void _showRestoreSuccessNotice() {
    setState(() {
      _restoreSucceeded = true;
      _message = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade300),
            const SizedBox(width: 12),
            const Expanded(child: Text('Backup restored successfully')),
          ],
        ),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveToDownloads() async {
    final pin = await _promptPin(confirm: true);
    if (pin == null) return;
    await _run(() async {
      final saved = await _backup.saveBackupToDownloads(pin: pin);
      if (!mounted) return;
      setState(() => _message = 'Backup saved to ${saved.path}');
      await _loadDiscovered();
    }, 'Backup saved to Download/HealthVault.');
  }

  Future<void> _shareBackup() async {
    final pin = await _promptPin(confirm: true);
    if (pin == null) return;
    await _run(
      () => _backup.shareBackup(pin: pin),
      'Backup file ready to share.',
    );
  }

  Future<void> _importBackup({String? path, String? uri}) async {
    final pin = await _promptPin(confirm: false);
    if (pin == null) return;

    setState(() {
      _busy = true;
      _message = null;
      _restoreSucceeded = false;
    });

    try {
      if (path != null) {
        await _backup.importFromPath(path, pin: pin, uri: uri);
      } else {
        await _backup.importFromPicker(pin: pin);
      }
      await _backup.dismissDiscoveredImportPrompt();
      ref.invalidate(backupRestoreOfferProvider);
      await _refreshProfileAfterRestore();
      if (!mounted) return;
      _showRestoreSuccessNotice();
      if (widget.discovered) {
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) context.go('/home');
      }
    } on FormatException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _skipDiscovered() async {
    await _backup.dismissDiscoveredImportPrompt();
    ref.invalidate(backupRestoreOfferProvider);
    if (mounted) context.go('/home');
  }

  Widget _restoreSuccessBanner() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Backup restored successfully',
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showDiscoveredCard =
        _discovered.isNotEmpty && (widget.discovered || !_restoreSucceeded);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.discovered ? 'Restore HealthVault' : 'Backup & Restore'),
        actions: [
          if (widget.discovered && !_restoreSucceeded)
            TextButton(
              onPressed: _busy ? null : _skipDiscovered,
              child: const Text('Skip'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_restoreSucceeded) ...[
            _restoreSuccessBanner(),
            const SizedBox(height: 16),
          ],
          if (!_restoreSucceeded)
            Text(
              widget.discovered
                  ? 'We found a HealthVault backup on this device. Enter the PIN you used when saving it to restore your health profile.'
                  : 'Your Health Vault is encrypted on this device. '
                      'Portable backups use a PIN-protected AES-256 .healthvault file.',
            ),
          if (showDiscoveredCard) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_discovered.length} backup file(s) in Download/HealthVault',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap Restore, then enter your backup PIN.'),
                    const SizedBox(height: 12),
                    ..._discovered.take(3).map(
                      (file) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(file.path.split('/').last),
                        subtitle: Text(file.modifiedAt.toLocal().toString()),
                        trailing: FilledButton(
                          onPressed: _busy
                              ? null
                              : () => _importBackup(
                                    path: file.path,
                                    uri: file.uri,
                                  ),
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
          if (!widget.discovered && !_restoreSucceeded) ...[
            FilledButton(
              onPressed: _busy ? null : _saveToDownloads,
              child: const Text('Save to HealthVault folder'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _busy ? null : _shareBackup,
              child: const Text('Share backup'),
            ),
            const SizedBox(height: 12),
          ],
          if (!_restoreSucceeded)
            OutlinedButton(
              onPressed: _busy ? null : () => _importBackup(),
              child: const Text('Import backup file'),
            ),
          if (!_restoreSucceeded) ...[
            const SizedBox(height: 12),
            Text(
              HealthVaultBackupCrypto.wrongPinMessage,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
