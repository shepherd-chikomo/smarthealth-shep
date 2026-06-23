import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/features/appointments/utils/disclosure_labels.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/profile/data/consent_repository.dart';
import 'package:smarthealth_shep/features/profile/models/consent_record.dart';

class PrivacySharingScreen extends StatefulWidget {
  const PrivacySharingScreen({super.key});

  @override
  State<PrivacySharingScreen> createState() => _PrivacySharingScreenState();
}

class _PrivacySharingScreenState extends State<PrivacySharingScreen> {
  final _repository = ConsentRepository();
  List<ConsentRecord> _consents = [];
  bool _loading = true;
  String? _error;
  String? _withdrawingKey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final consents = await _repository.listConsents();
      if (!mounted) return;
      setState(() {
        _consents = consents;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _withdraw(ConsentRecord record) async {
    final facilityId = record.facilityId;
    if (facilityId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw sharing?'),
        content: const Text(
          'Providers at this facility will no longer see your shared health '
          'profile. Past access is kept in the audit log.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep sharing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final key = '${record.consentType}:$facilityId';
    setState(() => _withdrawingKey = key);
    try {
      await _repository.withdrawConsent(
        record.consentType,
        facilityId: facilityId,
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not withdraw: $error')),
      );
    } finally {
      if (mounted) setState(() => _withdrawingKey = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & sharing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Facilities you have shared health data with. '
                        'You can withdraw access at any time.',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ..._buildFacilitySections(colors),
                      if (_facilityConsents.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 48),
                          child: Center(
                            child: Text(
                              'No active sharing consents',
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Iterable<Widget> _buildFacilitySections(HomeDashboardColors colors) sync* {
    for (final entry in _facilityConsents.entries) {
      final facilityId = entry.key;
      final records = entry.value;
      final phi = records.where((r) => r.consentType == 'facility_phi_share');
      final ongoing =
          records.where((r) => r.consentType == 'facility_ongoing_care');
      final encounter = records
          .where((r) => r.consentType == 'encounter_summary_receive');

      yield Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E8EE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Facility',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            Text(
              facilityId,
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
            const SizedBox(height: 12),
            if (phi.isNotEmpty) ...[
              Text(
                'Pre-visit sharing',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _sharedFieldsText(phi.first),
                style: TextStyle(color: colors.textSecondary),
              ),
              const SizedBox(height: 8),
              _WithdrawButton(
                loading: _withdrawingKey == 'facility_phi_share:$facilityId',
                onPressed: () => _withdraw(phi.first),
              ),
            ],
            if (ongoing.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Ongoing care record',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _WithdrawButton(
                loading:
                    _withdrawingKey == 'facility_ongoing_care:$facilityId',
                onPressed: () => _withdraw(ongoing.first),
              ),
            ],
            if (encounter.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Visit summaries',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You opted in to receive practitioner notes after visits.',
                style: TextStyle(color: colors.textSecondary),
              ),
              const SizedBox(height: 8),
              _WithdrawButton(
                loading:
                    _withdrawingKey == 'encounter_summary_receive:$facilityId',
                onPressed: () => _withdraw(encounter.first),
              ),
            ],
          ],
        ),
      );
    }
  }

  Map<String, List<ConsentRecord>> get _facilityConsents {
    final map = <String, List<ConsentRecord>>{};
    for (final record in _consents) {
      if (!record.isActive) continue;
      if (record.facilityId == null) continue;
      if (!{
        'facility_phi_share',
        'facility_ongoing_care',
        'encounter_summary_receive',
      }.contains(record.consentType)) {
        continue;
      }
      map.putIfAbsent(record.facilityId!, () => []).add(record);
    }
    return map;
  }

  String _sharedFieldsText(ConsentRecord record) {
    final fields = record.shareProfile.entries
        .where((e) => e.value)
        .map((e) => disclosureFieldLabel(e.key))
        .toList();
    if (fields.isEmpty) return 'Profile snapshot shared';
    return 'Shared: ${fields.join(', ')}';
  }
}

class _WithdrawButton extends StatelessWidget {
  const _WithdrawButton({required this.onPressed, required this.loading});

  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Withdraw access'),
    );
  }
}
