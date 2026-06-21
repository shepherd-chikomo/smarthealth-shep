import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/remote/claims_api_client.dart';
import 'package:my_practice/domain/models/portal_profile.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

enum _LoginStep { email, claimPreview }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _useEmail = true;
  bool _loading = false;
  String? _error;
  _LoginStep _step = _LoginStep.email;
  ProviderLookupResult? _claimPreview;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendStaffOtp({bool skipRegistryFallback = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final email = _emailCtrl.text.trim();
    final phone =
        !_useEmail ? normalizeZimbabwePhone(_phoneCtrl.text.trim()) : null;
    try {
      final repo = ref.read(myPracticeAuthRepositoryProvider);
      final result = await repo.sendOtp(
        channel: _useEmail ? OtpChannel.email : OtpChannel.phone,
        email: _useEmail ? email : null,
        phone: phone,
        context: 'staff',
      );
      if (!mounted) return;
      _goToOtp(
        otpContext: 'staff',
        channel: result.channel,
        destination: result.destination,
        email: _useEmail ? email : null,
        phone: phone,
      );
    } on DioException catch (e) {
      if (_useEmail &&
          extractApiErrorCode(e) == 'FORBIDDEN' &&
          !skipRegistryFallback) {
        await _attemptRegistryLookup(email);
        return;
      }
      setState(() => _error = extractApiError(e) ?? 'Could not send code');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _attemptRegistryLookup(String email) async {
    try {
      final lookup =
          await ref.read(claimsApiClientProvider).lookupProviderByEmail(email);
      if (!lookup.matched) {
        setState(() {
          _error =
              'No practitioner profile found for this email in the MDPCZ registry.';
        });
        return;
      }
      if (lookup.alreadyClaimed == true) {
        await _sendStaffOtp(skipRegistryFallback: true);
        return;
      }
      if (lookup.ambiguous == true) {
        setState(() {
          _error =
              'Multiple profiles match this email. Contact validation@smarthealth.co.zw.';
        });
        return;
      }
      setState(() {
        _claimPreview = lookup;
        _step = _LoginStep.claimPreview;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _sendClaimOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final email = _emailCtrl.text.trim();
    try {
      final repo = ref.read(myPracticeAuthRepositoryProvider);
      final result = await repo.sendOtp(
        channel: OtpChannel.email,
        email: email,
        context: 'practitioner',
      );
      if (!mounted) return;
      _goToOtp(
        otpContext: 'practitioner',
        channel: result.channel,
        destination: result.destination,
        email: email,
      );
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Could not send code');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToOtp({
    required String otpContext,
    required OtpChannel channel,
    required String destination,
    String? email,
    String? phone,
  }) {
    final params = {
      'context': otpContext,
      'channel': channel.name,
      'destination': destination,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    context.push('/otp?$query');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
        leading: _step == _LoginStep.claimPreview
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _step = _LoginStep.email;
                  _claimPreview = null;
                  _error = null;
                }),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _step == _LoginStep.claimPreview
            ? _buildClaimPreview()
            : _buildEmailStep(),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'MyPractice',
          style: AppTextStyles.xxl(
            fontWeight: AppTextStyles.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          'Practitioner sign in',
          style: AppTextStyles.sm(color: context.appColors.mutedForeground),
        ),
        const SizedBox(height: 24),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Email')),
            ButtonSegment(value: false, label: Text('Phone')),
          ],
          selected: {_useEmail},
          onSelectionChanged: (s) => setState(() => _useEmail = s.first),
        ),
        const SizedBox(height: 16),
        if (_useEmail)
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          )
        else
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Mobile number'),
          ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const Spacer(),
        FilledButton(
          onPressed: _loading ? null : _sendStaffOtp,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send OTP'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.push('/claim'),
          child: const Text('New user? Claim your profile'),
        ),
      ],
    );
  }

  Widget _buildClaimPreview() {
    final preview = _claimPreview!;
    final provider = preview.provider!;
    final linkedCount = preview.linkedFacilities.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Claim your profile',
          style: AppTextStyles.lg(fontWeight: AppTextStyles.bold),
        ),
        const SizedBox(height: 8),
        Text(
          provider.name,
          style: AppTextStyles.base(fontWeight: AppTextStyles.semibold),
        ),
        if (provider.specialty != null)
          Text(
            provider.specialty!,
            style: AppTextStyles.sm(color: context.appColors.mutedForeground),
          ),
        const SizedBox(height: 12),
        Text(
          linkedCount > 0
              ? '$linkedCount linked ${linkedCount == 1 ? 'facility' : 'facilities'} in the registry.'
              : 'Your practitioner profile is ready to claim.',
          style: AppTextStyles.sm(color: context.appColors.mutedForeground),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const Spacer(),
        FilledButton(
          onPressed: _loading ? null : _sendClaimOtp,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify email & claim profile'),
        ),
        TextButton(
          onPressed: () => context.push(
            '/claim/registry?email=${Uri.encodeComponent(_emailCtrl.text.trim())}',
          ),
          child: const Text('Open full claim wizard'),
        ),
      ],
    );
  }
}
