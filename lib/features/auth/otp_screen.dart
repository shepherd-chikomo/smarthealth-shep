import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/auth/auth_repository.dart';
import 'package:smarthealth_shep/core/auth/auth_state.dart';
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

class _OtpScreenState extends ConsumerState<OtpScreen> {
  late final List<TextEditingController> _controllers;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
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
      await ref.read(authControllerProvider.notifier).completeSignIn(session);
      if (!mounted) return;
      context.go('/home');
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
    return Scaffold(
      appBar: AppBar(title: Text('Verify code')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter the 6-digit code sent to ${widget.destination}',
              style: TextStyle(color: HomeDashboardColors.of(context).textSecondary),
            ),
            SizedBox(height: 24),
            Opacity(
              opacity: _loading ? 0.5 : 1,
              child: AbsorbPointer(
                absorbing: _loading,
                child: OtpInput(
                  controllers: _controllers,
                  onCompleted: _verify,
                ),
              ),
            ),
            if (_error != null) ...[
              SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: HomeDashboardColors.of(context).emergency),
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
