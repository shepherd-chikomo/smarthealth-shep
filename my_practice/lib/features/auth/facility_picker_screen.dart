import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class FacilityPickerScreen extends ConsumerWidget {
  const FacilityPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final facilities = auth.profile?.facilities ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Select facility')),
      body: facilities.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  auth.error ??
                      'No facilities linked to your account. Contact your administrator.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: facilities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final f = facilities[index];
                return AppTheme.themedCard(
                  context: context,
                  child: ListTile(
                    title: Text(f.name),
                    subtitle: Text(f.role),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await ref
                          .read(authStateProvider.notifier)
                          .selectFacility(f.id);
                      if (!context.mounted) return;
                      context.go('/dashboard');
                    },
                  ),
                );
              },
            ),
    );
  }
}
