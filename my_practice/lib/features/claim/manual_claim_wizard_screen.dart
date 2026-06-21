import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/remote/claims_api_client.dart';
import 'package:my_practice/domain/models/claim_models.dart';
import 'package:my_practice/features/claim/widgets/claim_evidence_picker.dart';
import 'package:my_practice/features/claim/widgets/claim_step_chips.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

enum _ManualStep { account, verify, upload, select, submit, pending, approved }

class ManualClaimWizardScreen extends ConsumerStatefulWidget {
  const ManualClaimWizardScreen({super.key});

  @override
  ConsumerState<ManualClaimWizardScreen> createState() =>
      _ManualClaimWizardScreenState();
}

class _ManualClaimWizardScreenState extends ConsumerState<ManualClaimWizardScreen> {
  _ManualStep _step = _ManualStep.account;
  bool _loading = false;
  String? _error;

  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _regNumberCtrl = TextEditingController();
  final _mdpczCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _otpSent = false;
  OtpChannel _otpChannel = OtpChannel.email;
  String _otpDestination = '';
  bool _emailConfirmed = false;
  bool _skipDocuments = false;

  String _claimType = 'facility';
  List<ClaimableFacility> _facilities = [];
  List<ClaimableProvider> _providers = [];
  ClaimableFacility? _selectedFacility;
  ClaimableProvider? _selectedProvider;
  List<ClaimEvidenceFile> _files = [];
  ClaimRecord? _activeClaim;

  List<String> get _stepLabels {
    if (_skipDocuments) {
      return const ['Account', 'Verify', 'Select', 'Submit', 'Review', 'Approved'];
    }
    return const [
      'Account',
      'Verify',
      'Documents',
      'Select',
      'Submit',
      'Review',
      'Approved',
    ];
  }

  int get _stepIndex {
    const order = _ManualStep.values;
    var idx = order.indexOf(_step);
    if (_skipDocuments && idx > order.indexOf(_ManualStep.upload)) {
      idx -= 1;
    }
    return idx;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_checkExistingSession);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _searchCtrl.dispose();
    _regNumberCtrl.dispose();
    _mdpczCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkExistingSession() async {
    final repo = ref.read(myPracticeAuthRepositoryProvider);
    if (!await repo.hasSession()) return;
    try {
      await _applyRegistryMatch();
      final mine = await ref.read(claimsApiClientProvider).myClaims();
      ClaimRecord? pending;
      for (final c in [...mine.facilityClaims, ...mine.providerClaims]) {
        if (['draft', 'submitted', 'under_review', 'approved']
            .contains(c.status)) {
          pending = c;
          break;
        }
      }
      if (pending == null) {
        if (mounted) setState(() => _step = _ManualStep.verify);
        return;
      }
      final claim = pending;
      setState(() {
        _activeClaim = claim;
        _claimType = claim.type;
        if (claim.status == 'approved') {
          _step = _ManualStep.approved;
        } else if (['submitted', 'under_review'].contains(claim.status)) {
          _step = _ManualStep.pending;
        } else {
          _step = _ManualStep.submit;
        }
      });
    } catch (_) {}
  }

