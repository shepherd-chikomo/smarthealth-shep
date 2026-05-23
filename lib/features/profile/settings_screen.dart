import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: const Text('Family Members'),
            subtitle: const Text('Manage dependents and health profiles'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/family'),
          ),
        ],
      ),
    );
  }
}
