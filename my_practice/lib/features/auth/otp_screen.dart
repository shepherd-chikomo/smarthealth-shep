import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final params = GoRouterState.of(context).uri.queryParameters;
    final channel =
        params['channel'] == 'phone' ? OtpChannel.phone : OtpChannel.email;
    final destination = params['destination'] ?? '';

    setState(() => _loading = true);
    try {
      final repo = ref.read(myPracticeAuthRepositoryProvider);
      await repo.verifyOtp(
        channel: channel,
        otp: _otpCtrl.text.trim(),
        email: channel == OtpChannel.email ? destination : null,
        phone: channel == OtpChannel.phone ? destination : null,
      );
      await ref.read(authStateProvider.notifier).loadProfile();
      if (!mounted) return;
      final auth = ref.read(authStateProvider);
      if (auth.status == AuthStatus.needsFacility) {
        context.go('/facility-picker');
      } else {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
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
              decoration: const InputDecoration(labelText: 'OTP code'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _verify,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
