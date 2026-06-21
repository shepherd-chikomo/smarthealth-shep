import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/remote/claims_api_client.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final params = GoRouterState.of(context).uri.queryParameters;
    final channel =
        params['channel'] == 'phone' ? OtpChannel.phone : OtpChannel.email;
    final email = params['email'];
    final phone = params['phone'];
    final otpContext = params['context'] ?? 'staff';

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(myPracticeAuthRepositoryProvider);
      await repo.verifyOtp(
        channel: channel,
        otp: _otpCtrl.text.trim(),
        email: email != null && email.isNotEmpty ? email : null,
        phone: phone != null && phone.isNotEmpty ? phone : null,
        context: otpContext,
      );
      await ref.read(authStateProvider.notifier).loadProfile();
      if (!mounted) return;
      final auth = ref.read(authStateProvider);
      if (auth.status == AuthStatus.needsFacility ||
          (auth.status == AuthStatus.authenticated &&
              ref.read(facilityIdProvider) == null)) {
        context.go('/facility-picker');
      } else if (auth.status == AuthStatus.authenticated) {
        context.go('/dashboard');
      } else {
        setState(
          () => _error = auth.error ?? 'Sign in failed. Try again.',
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _error = extractApiError(e) ?? 'Invalid or expired code');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final destination =
        GoRouterState.of(context).uri.queryParameters['destination'] ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Enter the code sent to $destination'),
            const SizedBox(height: 16),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'OTP code'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _verify,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