  Future<void> _applyRegistryMatch() async {
    try {
      final match = await ref.read(claimsApiClientProvider).registryEmailMatch();
      if (match.matched && match.provider != null) {
        final firstLinked =
            match.linkedFacilities.isNotEmpty ? match.linkedFacilities.first : null;
        setState(() {
          _skipDocuments = true;
          _claimType = 'provider';
          _emailConfirmed = true;
          _selectedProvider = ClaimableProvider(
            id: match.provider!.id,
            name: match.provider!.name,
            specialty: match.provider!.specialty,
            facilityId: firstLinked?.id,
            facilityName: firstLinked?.name ?? 'No facility linked',
          );
          if (match.provider!.registrationNumber != null) {
            _mdpczCtrl.text = match.provider!.registrationNumber!;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _sendOtp({bool usePhone = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(myPracticeAuthRepositoryProvider).sendOtp(
            channel: usePhone ? OtpChannel.phone : OtpChannel.email,
            email: usePhone ? null : _emailCtrl.text.trim(),
            phone: usePhone ? normalizeZimbabwePhone(_phoneCtrl.text) : null,
            context: 'mobile',
          );
      setState(() {
        _otpChannel = result.channel;
        _otpDestination = result.destination;
        _otpSent = true;
      });
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Could not send code');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(myPracticeAuthRepositoryProvider).verifyOtp(
            channel: _otpChannel,
            email: _otpChannel == OtpChannel.email ? _emailCtrl.text.trim() : null,
            phone: _otpChannel == OtpChannel.phone
                ? normalizeZimbabwePhone(_phoneCtrl.text)
                : null,
            otp: _otpCtrl.text.trim(),
            context: 'mobile',
          );
      await _applyRegistryMatch();
      if (mounted) setState(() => _step = _ManualStep.verify);
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Invalid code');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadListings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(claimsApiClientProvider);
      if (_claimType == 'facility') {
        final list = await api.searchFacilities(query: _searchCtrl.text.trim());
        setState(() => _facilities = list);
      } else {
        final list = await api.searchProviders(query: _searchCtrl.text.trim());
        setState(() => _providers = list);
      }
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Search failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createDraftClaim() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final evidence = evidencePayload(_files, skipDocuments: _skipDocuments);
      final api = ref.read(claimsApiClientProvider);
      if (_claimType == 'facility' && _selectedFacility != null) {
        final claim = await api.createFacilityClaim(
          facilityId: _selectedFacility!.id,
          businessRegistrationNumber:
              _regNumberCtrl.text.trim().isEmpty ? null : _regNumberCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          evidence: evidence,
        );
        setState(() {
          _activeClaim = claim;
          _step = _ManualStep.submit;
        });
      } else if (_claimType == 'provider' && _selectedProvider != null) {
        final claim = await api.createProviderClaim(
          providerId: _selectedProvider!.id,
          mdpczNumber: _mdpczCtrl.text.trim().isEmpty ? null : _mdpczCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          evidence: evidence,
        );
        setState(() {
          _activeClaim = claim;
          _step = _ManualStep.submit;
        });
      } else {
        throw Exception('Select a listing to claim');
      }
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Could not create claim');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitClaim() async {
    if (_activeClaim == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final evidence = evidencePayload(_files, skipDocuments: _skipDocuments);
      final api = ref.read(claimsApiClientProvider);
      ClaimRecord claim;
      if (_activeClaim!.type == 'facility') {
        await api.updateFacilityClaim(
          _activeClaim!.id,
          businessRegistrationNumber:
              _regNumberCtrl.text.trim().isEmpty ? null : _regNumberCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          evidence: evidence,
        );
        claim = await api.submitFacilityClaim(_activeClaim!.id);
      } else {
        claim = await api.submitProviderClaim(_activeClaim!.id);
      }
      setState(() {
        _activeClaim = claim;
        _step = _ManualStep.pending;
      });
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Submit failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _continueFromVerify() {
    setState(() => _step = _skipDocuments ? _ManualStep.select : _ManualStep.upload);
  }

  String? get _selectedName =>
      _claimType == 'facility' ? _selectedFacility?.name : _selectedProvider?.name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual claim wizard')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Verify ownership to manage a facility or practitioner listing.',
            style: AppTextStyles.sm(color: context.appColors.mutedForeground),
          ),
          const SizedBox(height: 16),
          ClaimStepChips(steps: _stepLabels, currentIndex: _stepIndex),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
          ],
          switch (_step) {
            _ManualStep.account => _buildAccount(),
            _ManualStep.verify => _buildVerify(),
            _ManualStep.upload => _buildUpload(),
            _ManualStep.select => _buildSelect(),
            _ManualStep.submit => _buildSubmit(),
            _ManualStep.pending => _buildPending(),
            _ManualStep.approved => _buildApproved(),
          },
        ],
      ),
    );
  }

  Widget _buildAccount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('1. Create account', style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
          enabled: !_otpSent,
        ),
        if (_otpSent) ...[
          const SizedBox(height: 12),
          Text('Code sent to $_otpDestination'),
          TextField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(labelText: 'Verification code'),
          ),
        ] else ...[
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone (fallback)',
              hintText: '0771234567',
            ),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _loading
              ? null
              : (_otpSent ? _verifyOtp : () => _sendOtp()),
          child: Text(_otpSent ? 'Verify & continue' : 'Send code to email'),
        ),
        if (!_otpSent)
          TextButton(
            onPressed: _loading || _phoneCtrl.text.trim().isEmpty
                ? null
                : () => _sendOtp(usePhone: true),
            child: const Text('Send code to phone instead'),
          ),
      ],
    );
  }

  Widget _buildVerify() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('2. Verify contact details',
            style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        const SizedBox(height: 12),
        if (_skipDocuments && _selectedProvider != null)
          Text(
            'Your email matches registry record for ${_selectedProvider!.name}. Document upload is not required.',
            style: AppTextStyles.sm(color: Theme.of(context).colorScheme.primary),
          ),
        CheckboxListTile(
          value: true,
          onChanged: null,
          title: const Text('Phone verified via OTP'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          value: _emailConfirmed,
          onChanged: (v) => setState(() => _emailConfirmed = v ?? false),
          title: const Text('I confirm my email on file is current'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _continueFromVerify, child: const Text('Continue')),
      ],
    );
  }

  Widget _buildUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('3. Upload proof documents',
            style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        const SizedBox(height: 12),
        ClaimEvidencePicker(
          files: _files,
          onChanged: (files) => setState(() => _files = files),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _files.isEmpty ? null : () => setState(() => _step = _ManualStep.select),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _skipDocuments ? '3. Confirm listing' : '4. Select listing',
          style: AppTextStyles.base(fontWeight: AppTextStyles.bold),
        ),
        if (!_skipDocuments) ...[
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'facility', label: Text('Facility')),
              ButtonSegment(value: 'provider', label: Text('Practitioner')),
            ],
            selected: {_claimType},
            onSelectionChanged: (s) => setState(() {
              _claimType = s.first;
              _selectedFacility = null;
              _selectedProvider = null;
            }),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(hintText: 'Search by name or city'),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: _loading ? null : _loadListings,
              child: const Text('Search'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_claimType == 'facility')
          ..._facilities.map(
            (f) => RadioListTile<String>(
              value: f.id,
              groupValue: _selectedFacility?.id,
              onChanged: (v) => setState(() => _selectedFacility = f),
              title: Text(f.name),
              subtitle: Text(f.locationLabel),
            ),
          )
        else
          ..._providers.map(
            (p) => RadioListTile<String>(
              value: p.id,
              groupValue: _selectedProvider?.id,
              onChanged: (v) => setState(() => _selectedProvider = p),
              title: Text(p.name),
              subtitle: Text('${p.specialty ?? 'Provider'} · ${p.facilityName}'),
            ),
          ),
        if (_claimType == 'facility')
          TextField(
            controller: _regNumberCtrl,
            decoration: const InputDecoration(
              labelText: 'Business registration number (optional)',
            ),
          )
        else
          TextField(
            controller: _mdpczCtrl,
            decoration: const InputDecoration(labelText: 'MDPCZ number (optional)'),
          ),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Notes for reviewers (optional)'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _loading ||
                  (_selectedFacility == null && _selectedProvider == null)
              ? null
              : _createDraftClaim,
          child: const Text('Continue to review'),
        ),
      ],
    );
  }

  Widget _buildSubmit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('5. Submit claim', style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        const SizedBox(height: 12),
        _summaryRow('Listing', _selectedName ?? _activeClaim?.displayName ?? '—'),
        _summaryRow('Type', _claimType),
        _summaryRow(
          'Documents',
          _skipDocuments ? 'Skipped (registry email)' : '${_files.length} file(s)',
        ),
        _summaryRow('Status', _activeClaim?.statusLabel ?? 'Draft'),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _loading ? null : _submitClaim,
          child: const Text('Submit for review'),
        ),
      ],
    );
  }

  Widget _buildPending() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('6. Pending review', style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        const SizedBox(height: 12),
        Text(
          'Your claim for ${_selectedName ?? _activeClaim?.displayName ?? 'this listing'} is under review. We typically respond within 2–3 business days.',
          style: AppTextStyles.sm(color: context.appColors.mutedForeground),
        ),
      ],
    );
  }

  Widget _buildApproved() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('7. Claim approved',
            style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        const SizedBox(height: 12),
        Text(
          'You now own this listing. Load your profile to start using MyPractice.',
          style: AppTextStyles.sm(color: context.appColors.mutedForeground),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () async {
            await ref.read(authStateProvider.notifier).loadProfile();
            if (!context.mounted) return;
            context.go('/facility-picker');
          },
          child: const Text('Continue to facilities'),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.sm(color: context.appColors.mutedForeground))),
          Text(value, style: AppTextStyles.sm(fontWeight: AppTextStyles.semibold)),
        ],
      ),
    );
  }
}
