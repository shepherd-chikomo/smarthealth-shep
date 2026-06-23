import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/remote/claims_api_client.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/domain/models/facility_hour.dart';
import 'package:my_practice/domain/models/facility_profile_settings.dart';
import 'package:my_practice/domain/models/facility_service.dart';
import 'package:my_practice/features/calendar/facility_hours_editor.dart';
import 'package:my_practice/features/facility/facility_profile_providers.dart';
import 'package:my_practice/shared/widgets/practice_more_app_bar.dart';

const _storage = FlutterSecureStorage();

final myScheduleProvider = FutureProvider.autoDispose<_MyScheduleData>((ref) async {
  final auth = ref.watch(authStateProvider);
  final providerId = auth.profile?.provider?.id;
  final facilityId = ref.watch(facilityIdProvider);
  if (providerId == null || providerId.isEmpty || facilityId == null) {
    return const _MyScheduleData.empty();
  }

  final repo = ref.watch(facilityRepositoryProvider);
  final profile = await ref.watch(facilityProfileProvider.future);
  final settings = FacilityProfileSettings.fromJson(
    profile['profileSettings'] as Map<String, dynamic>?,
  );
  final hours = await repo.getProviderSchedule(providerId);
  final serviceIds = await repo.getDoctorServiceIds(providerId);

  final reminderKey = 'schedule_reminder_$facilityId';
  final reminderRaw = await _storage.read(key: reminderKey);
  var reminderEnabled = true;
  int reminderDay = 0;
  int reminderHour = 14;
  if (reminderRaw != null && reminderRaw.contains(':')) {
    final parts = reminderRaw.split(':');
    if (parts.length >= 3) {
      reminderEnabled = parts[0] == '1';
      reminderDay = int.tryParse(parts[1]) ?? 0;
      reminderHour = int.tryParse(parts[2]) ?? 14;
    } else {
      reminderDay = int.tryParse(parts[0]) ?? 0;
      reminderHour = int.tryParse(parts[1]) ?? 14;
    }
  }

  return _MyScheduleData(
    providerId: providerId,
    hours: hours,
    facilityServices: settings.services,
    selectedServiceIds: serviceIds.toSet(),
    reminderEnabled: reminderEnabled,
    reminderDay: reminderDay,
    reminderHour: reminderHour,
  );
});

class _MyScheduleData {
  const _MyScheduleData({
    required this.providerId,
    required this.hours,
    required this.facilityServices,
    required this.selectedServiceIds,
    required this.reminderEnabled,
    required this.reminderDay,
    required this.reminderHour,
  });

  const _MyScheduleData.empty()
      : providerId = null,
        hours = const [],
        facilityServices = const [],
        selectedServiceIds = const {},
        reminderEnabled = true,
        reminderDay = 0,
        reminderHour = 14;

  final String? providerId;
  final List<FacilityHour> hours;
  final List<FacilityServiceEntry> facilityServices;
  final Set<String> selectedServiceIds;
  final bool reminderEnabled;
  final int reminderDay;
  final int reminderHour;
}

/// Practitioner weekly availability and services at the active facility.
class ProviderAvailabilityScreen extends ConsumerStatefulWidget {
  const ProviderAvailabilityScreen({super.key});

  @override
  ConsumerState<ProviderAvailabilityScreen> createState() =>
      _ProviderAvailabilityScreenState();
}

