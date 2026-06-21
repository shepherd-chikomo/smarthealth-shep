import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:smarthealth_shep/core/auth/auth_repository.dart';
import 'package:smarthealth_shep/core/auth/auth_state.dart';
import 'package:smarthealth_shep/core/backup/post_auth_navigation.dart';
import 'package:smarthealth_shep/core/router/app_router.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/widgets/otp_input.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.channel,
    required this.destination,
    this.email,
    this.phone,
  });

  final OtpChannel channel;
  final String destination;
  final String? email;
  final String? phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> with CodeAutoFill {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _listenForSmsAutofill();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
  }

  Future<void> _listenForSmsAutofill() async {
    if (widget.channel != OtpChannel.phone) return;
    try {
      await SmsAutoFill().listenForCode();
    } catch (_) {
      // SMS listener is best-effort; keyboard autofill still works.
    }
  }

  @override
  void codeUpdated() {
    final smsCode = code;
    if (smsCode == null || smsCode.length != 6 || _loading) return;
    _otpController.text = smsCode;
    _verify(smsCode);
  }

  @override
  void dispose() {
    cancel();
    SmsAutoFill().unregisterListener();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verify(String otp) async {
    if (otp.length != 6 || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = await ref.read(authRepositoryProvider).verifyOtp(
            channel: widget.channel,
            otp: otp,
            email: widget.email,
            phone: widget.phone,
          );
      // Resolve backup route before sign-in: auth redirect unmounts this screen.
      await PostAuthNavigation.resolveRouteForOtpSignIn();
      await ref.read(authControllerProvider.notifier).completeSignIn(session);
      TextInput.finishAutofillContext(shouldSave: false);
      ref.read(routerProvider).go(PostAuthNavigation.consumePendingRoute());
    } on DioException catch (e) {
      setState(() => _error = _extractError(e) ?? 'Invalid or expired code');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _extractError(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      return (data['error'] as Map)['message'] as String?;
    }
    return error.message;
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);
    final autofillHint = widget.channel == OtpChannel.phone
        ? 'Your SMS code should appear above the keyboard for autofill.'
        : 'Your email code should appear above the keyboard for autofill.';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Verify code'),
        backgroundColor: colors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter the 6-digit code sent to ${widget.destination}',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              autofillHint,
              style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Opacity(
              opacity: _loading ? 0.5 : 1,
              child: AbsorbPointer(
                absorbing: _loading,
                child: OtpInput(
                  controller: _otpController,
                  focusNode: _focusNode,
                  onCompleted: _verify,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: colors.emergency),
              ),
            ],
            if (_loading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            const Spacer(),
            TextButton(
              onPressed: _loading ? null : () => context.go('/login'),
              child: Text(
                widget.channel == OtpChannel.email
                    ? 'Use a different email'
                    : 'Use a different number',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
