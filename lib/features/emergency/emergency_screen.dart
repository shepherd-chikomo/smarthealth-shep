import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/data/emergency_repository.dart';
import 'package:smarthealth_shep/shared/widgets/emergency_tile.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final servicesAsync = ref.watch(_emergencyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navEmergency)),
      body: servicesAsync.when(
        data: (services) => ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            return EmergencyTile(
              service: services[index],
              pulse: index == 0,
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}

final _emergencyProvider = FutureProvider((ref) {
  return ref.read(emergencyRepositoryProvider).getServices();
});
