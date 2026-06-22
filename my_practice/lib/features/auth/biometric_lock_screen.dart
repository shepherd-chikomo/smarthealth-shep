import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/core/security/app_lock_notifier.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_icon_widgets.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Prompt automatically on open.
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final unlocked = await ref.read(appLockProvider.notifier).authenticateAndUnlock();
    if (!mounted) return;
    if (unlocked) {
      context.go('/dashboard');
    } else {
      setState(() {
        _busy = false;
        _error = 'Authentication failed. Please try again.';
      });
    }
  }

  Future<void> _signOut() async {
    await ref.read(myPracticeAuthRepositoryProvider).signOut();
    ref.read(appLockProvider.notifier).unlock();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final colors = context.appColors;
    final name = auth.profile?.displayName ?? 'Welcome back';
    final email = auth.session?.email ?? auth.session?.phone ?? '';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PracticeBrandMark(size: 56),
                const SizedBox(height: 32),
                Text(
                  name,
                  style: PracticeDesignTokens.inter(
                    size: 22,
                    weight: FontWeight.w700,
                    color: colors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: PracticeDesignTokens.metadata(context),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 48),
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: colors.mutedForeground,
                ),
                const SizedBox(height: 16),
                Text(
                  'Session locked',
                  style: PracticeDesignTokens.inter(
                    size: 16,
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _authenticate,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.fingerprint, size: 20),
                    label: Text(_busy ? 'Verifying…' : 'Unlock with biometrics / pattern'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: PracticeDesignTokens.metadata(context).copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _busy ? null : _signOut,
                  child: Text(
                    'Sign out instead',
                    style: PracticeDesignTokens.inter(
                      size: 14,
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
