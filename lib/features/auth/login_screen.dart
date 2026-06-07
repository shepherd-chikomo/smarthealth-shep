import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth_shep/core/auth/auth_repository.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  OtpChannel _channel = OtpChannel.email;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPreferredChannel();
  }

  Future<void> _loadPreferredChannel() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('otp_preferred_channel');
    if (!mounted || saved == null) return;
    setState(() {
      _channel = saved == 'phone' ? OtpChannel.phone : OtpChannel.email;
    });
  }

  Future<void> _savePreferredChannel(OtpChannel channel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('otp_preferred_channel', channel.name);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim().isEmpty
        ? null
        : normalizeZimbabwePhone(_phoneController.text.trim());

    try {
      await _savePreferredChannel(_channel);
      final result = await ref.read(authRepositoryProvider).sendOtp(
            channel: _channel,
            email: _channel == OtpChannel.email ? email : null,
            phone: _channel == OtpChannel.phone ? phone : null,
          );
      if (!mounted) return;
      final params = {
        'channel': result.channel.name,
        'destination': result.destination,
        if (result.channel == OtpChannel.email) 'email': email,
        if (result.channel == OtpChannel.phone && phone != null) 'phone': phone,
      };
      final query = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      context.go('/otp?$query');
    } on DioException catch (e) {
      final message = _extractError(e) ?? 'Could not send verification code';
      setState(() => _error = message);
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
      backgroundColor: HomeDashboardColors.of(context).background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: AutofillGroup(
            child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 32),
                Text(
                  'Sign in to MyHealth',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: HomeDashboardColors.of(context).textPrimary,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  'Choose email or phone. We will send a one-time verification code.',
                  style: TextStyle(color: HomeDashboardColors.of(context).textSecondary),
                ),
                const SizedBox(height: 24),
                SegmentedButton<OtpChannel>(
                  segments: const [
                    ButtonSegment(
                      value: OtpChannel.email,
                      label: Text('Email'),
                      icon: Icon(Icons.email_outlined),
                    ),
                    ButtonSegment(
                      value: OtpChannel.phone,
                      label: Text('Phone'),
                      icon: Icon(Icons.phone_outlined),
                    ),
                  ],
                  selected: {_channel},
                  onSelectionChanged: _loading
                      ? null
                      : (selection) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() => _channel = selection.first);
                        },
                ),
                const SizedBox(height: 24),
                if (_channel == OtpChannel.email)
                  TextFormField(
                    key: const ValueKey('login-email'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      hintText: 'you@example.com',
                      border: OutlineInputBorder(),
                    ),
                    validator: validateEmail,
                    enabled: !_loading,
                    onFieldSubmitted: (_) => _sendOtp(),
                  )
                else
                  TextFormField(
                    key: const ValueKey('login-phone'),
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    decoration: const InputDecoration(
                      labelText: 'Mobile number',
                      hintText: '077 123 4567',
                      prefixText: '+263 ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter your mobile number';
                      }
                      return validateZimbabwePhone(value);
                    },
                    enabled: !_loading,
                    onFieldSubmitted: (_) => _sendOtp(),
                  ),
                if (_error != null) ...[
                  SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: HomeDashboardColors.of(context).emergency),
                  ),
                ],
                Spacer(),
                FilledButton(
                  onPressed: _loading ? null : _sendOtp,
                  style: FilledButton.styleFrom(
                    backgroundColor: HomeDashboardColors.of(context).primary,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Continue'),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
