import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(myPracticeAuthRepositoryProvider);
      final result = await repo.sendOtp(
        channel: _useEmail ? OtpChannel.email : OtpChannel.phone,
        email: _useEmail ? _emailCtrl.text.trim() : null,
        phone: !_useEmail ? normalizeZimbabwePhone(_phoneCtrl.text) : null,
      );
      if (!mounted) return;
      context.push(
        '/otp?channel=${result.channel.name}&destination=${Uri.encodeComponent(result.destination)}',
      );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
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
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _sendOtp,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
