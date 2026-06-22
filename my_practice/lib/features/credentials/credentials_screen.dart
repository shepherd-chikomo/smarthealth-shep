import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/design_system/widgets/practice_icon_widgets.dart';
import 'package:my_practice/features/practice_ops/practice_ops_providers.dart';
import 'package:my_practice/shared/widgets/practice_more_app_bar.dart';

class CredentialsScreen extends ConsumerStatefulWidget {
  const CredentialsScreen({super.key});

  @override
  ConsumerState<CredentialsScreen> createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends ConsumerState<CredentialsScreen> {
  bool _adding = false;

  Future<void> _showAddDialog() async {
    final result = await showDialog<_CredentialForm>(
      context: context,
      builder: (_) => const _AddCredentialDialog(),
    );
    if (result == null || !mounted) return;

    setState(() => _adding = true);
    try {
      await ref.read(facilityRepositoryProvider).createCredential(
            credentialType: result.credentialType,
            title: result.title,
            issuedAt: result.issuedAt,
            expiresAt: result.expiresAt,
          );
      ref.invalidate(credentialsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credential added')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add credential: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final credsAsync = ref.watch(credentialsProvider);
    final auth = ref.watch(authStateProvider);
    final provider = auth.profile?.provider;

    return Scaffold(
      appBar: practiceMoreAppBar(context, 'Credential Wallet'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adding ? null : _showAddDialog,
        icon: _adding
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: const Text('Add credential'),
      ),
      body: credsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (creds) {
          final display = [...creds];
          if (display.isEmpty && provider?.registrationNumber != null) {
            display.add({
              'id': 'mdpcz-local',
              'credentialType': 'registration',
              'title': 'MDPCZ Registration',
              'registrationNumber': provider!.registrationNumber,
            });
          }

          if (display.isEmpty) {
            return PracticeEmptyState(
              title: 'No credentials',
              message: provider == null
                  ? 'Claim your MDPCZ practitioner profile to see registrations and certificates.'
                  : 'Add APC certificates, licences, and CPD records with renewal dates.',
              icon: Icons.badge_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(credentialsProvider);
              await ref.read(credentialsProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text('Credential Wallet', style: PracticeDesignTokens.pageTitle(context)),
                Text(
                  'Practising certificates and registrations',
                  style: PracticeDesignTokens.metadata(context),
                ),
                const SizedBox(height: 16),
                ...display.map((c) => _CredentialCard(data: c)),
                const SizedBox(height: 72),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CredentialForm {
  const _CredentialForm({
    required this.credentialType,
    required this.title,
    this.issuedAt,
    this.expiresAt,
  });

  final String credentialType;
  final String title;
  final String? issuedAt;
  final String? expiresAt;
}

class _AddCredentialDialog extends StatefulWidget {
  const _AddCredentialDialog();

  @override
  State<_AddCredentialDialog> createState() => _AddCredentialDialogState();
}

class _AddCredentialDialogState extends State<_AddCredentialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  String _type = 'certificate';
  DateTime? _issuedAt;
  DateTime? _expiresAt;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  String? _formatDate(DateTime? dt) {
    if (dt == null) return null;
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate({required bool issued}) async {
    final initial = issued ? (_issuedAt ?? DateTime.now()) : (_expiresAt ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (issued) {
        _issuedAt = picked;
      } else {
        _expiresAt = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add credential'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Annual Practising Certificate 2026',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'certificate', child: Text('Certificate')),
                  DropdownMenuItem(value: 'licence', child: Text('Licence')),
                  DropdownMenuItem(value: 'registration', child: Text('Registration')),
                  DropdownMenuItem(value: 'cpd', child: Text('CPD record')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'certificate'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Issued date (optional)'),
                subtitle: Text(_issuedAt == null ? 'Not set' : _formatDate(_issuedAt)!),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(issued: true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Renewal / expiry date'),
                subtitle: Text(_expiresAt == null ? 'Not set' : _formatDate(_expiresAt)!),
                trailing: const Icon(Icons.event_outlined),
                onTap: () => _pickDate(issued: false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _CredentialForm(
                credentialType: _type,
                title: _titleCtrl.text.trim(),
                issuedAt: _formatDate(_issuedAt),
                expiresAt: _formatDate(_expiresAt),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _CredentialCard extends StatelessWidget {
  const _CredentialCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? 'Credential';
    final type = (data['credentialType'] as String? ?? 'other').toUpperCase();
    final expiresRaw = data['expiresAt'] as String?;
    final issuedRaw = data['issuedAt'] as String?;
    final regNo = data['registrationNumber'] as String?;
    DateTime? expires;
    DateTime? issued;
    if (expiresRaw != null && expiresRaw.isNotEmpty) {
      expires = DateTime.tryParse(expiresRaw);
    }
    if (issuedRaw != null && issuedRaw.isNotEmpty) {
      issued = DateTime.tryParse(issuedRaw);
    }
    final daysLeft = expires?.difference(DateTime.now()).inDays;
    final tone = daysLeft == null
        ? PracticeStatusTone.neutral
        : daysLeft < 30
            ? PracticeStatusTone.danger
            : daysLeft < 90
                ? PracticeStatusTone.warning
                : PracticeStatusTone.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Row(
        children: [
          PracticeIconBadge(
            icon: Icons.verified_outlined,
            color: tone.color(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
                Text(type, style: PracticeDesignTokens.metadata(context)),
                if (regNo != null)
                  Text('Reg. $regNo', style: PracticeDesignTokens.metadata(context)),
                if (issued != null)
                  Text(
                    'Issued ${_formatDate(issued)}',
                    style: PracticeDesignTokens.metadata(context),
                  ),
                if (expires != null)
                  Text(
                    'Expires ${_formatDate(expires)}',
                    style: PracticeDesignTokens.metadata(context),
                  ),
              ],
            ),
          ),
          if (daysLeft != null)
            PracticeStatusChip(
              label: daysLeft < 0
                  ? 'Expired'
                  : daysLeft == 0
                      ? 'Today'
                      : '$daysLeft days',
              tone: tone,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
