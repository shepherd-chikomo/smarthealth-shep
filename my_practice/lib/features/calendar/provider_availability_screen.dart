import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/data/seed/dev_provider_schedule.dart';
import 'package:my_practice/domain/models/facility_hour.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/features/calendar/facility_hours_editor.dart';

final providerScheduleProvider =
    FutureProvider.autoDispose<List<FacilityHour>>((ref) {
  return ref.read(facilityRepositoryProvider).getProviderSchedule(
        DevProviderSchedule.defaultProviderId,
      );
});

class ProviderAvailabilityScreen extends ConsumerWidget {
  const ProviderAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(providerScheduleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Provider Schedule')),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (hours) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Your weekly schedule', style: PracticeDesignTokens.pageTitle(context)),
            Text(
              'Patients see these slots when booking via MyHealth.',
              style: PracticeDesignTokens.metadata(context),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: PracticeDesignTokens.previewCardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Working hours',
                          style: PracticeDesignTokens.sectionTitle(context)),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          await showFacilityHoursEditor(
                            context,
                            hours,
                            title: 'Edit provider schedule',
                            onSave: (updated) => ref
                                .read(facilityRepositoryProvider)
                                .updateProviderSchedule(
                                  DevProviderSchedule.defaultProviderId,
                                  updated,
                                ),
                          );
                          ref.invalidate(providerScheduleProvider);
                        },
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final h in hours)
                    Text(h.displayLine,
                        style: PracticeDesignTokens.clinicalNote(context)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (MyPracticeConfig.useLocalDevSeed)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: PracticeDesignTokens.previewCardDecoration(context),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dev mode saves locally. Use pilot login to sync to dev server.',
                        style: PracticeDesignTokens.metadata(context),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
