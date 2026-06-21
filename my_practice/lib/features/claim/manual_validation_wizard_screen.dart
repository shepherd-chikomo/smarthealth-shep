import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/remote/claims_api_client.dart';
import 'package:my_practice/domain/models/claim_models.dart';
import 'package:my_practice/features/claim/widgets/claim_evidence_picker.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

enum _ValidationStep { credentials, account, otp, manual, done }

class ManualValidationWizardScreen extends ConsumerStatefulWidget {
  const ManualValidationWizardScreen({super.key});

  @override
  ConsumerState<ManualValidationWizardScreen> createState() =>
      _ManualValidationWizardScreenState();
}

class _ManualValidationWizardScreenState
    extends ConsumerState<ManualValidationWizardScreen> {
  _ValidationStep _step = _ValidationStep.credentials;
  bool _loading = false;
  String? _error;

  final _regCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  List<ClaimEvidenceFile> _files = [];

  String _providerName = '';
  String? _sessionId;
  bool _otpSent = false;

  @override
  void dispose() {
    _regCtrl.dispose();
    _emailCtrl.dispose();
    _specialtyCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _validateCredentials() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(claimsApiClientProvider).validatePractitionerCredentials(
            registrationNumber: _regCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            specialty: _specialtyCtrl.text.trim(),
          );
      setState(() {
        _providerName = result['providerName'] as String? ?? '';
        _step = _ValidationStep.account;
      });
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Validation failed');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendAccountOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(myPracticeAuthRepositoryProvider).sendOtp(
            channel: OtpChannel.email,
            email: _emailCtrl.text.trim(),
            context: 'mobile',
          );
      setState(() => _otpSent = true);
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Could not send code');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyAccountOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(myPracticeAuthRepositoryProvider).verifyOtp(
            channel: OtpChannel.email,
            email: _emailCtrl.text.trim(),
            otp: _otpCtrl.text.trim(),
            context: 'mobile',
          );
      final sessionId =
          await ref.read(claimsApiClientProvider).sendPractitionerClaimOtp(
                registrationNumber: _regCtrl.text.trim(),
                email: _emailCtrl.text.trim(),
                specialty: _specialtyCtrl.text.trim(),
              );
      setState(() {
        _sessionId = sessionId;
        _step = _ValidationStep.otp;
        _otpCtrl.clear();
      });
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Verification failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyClaimOtp() async {
    if (_sessionId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(claimsApiClientProvider).verifyPractitionerClaimOtp(
            sessionId: _sessionId!,
            otp: _otpCtrl.text.trim(),
          );
      if (!mounted) return;
      context.go('/claim/registry');
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Invalid claim code');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitManualTicket() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(claimsApiClientProvider).submitManualValidation(
            registrationNumber: _regCtrl.text.trim(),
            specialty: _specialtyCtrl.text.trim(),
            submitterName:
                _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
            submitterEmail: _emailCtrl.text.trim(),
            submitterPhone: _phoneCtrl.text.trim().isEmpty
                ? null
                : normalizeZimbabwePhone(_phoneCtrl.text.trim()),
            evidence: evidencePayload(_files),
          );
      setState(() => _step = _ValidationStep.done);
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Could not submit ticket');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration validation')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (_error != null) ...[
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
          ],
          switch (_step) {
            _ValidationStep.credentials => _buildCredentials(),
            _ValidationStep.account => _buildAccount(),
            _ValidationStep.otp => _buildClaimOtp(),
            _ValidationStep.manual => _buildManual(),
            _ValidationStep.done => _buildDone(),
          },
        ],
      ),
    );
  }

  Widget _buildCredentials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Validate MDPCZ credentials',
            style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _regCtrl,
          decoration: const InputDecoration(labelText: 'Registration number'),
        ),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: _specialtyCtrl,
          decoration: const InputDecoration(labelText: 'Specialty'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _loading ? null : _validateCredentials,
          child: const Text('Validate'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _step = _ValidationStep.manual),
          child: const Text('Skip validation — submit manual review ticket'),
        ),
      ],
    );
  }

  Widget _buildAccount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Matched: $_providerName',
            style: AppTextStyles.sm(color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 12),
        Text('Verify your email to continue.',
            style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        if (!_otpSent) ...[
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _sendAccountOtp,
            child: const Text('Send verification code'),
          ),
        ] else ...[
          TextField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(labelText: 'Email verification code'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _verifyAccountOtp,
            child: const Text('Verify email'),
          ),
        ],
      ],
    );
  }

  Widget _buildClaimOtp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Enter claim verification code',
            style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _otpCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(labelText: 'Claim OTP'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _loading ? null : _verifyClaimOtp,
          child: const Text('Complete claim'),
        ),
      ],
    );
  }

  Widget _buildManual() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Manual validation ticket',
            style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        const SizedBox(height: 12),
        TextField(controller: _regCtrl, decoration: const InputDecoration(labelText: 'Registration number')),
        TextField(controller: _specialtyCtrl, decoration: const InputDecoration(labelText: 'Specialty')),
        TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Your name')),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Phone'),
        ),
        const SizedBox(height: 12),
        ClaimEvidencePicker(
          files: _files,
          onChanged: (f) => setState(() => _files = f),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _loading ? null : _submitManualTicket,
          child: const Text('Submit for manual review'),
        ),
      ],
    );
  }

  Widget _buildDone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Ticket submitted',
            style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        const SizedBox(height: 12),
        Text(
          'SmartHealth will review your credentials. You will be notified when approved.',
          style: AppTextStyles.sm(color: context.appColors.mutedForeground),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => context.go('/claim'),
          child: const Text('Back to claim options'),
        ),
      ],
    );
  }
}
