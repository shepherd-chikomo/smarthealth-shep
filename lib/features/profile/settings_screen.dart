import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/auth/auth_state.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          if (auth.isAuthenticated && auth.phone != null)
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Signed in'),
              subtitle: Text(auth.phone!),
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign in'),
              subtitle: const Text('Verify with SMS code'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/login'),
            ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.notificationsTitle),
            subtitle: Text(l10n.notificationsPreferences),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: Text(l10n.notificationsPreferences),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/notifications/preferences'),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Privacy & sharing'),
            subtitle: const Text('Manage facility access to your health data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Encrypted Health Vault (.healthvault)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/backup'),
          ),
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: const Text('Family Members'),
            subtitle: const Text('Manage dependents and health profiles'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/family'),
          ),
          if (auth.isAuthenticated)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              },
            ),
        ],
      ),
    );
  }
}
