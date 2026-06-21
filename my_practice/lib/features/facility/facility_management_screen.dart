import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/remote/claims_api_client.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/domain/models/facility_hour.dart';
import 'package:my_practice/features/calendar/facility_hours_editor.dart';
import 'package:my_practice/features/facility/team_provider.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class FacilityManagementScreen extends ConsumerStatefulWidget {
  const FacilityManagementScreen({super.key});

  @override
  ConsumerState<FacilityManagementScreen> createState() =>
      _FacilityManagementScreenState();
}

class _FacilityManagementScreenState
    extends ConsumerState<FacilityManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _websiteCtrl;

  bool _loaded = false;
  bool _saving = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!MyPracticeConfig.useLocalDevSeed) {
        ref.read(authStateProvider.notifier).loadProfile();
      }
    });
    _nameCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _websiteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  void _bindFacility(Map<String, dynamic> facility) {
    _nameCtrl.text = facility['name'] as String? ?? '';
    _descriptionCtrl.text = facility['description'] as String? ?? '';
    _addressCtrl.text = facility['addressLine1'] as String? ?? '';
    _cityCtrl.text = facility['city'] as String? ?? '';
    _phoneCtrl.text = facility['phone'] as String? ?? '';
    _emailCtrl.text = facility['email'] as String? ?? '';
    _websiteCtrl.text = facility['website'] as String? ?? '';
    _loaded = true;
  }

  bool _canManage() {
    if (MyPracticeConfig.useLocalDevSeed) return true;
    final auth = ref.read(authStateProvider);
    final facilityId = ref.read(facilityIdProvider);
    final profile = auth.profile;
    if (profile == null || facilityId == null) return false;
    if (profile.role == 'super_admin') return true;
    for (final f in profile.facilities) {
      if (f.id == facilityId) return f.role == 'facility_admin';
    }
    return false;
  }

  String? _membershipRole() {
    final facilityId = ref.read(facilityIdProvider);
    final profile = ref.read(authStateProvider).profile;
    if (facilityId == null || profile == null) return null;
    for (final f in profile.facilities) {
      if (f.id == facilityId) return f.role;
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
      _success = null;
    });
    try {
      await ref.read(facilityRepositoryProvider).updateProfile({
        'name': _nameCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'addressLine1': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'website': _websiteCtrl.text.trim(),
      });
      ref.invalidate(_facilityProfileProvider);
      if (mounted) setState(() => _success = 'Facility profile saved.');
    } on DioException catch (e) {
      if (mounted) {
        setState(
          () => _error = extractApiError(e) ?? 'Could not save facility profile',
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editHours(List<FacilityHour> hours) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FacilityHoursEditorSheet(initialHours: hours),
    );
    ref.invalidate(facilityHoursProvider);
  }

  @override
  Widget build(BuildContext context) {
    final profileFuture = ref.watch(_facilityProfileProvider);
    final hoursAsync = ref.watch(facilityHoursProvider);
    final canManage = _canManage();
    final membershipRole = _membershipRole();

    return Scaffold(
      appBar: AppBar(title: const Text('Facility Management')),
      body: profileFuture.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (raw) {
          final facility =
              raw['facility'] as Map<String, dynamic>? ?? raw;
          final settings =
              raw['profileSettings'] as Map<String, dynamic>? ?? {};
          if (!_loaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _bindFacility(facility));
            });
          }

          final services = (settings['services'] as List<dynamic>? ?? [])
              .map((s) => (s as Map)['name'] as String? ?? '')
              .where((s) => s.isNotEmpty)
              .toList();

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!canManage)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          membershipRole == 'receptionist' ||
                                  membershipRole == 'doctor'
                              ? 'Your role ($membershipRole) can view but not edit facility details. '
                                  'Only facility administrators can update the profile and hours.'
                              : 'Sign in with a facility administrator account to edit details.',
                          style: AppTextStyles.sm(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                        if (membershipRole == 'receptionist' ||
                            membershipRole == 'doctor') ...[
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => context.push('/claim'),
                            child: const Text('Claim facility ownership'),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (_error != null) ...[
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 8),
                ],
                if (_success != null) ...[
                  Text(_success!, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 8),
                ],
                _section(
                  context,
                  title: 'Facility profile',
                  icon: Icons.business_outlined,
                  child: Column(
                    children: [
                      _field('Name', _nameCtrl, enabled: canManage, required: true),
                      _field('Description', _descriptionCtrl, enabled: canManage, maxLines: 3),
                      _field('Address', _addressCtrl, enabled: canManage),
                      _field('City', _cityCtrl, enabled: canManage),
                      _field('Phone', _phoneCtrl, enabled: canManage, keyboard: TextInputType.phone),
                      _field('Email', _emailCtrl, enabled: canManage, keyboard: TextInputType.emailAddress),
                      _field('Website', _websiteCtrl, enabled: canManage, keyboard: TextInputType.url),
                      if (canManage) ...[
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _saving ? null : _saveProfile,
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Save profile'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _section(
                  context,
                  title: 'Operating hours',
                  icon: Icons.schedule_outlined,
                  trailing: canManage
                      ? TextButton(
                          onPressed: hoursAsync.hasValue
                              ? () => _editHours(hoursAsync.requireValue)
                              : null,
                          child: const Text('Edit'),
                        )
                      : null,
                  child: hoursAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('$e'),
                    data: (hours) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: hours
                          .map(
                            (h) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                h.displayLine,
                                style: PracticeDesignTokens.clinicalNote(context),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _section(
                  context,
                  title: 'Services offered',
                  icon: Icons.medical_services_outlined,
                  child: services.isEmpty
                      ? Text(
                          'No services configured yet.',
                          style: PracticeDesignTokens.metadata(context),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: services
                              .map(
                                (s) => PracticeStatusChip(
                                  label: s,
                                  tone: PracticeStatusTone.info,
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: PracticeDesignTokens.sectionTitle(context)),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    required bool enabled,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }
}

final _facilityProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(facilityRepositoryProvider).getProfile();
});
