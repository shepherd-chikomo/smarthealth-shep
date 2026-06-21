import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/remote/claims_api_client.dart';
import 'package:my_practice/domain/models/portal_profile.dart';
import 'package:my_practice/features/claim/widgets/claim_step_chips.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

enum _RegistryStep { account, facilities, complete }

class RegistryClaimWizardScreen extends ConsumerStatefulWidget {
  const RegistryClaimWizardScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<RegistryClaimWizardScreen> createState() =>
      _RegistryClaimWizardScreenState();
}

class _RegistryClaimWizardScreenState
    extends ConsumerState<RegistryClaimWizardScreen> {
  static const _stepLabels = ['Account', 'Facilities', 'Complete'];

  _RegistryStep _step = _RegistryStep.account;
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _otpSent = false;
  String _otpDestination = '';
  String? _lookupPreview;
  String _providerName = '';
  String? _providerSpecialty;
  List<LinkedFacility> _linkedFacilities = [];
  final Set<String> _ownedIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailCtrl.text = widget.initialEmail!;
    }
    Future.microtask(_resumeIfAuthed);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  int get _stepIndex {
    switch (_step) {
      case _RegistryStep.account:
        return 0;
      case _RegistryStep.facilities:
        return 1;
      case _RegistryStep.complete:
        return 2;
    }
  }

  Future<void> _resumeIfAuthed() async {
    final repo = ref.read(myPracticeAuthRepositoryProvider);
    if (!await repo.hasSession()) return;
    try {
      final status = await ref.read(claimsApiClientProvider).onboardingStatus();
      if (status.phase == 'unclaimed') return;
      setState(() {
        _providerName = status.provider?.name ?? '';
        _providerSpecialty = status.provider?.specialty;
        _linkedFacilities = status.linkedFacilities;
        _ownedIds.addAll(
          status.linkedFacilities.where((f) => f.isOwnedByMe).map((f) => f.id),
        );
        _step = status.phase == 'has_facilities'
            ? _RegistryStep.complete
            : _RegistryStep.facilities;
      });
      if (_step == _RegistryStep.facilities) {
        await _refreshFacilities();
      }
    } catch (_) {}
  }

  Future<void> _refreshFacilities() async {
    try {
      final facilities =
          await ref.read(claimsApiClientProvider).myPrimaryFacilities();
      if (!mounted) return;
      setState(() {
        _linkedFacilities = facilities;
        _ownedIds.addAll(
          facilities.where((f) => f.isOwnedByMe).map((f) => f.id),
        );
      });
    } catch (_) {}
  }

  Future<void> _lookupEmail() async {
    setState(() {
      _loading = true;
      _error = null;
      _lookupPreview = null;
    });
    try {
      final lookup = await ref
          .read(claimsApiClientProvider)
          .lookupProviderByEmail(_emailCtrl.text.trim());
      if (!lookup.matched) {
        throw Exception(
          'No practitioner profile found. Try manual claim or registration validation.',
        );
      }
      if (lookup.alreadyClaimed == true) {
        throw Exception(
          'Profile already claimed. Sign in with your work email instead.',
        );
      }
      if (lookup.ambiguous == true) {
        throw Exception(
          'Multiple profiles match. Contact validation@smarthealth.co.zw.',
        );
      }
      final provider = lookup.provider!;
      final count = lookup.linkedFacilities.length;
      setState(() {
        _providerName = provider.name;
        _providerSpecialty = provider.specialty;
        _linkedFacilities = lookup.linkedFacilities;
        _lookupPreview = count > 0
            ? '${provider.name} — $count linked ${count == 1 ? 'facility' : 'facilities'}'
            : '${provider.name} — profile ready to claim';
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(myPracticeAuthRepositoryProvider).sendOtp(
            channel: OtpChannel.email,
            email: _emailCtrl.text.trim(),
            context: 'practitioner',
          );
      setState(() {
        _otpDestination = result.destination;
        _otpSent = true;
      });
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Could not send code');
    } catch (e) {
      setState(() => _error = e.toString());
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
            channel: OtpChannel.email,
            email: _emailCtrl.text.trim(),
            otp: _otpCtrl.text.trim(),
            context: 'practitioner',
          );
      await ref.read(authStateProvider.notifier).loadProfile();
      final status = await ref.read(claimsApiClientProvider).onboardingStatus();
      if (!mounted) return;
      setState(() {
        _providerName = status.provider?.name ?? _providerName;
        _providerSpecialty = status.provider?.specialty ?? _providerSpecialty;
        _linkedFacilities = status.linkedFacilities;
        _ownedIds.addAll(
          status.linkedFacilities.where((f) => f.isOwnedByMe).map((f) => f.id),
        );
        _step = status.phase == 'has_facilities'
            ? _RegistryStep.complete
            : _RegistryStep.facilities;
      });
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Invalid or expired code');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _claimFacility(String id) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(claimsApiClientProvider).instantClaimFacility(id);
      setState(() => _ownedIds.add(id));
      final status = await ref.read(claimsApiClientProvider).onboardingStatus();
      await ref.read(authStateProvider.notifier).loadProfile();
      if (!mounted) return;
      if (status.phase == 'has_facilities') {
        setState(() => _step = _RegistryStep.complete);
      }
      await _refreshFacilities();
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Could not claim facility');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _finish() async {
    await ref.read(authStateProvider.notifier).loadProfile();
    if (!mounted) return;
    final auth = ref.read(authStateProvider);
    if (auth.status == AuthStatus.authenticated) {
      context.go('/dashboard');
    } else {
      context.go('/facility-picker');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim practitioner profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Verify your registry email to claim your MDPCZ profile and linked facilities.',
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
            _RegistryStep.account => _buildAccountStep(),
            _RegistryStep.facilities => _buildFacilitiesStep(),
            _RegistryStep.complete => _buildCompleteStep(),
          },
        ],
      ),
    );
  }

  Widget _buildAccountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('1. Verify registry email',
            style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        const SizedBox(height: 12),
        if (!_otpSent) ...[
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            enabled: !_loading,
          ),
          if (_lookupPreview != null) ...[
            const SizedBox(height: 12),
            Text(_lookupPreview!,
                style: AppTextStyles.sm(
                    color: Theme.of(context).colorScheme.primary)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading
                ? null
                : (_lookupPreview == null ? _lookupEmail : _sendOtp),
            child: Text(_lookupPreview == null ? 'Find my profile' : 'Send code'),
          ),
          if (_lookupPreview != null)
            TextButton(
              onPressed: () => setState(() {
                _lookupPreview = null;
                _providerName = '';
              }),
              child: const Text('Use a different email'),
            ),
        ] else ...[
          if (_providerName.isNotEmpty)
            Text('Claiming profile for $_providerName',
                style: AppTextStyles.sm(
                    color: Theme.of(context).colorScheme.primary)),
          Text('Code sent to $_otpDestination'),
          const SizedBox(height: 12),
          TextField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(labelText: 'Verification code'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _verifyOtp,
            child: const Text('Verify & claim profile'),
          ),
          TextButton(
            onPressed: _loading ? null : _sendOtp,
            child: const Text('Resend code'),
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.push('/claim/manual'),
          child: const Text('Not in registry? Use manual claim'),
        ),
      ],
    );
  }

  Widget _buildFacilitiesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('2. Claim your facilities',
            style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        const SizedBox(height: 8),
        Text(
          'Linked to $_providerName in the HPA registry.',
          style: AppTextStyles.sm(color: context.appColors.mutedForeground),
        ),
        const SizedBox(height: 16),
        if (_linkedFacilities.isEmpty)
          Text(
            'No facilities linked yet. Contact validation@smarthealth.co.zw if you expect sites here.',
            style: AppTextStyles.sm(color: context.appColors.mutedForeground),
          )
        else
          ..._linkedFacilities.map(_facilityTile),
        if (_ownedIds.isNotEmpty) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : () => setState(() => _step = _RegistryStep.complete),
            child: const Text('Continue'),
          ),
        ],
      ],
    );
  }

  Widget _facilityTile(LinkedFacility f) {
    final owned = f.isOwnedByMe || _ownedIds.contains(f.id);
    final unavailable = f.isClaimed && !owned;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppTheme.themedCard(
        context: context,
        child: ListTile(
          title: Text(f.name),
          subtitle: Text('${f.city ?? 'Zimbabwe'} · ${f.statusLabel}'),
          trailing: owned
              ? const Icon(Icons.check_circle, color: Colors.green)
              : unavailable
                  ? null
                  : FilledButton(
                      onPressed: _loading ? null : () => _claimFacility(f.id),
                      child: const Text('Claim'),
                    ),
        ),
      ),
    );
  }

  Widget _buildCompleteStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('3. Ready to practice',
            style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
        const SizedBox(height: 8),
        Text(
          'Your profile and ${_ownedIds.isEmpty ? 'facilities are' : '${_ownedIds.length} ${_ownedIds.length == 1 ? 'facility is' : 'facilities are'}'} set up.',
          style: AppTextStyles.sm(color: context.appColors.mutedForeground),
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: _finish, child: const Text('Open MyPractice')),
      ],
    );
  }
}
