import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/feature_flags/feature_flags_notifier.dart';
import 'package:my_practice/core/theme/theme_mode_provider.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';

class FacilityScreen extends ConsumerWidget {
  const FacilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authStateProvider).profile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('More', style: PracticeDesignTokens.pageTitle(context)),
        const SizedBox(height: 8),
          if (profile != null)
            ListTile(
              title: Text(profile.displayName),
              subtitle: Text(profile.role),
            ),
          ListTile(
            leading: const Icon(Icons.local_hospital),
            title: const Text('Facility Management'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Team Management'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Claim Facility'),
            onTap: () {},
          ),
          if (ref.featureEnabled(FeatureFlagKeys.claimsModule))
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Claims Dashboard'),
              onTap: () => context.push('/claims'),
            ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Reports & Analytics'),
            onTap: () => context.push('/reports'),
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Internal Messaging'),
            onTap: () => context.push('/messages'),
          ),
          ListTile(
            leading: Icon(
              ref.watch(themeModeProvider) == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            title: const Text('Appearance'),
            subtitle: Text(
              ref.watch(themeModeProvider) == ThemeMode.dark
                  ? 'Dark mode'
                  : 'Light mode',
            ),
            onTap: () =>
                ref.read(themeModeProvider.notifier).toggleLightDark(),
          ),
          const Divider(),
          _FutureModuleTile(
            flag: FeatureFlagKeys.connect,
            title: 'SmartHealth Connect',
            module: 'connect',
          ),
          _FutureModuleTile(
            flag: FeatureFlagKeys.switchModule,
            title: 'SmartHealth Switch',
            module: 'switch',
          ),
          _FutureModuleTile(
            flag: FeatureFlagKeys.insights,
            title: 'SmartHealth Insights',
            module: 'insights',
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () => ref.read(authStateProvider.notifier).signOut(),
          ),
          if (MyPracticeConfig.devMode)
            const ListTile(
              title: Text('Development Mode'),
              subtitle: Text('Using seed data'),
            ),
        ],
      );
  }
}

class _FutureModuleTile extends ConsumerWidget {
  const _FutureModuleTile({
    required this.flag,
    required this.title,
    required this.module,
  });

  final String flag;
  final String title;
  final String module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.featureEnabled(flag)) return const SizedBox.shrink();
    return ListTile(
      leading: const Icon(Icons.construction),
      title: Text(title),
      subtitle: const Text('Architecture preview'),
      onTap: () => context.push('/future/$module'),
    );
  }
}