class _ProviderAvailabilityScreenState
    extends ConsumerState<ProviderAvailabilityScreen> {
  bool _saving = false;
  String? _error;
  String? _success;
  bool? _reminderEnabled;
  int? _reminderDay;
  int? _reminderHour;

  static const _dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  Future<void> _saveServices(
    String providerId,
    Set<String> selected,
  ) async {
    setState(() {
      _saving = true;
      _error = null;
      _success = null;
    });
    try {
      await ref
          .read(facilityRepositoryProvider)
          .updateDoctorServiceIds(providerId, selected.toList());
      ref.invalidate(myScheduleProvider);
      if (mounted) setState(() => _success = 'Services saved.');
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Could not save services');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveReminder(
    String facilityId, {
    required bool enabled,
    required int day,
    required int hour,
  }) async {
    setState(() {
      _reminderEnabled = enabled;
      _reminderDay = day;
      _reminderHour = hour;
    });
    await _storage.write(
      key: 'schedule_reminder_$facilityId',
      value: '${enabled ? 1 : 0}:$day:$hour',
    );
    if (mounted) setState(() => _success = 'Reminder preference saved.');
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(myScheduleProvider);
    final facilityId = ref.watch(facilityIdProvider);

    return Scaffold(
      appBar: practiceMoreAppBar(context, 'My Schedule'),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) {
          if (data.providerId == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Link your practitioner profile to set your schedule. '
                  'Claim your MDPCZ profile if you have not already.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final selected = Set<String>.from(data.selectedServiceIds);
          final reminderEnabled = _reminderEnabled ?? data.reminderEnabled;
          final reminderDay = _reminderDay ?? data.reminderDay;
          final reminderHour = _reminderHour ?? data.reminderHour;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_error != null)
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              if (_success != null)
                Text(_success!, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              Text('My weekly schedule', style: PracticeDesignTokens.pageTitle(context)),
              Text(
                'Patients see these slots when booking at this facility. '
                'Syncs with the facility portal appointments view.',
                style: PracticeDesignTokens.metadata(context),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: PracticeDesignTokens.previewCardDecoration(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text('Weekly hours',
                            style: PracticeDesignTokens.sectionTitle(context)),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            await showFacilityHoursEditor(
                              context,
                              data.hours,
                              title: 'Edit weekly schedule',
                              onSave: (updated) => ref
                                  .read(facilityRepositoryProvider)
                                  .updateProviderSchedule(
                                    data.providerId!,
                                    updated,
                                  ),
                            );
                            ref.invalidate(myScheduleProvider);
                          },
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final h in data.hours)
                      Text(h.displayLine,
                          style: PracticeDesignTokens.clinicalNote(context)),
                    const SizedBox(height: 8),
                    Text(
                      'This repeating weekly pattern applies until you change individual days.',
                      style: PracticeDesignTokens.metadata(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: PracticeDesignTokens.previewCardDecoration(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Services I offer here',
                        style: PracticeDesignTokens.sectionTitle(context)),
                    const SizedBox(height: 4),
                    Text(
                      'Select from services configured on the facility profile.',
                      style: PracticeDesignTokens.metadata(context),
                    ),
                    const SizedBox(height: 8),
                    if (data.facilityServices.isEmpty)
                      Text(
                        'No services on the facility profile yet. Add them under Facility profile → Services.',
                        style: PracticeDesignTokens.metadata(context),
                      )
                    else
                      for (final service in data.facilityServices)
                        CheckboxListTile(
                          value: selected.contains(service.id),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                selected.add(service.id);
                              } else {
                                selected.remove(service.id);
                              }
                            });
                          },
                          title: Text(service.name),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _saving
                          ? null
                          : () => _saveServices(data.providerId!, selected),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save services'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: PracticeDesignTokens.previewCardDecoration(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Schedule reminder',
                        style: PracticeDesignTokens.sectionTitle(context)),
                    const SizedBox(height: 4),
                    Text(
                      'Get a nudge to review and update your availability for the week ahead.',
                      style: PracticeDesignTokens.metadata(context),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable weekly reminder'),
                      subtitle: Text(
                        reminderEnabled
                            ? 'You will be reminded to review your schedule.'
                            : 'Reminders are turned off.',
                        style: PracticeDesignTokens.metadata(context),
                      ),
                      value: reminderEnabled,
                      onChanged: facilityId == null
                          ? null
                          : (v) => _saveReminder(
                                facilityId,
                                enabled: v,
                                day: reminderDay,
                                hour: reminderHour,
                              ),
                    ),
                    DropdownButtonFormField<int>(
                      initialValue: reminderDay,
                      decoration: const InputDecoration(
                        labelText: 'Reminder day',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        7,
                        (i) => DropdownMenuItem(value: i, child: Text(_dayNames[i])),
                      ),
                      onChanged: facilityId == null || !reminderEnabled
                          ? null
                          : (v) {
                              if (v != null) {
                                _saveReminder(
                                  facilityId,
                                  enabled: reminderEnabled,
                                  day: v,
                                  hour: reminderHour,
                                );
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: reminderHour,
                      decoration: const InputDecoration(
                        labelText: 'Reminder time',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (var h = 8; h <= 20; h++)
                          DropdownMenuItem(
                            value: h,
                            child: Text('${h.toString().padLeft(2, '0')}:00'),
                          ),
                      ],
                      onChanged: facilityId == null || !reminderEnabled
                          ? null
                          : (v) {
                              if (v != null) {
                                _saveReminder(
                                  facilityId,
                                  enabled: reminderEnabled,
                                  day: reminderDay,
                                  hour: v,
                                );
                              }
                            },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Default: Sunday afternoon. Adjust particular days any time with Edit weekly hours.',
                      style: PracticeDesignTokens.metadata(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
