import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/features/notifications/models/notification_model.dart';
import 'package:smarthealth_shep/features/notifications/providers/notification_providers.dart';

import 'package:smarthealth_shep/shared/widgets/app_shell_with_bottom_nav.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  late Future<List<NotificationPreference>> _future;

  static const _categories = [
    'appointment_reminder',
    'appointment_confirmed',
    'appointment_rescheduled',
    'appointment_cancellation',
    'queue_update',
    'emergency_alert',
    'verification_update',
    'claim_approval',
    'provider_message',
    'facility_announcement',
    'general',
  ];

  static const _channels = ['push', 'sms', 'email'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPrefs());
  }

  void _loadPrefs() {
    setState(() {
      _future = ref.read(notificationRepositoryProvider).listPreferences();
    });
  }

  Future<void> _toggle(NotificationPreference pref, bool value) async {
    await ref.read(notificationRepositoryProvider).updatePreference(
          channel: pref.channel,
          category: pref.category,
          isEnabled: value,
          quietHoursStart: pref.quietHoursStart,
          quietHoursEnd: pref.quietHoursEnd,
        );
    setState(() {
      _future = ref.read(notificationRepositoryProvider).listPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShellWithBottomNav(
      appBar: AppBar(title: const Text('Notification preferences')),
      body: FutureBuilder<List<NotificationPreference>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final prefs = snapshot.data!;
          final prefMap = {
            for (final p in prefs) '${p.category}:${p.channel}': p,
          };

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Choose how you receive each type of notification. '
                  'Push is tried first, then SMS and email as fallbacks.',
                ),
              ),
              ..._categories.map((category) {
                return ExpansionTile(
                  title: Text(_label(category)),
                  children: _channels.map((channel) {
                    final key = '$category:$channel';
                    final pref = prefMap[key] ??
                        NotificationPreference(
                          channel: channel,
                          category: category,
                          isEnabled: true,
                        );
                    return SwitchListTile(
                      title: Text(channel.toUpperCase()),
                      value: pref.isEnabled,
                      onChanged: (v) => _toggle(pref, v),
                    );
                  }).toList(),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  String _label(String category) => category
      .split('_')
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
