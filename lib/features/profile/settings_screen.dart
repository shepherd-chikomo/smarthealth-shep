import 'package:flutter/material.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: const Center(child: Text('Settings — placeholder')),
    );
  }
}
