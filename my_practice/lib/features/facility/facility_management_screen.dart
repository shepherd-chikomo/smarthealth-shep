import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/remote/claims_api_client.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/domain/constants/facility_profile_constants.dart';
import 'package:my_practice/domain/models/facility_profile_settings.dart';
import 'package:my_practice/domain/models/facility_service.dart';
import 'package:my_practice/features/facility/facility_profile_providers.dart';
import 'package:my_practice/shared/widgets/practice_more_app_bar.dart';
import 'package:smarthealth_core/smarthealth_core.dart';
import 'package:uuid/uuid.dart';

/// Facility profile editor — tabs match the facility portal (`FacilityProfileTabs`).
class FacilityManagementScreen extends ConsumerStatefulWidget {
  const FacilityManagementScreen({super.key});

  @override
  ConsumerState<FacilityManagementScreen> createState() =>
      _FacilityManagementScreenState();
}

class _FacilityManagementScreenState extends ConsumerState<FacilityManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _websiteCtrl;
  final _customServiceCtrl = TextEditingController();
  final _customMedicalAidCtrl = TextEditingController();

  bool _loaded = false;
  bool _saving = false;
  bool _proposingService = false;
  bool _proposingMedicalAid = false;
  bool _logoBusy = false;
  String? _error;
  String? _success;
  String? _proposalMessage;
  String? _facilityCategory;
  List<String> _facilityTypes = [];
  FacilityProfileSettings? _draftSettings;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: facilityProfileTabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!MyPracticeConfig.useLocalDevSeed) {
        ref.read(authStateProvider.notifier).loadProfile();
      }
      ref.read(facilityServicesCatalogProvider.future);
      ref.read(facilityMedicalAidCatalogProvider.future);
    });
    _nameCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _whatsappCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _websiteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _customServiceCtrl.dispose();
    _customMedicalAidCtrl.dispose();
    super.dispose();
  }

  void _bindFacility(Map<String, dynamic> facility) {
    _nameCtrl.text = facility['name'] as String? ?? '';
    _descriptionCtrl.text = facility['description'] as String? ?? '';
    _addressCtrl.text = facility['addressLine1'] as String? ?? '';
    _cityCtrl.text = facility['city'] as String? ?? '';
    _phoneCtrl.text = facility['phone'] as String? ?? '';
    _whatsappCtrl.text = facility['whatsappPhone'] as String? ?? '';
    _emailCtrl.text = facility['email'] as String? ?? '';
    _websiteCtrl.text = facility['website'] as String? ?? '';
    _facilityCategory = facility['facilityCategory'] as String?;
    final types = facility['facilityTypes'];
    if (types is List) {
      _facilityTypes = types.map((e) => e.toString()).toList();
    } else if (facility['facilityType'] != null) {
      _facilityTypes = [facility['facilityType'].toString()];
    }
    _loaded = true;
  }

  FacilityProfileSettings _effective(FacilityProfileSettings server) =>
      _draftSettings ?? server;

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

  Future<void> _saveGeneral() async {
    if (!_formKey.currentState!.validate()) return;
    if (_facilityTypes.isEmpty) {
      setState(() => _error = 'Select at least one facility category.');
      return;
    }
    await _runSave(() async {
      await ref.read(facilityRepositoryProvider).updateProfile({
        'name': _nameCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'addressLine1': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'whatsappPhone': _whatsappCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'website': _websiteCtrl.text.trim(),
        if (_facilityCategory != null && _facilityCategory!.isNotEmpty)
          'facilityCategory': _facilityCategory,
        'facilityTypes': _facilityTypes,
      });
      return 'Changes saved.';
    });
  }

  Future<void> _saveSettings(
    FacilityProfileSettings settings,
    Map<String, dynamic> patch,
  ) async {
    await _runSave(() async {
      await ref.read(facilityRepositoryProvider).updateProfileSettings(patch);
      setState(() => _draftSettings = settings);
      return 'Saved successfully.';
    });
  }

  Future<void> _runSave(Future<String> Function() action) async {
    setState(() {
      _saving = true;
      _error = null;
      _success = null;
    });
    try {
      final message = await action();
      ref.invalidate(facilityProfileProvider);
      if (mounted) setState(() => _success = message);
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _error = extractApiError(e) ?? 'Could not save');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggleCatalogService(
    FacilityProfileSettings effective,
    FacilityServiceCatalogItem item,
  ) {
    final exists = effective.services.any((s) => s.key == item.id);
    final next = exists
        ? effective.services.where((s) => s.key != item.id).toList()
        : [
            ...effective.services,
            FacilityServiceEntry(
              id: const Uuid().v4(),
              key: item.id,
              name: item.label,
              iconKey: item.iconKey,
            ),
          ];
    setState(() => _draftSettings = effective.copyWith(services: next));
  }

  void _toggleMedicalAid(
    FacilityProfileSettings effective,
    MedicalAidCatalogItem scheme,
  ) {
    final exists =
        effective.medicalAids.any((m) => m.schemeKey == scheme.schemeKey);
    final next = exists
        ? effective.medicalAids
            .where((m) => m.schemeKey != scheme.schemeKey)
            .toList()
        : [
            ...effective.medicalAids,
            MedicalAidEntry(schemeKey: scheme.schemeKey, name: scheme.name),
          ];
    setState(() => _draftSettings = effective.copyWith(medicalAids: next));
  }

  void _toggleFlag(
    FacilityProfileSettings effective,
    String group,
    String key,
  ) {
    if (group == 'accessibility') {
      final map = Map<String, bool>.from(effective.accessibility);
      map[key] = !(map[key] ?? false);
      setState(() => _draftSettings = effective.copyWith(accessibility: map));
    } else if (group == 'emergency') {
      final map = Map<String, bool>.from(effective.emergency);
      map[key] = !(map[key] ?? false);
      setState(() => _draftSettings = effective.copyWith(emergency: map));
    } else if (group == 'smarthealthFeatures') {
      final map = Map<String, bool>.from(effective.smarthealthFeatures);
      map[key] = !(map[key] ?? false);
      setState(() => _draftSettings = effective.copyWith(smarthealthFeatures: map));
    }
  }

  Future<void> _proposeService() async {
    final label = _customServiceCtrl.text.trim();
    if (label.isEmpty) return;
    setState(() {
      _proposingService = true;
      _proposalMessage = null;
      _error = null;
    });
    try {
      final result =
          await ref.read(facilityRepositoryProvider).submitServiceProposal(label);
      final skipped = result['skipped'] as bool? ?? false;
      setState(() {
        _proposalMessage = skipped
            ? 'That service is already in the catalog or pending review.'
            : 'Service submitted for admin review.';
        _customServiceCtrl.clear();
      });
      ref.invalidate(facilityServicesCatalogProvider);
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Could not propose service');
    } finally {
      if (mounted) setState(() => _proposingService = false);
    }
  }

  Future<void> _proposeMedicalAid() async {
    final name = _customMedicalAidCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _proposingMedicalAid = true;
      _proposalMessage = null;
      _error = null;
    });
    try {
      final result =
          await ref.read(facilityRepositoryProvider).submitMedicalAidProposal(name);
      final skipped = result['skipped'] as bool? ?? false;
      setState(() {
        _proposalMessage = skipped
            ? 'That scheme is already in the catalog or pending review.'
            : 'Medical aid submitted for admin review.';
        _customMedicalAidCtrl.clear();
      });
      ref.invalidate(facilityMedicalAidSubmissionsProvider);
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Could not propose medical aid');
    } finally {
      if (mounted) setState(() => _proposingMedicalAid = false);
    }
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return;
    setState(() => _logoBusy = true);
    try {
      await ref.read(facilityRepositoryProvider).uploadLogo(
            path,
            result!.files.single.name,
          );
      ref.invalidate(facilityProfileProvider);
      if (mounted) setState(() => _success = 'Logo uploaded successfully.');
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Could not upload logo');
    } finally {
      if (mounted) setState(() => _logoBusy = false);
    }
  }

  Future<void> _removeLogo() async {
    setState(() => _logoBusy = true);
    try {
      await ref.read(facilityRepositoryProvider).removeLogo();
      ref.invalidate(facilityProfileProvider);
      if (mounted) setState(() => _success = 'Logo removed.');
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Could not remove logo');
    } finally {
      if (mounted) setState(() => _logoBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileFuture = ref.watch(facilityProfileProvider);
    final servicesCatalog = ref.watch(facilityServicesCatalogProvider);
    final medicalAidCatalog = ref.watch(facilityMedicalAidCatalogProvider);
    final medicalAidPending = ref.watch(facilityMedicalAidSubmissionsProvider);
    final canManage = _canManage();
    final membershipRole = _membershipRole();

    return Scaffold(
      appBar: practiceMoreAppBar(
        context,
        'Facility profile',
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [for (final t in facilityProfileTabs) Tab(text: t)],
        ),
      ),
      body: profileFuture.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (raw) {
          final facility = raw['facility'] as Map<String, dynamic>? ?? raw;
          final serverSettings = FacilityProfileSettings.fromJson(
            raw['profileSettings'] as Map<String, dynamic>?,
          );
          if (!_loaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _bindFacility(facility));
            });
          }
          final effective = _effective(serverSettings);
          final logoUrl = facility['logoUrl'] as String?;

          return Column(
            children: [
              if (!canManage)
                _ReadOnlyBanner(
                  membershipRole: membershipRole,
                  onClaim: () => context.push('/claim'),
                ),
              if (_error != null)
                _BannerMessage(text: _error!, isError: true),
              if (_success != null)
                _BannerMessage(text: _success!, isError: false),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _scrollTab(_generalTab(facility, canManage)),
                    _scrollTab(_logoTab(logoUrl, canManage)),
                    _scrollTab(_servicesTab(effective, canManage, servicesCatalog)),
                    _scrollTab(
                      _medicalAidTab(
                        effective,
                        canManage,
                        medicalAidCatalog,
                        medicalAidPending,
                      ),
                    ),
                    _scrollTab(
                      _accessibilityTab(
                        effective,
                        canManage,
                      ),
                    ),
                    _scrollTab(_bookingTab(effective, canManage)),
                    _scrollTab(_featuresTab(effective, canManage)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _scrollTab(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
            child: child,
          ),
        );
      },
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: child,
    );
  }

  Widget _generalTab(Map<String, dynamic> facility, bool canManage) {
    return Form(
      key: _formKey,
      child: _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field('Name', _nameCtrl, enabled: canManage, required: true),
            DropdownButtonFormField<String>(
              value: _facilityCategory?.isNotEmpty == true
                  ? _facilityCategory
                  : null,
              decoration: const InputDecoration(
                labelText: 'Facility Classification',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Select classification…')),
                for (final c in facilityClassificationOptions)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: canManage
                  ? (v) => setState(() => _facilityCategory = v)
                  : null,
            ),
            const SizedBox(height: 12),
            _field('Description', _descriptionCtrl, enabled: canManage, maxLines: 3),
            _field('Address', _addressCtrl, enabled: canManage),
            _field('City', _cityCtrl, enabled: canManage),
            _field('Phone', _phoneCtrl, enabled: canManage, keyboard: TextInputType.phone),
            _field('WhatsApp', _whatsappCtrl, enabled: canManage, keyboard: TextInputType.phone),
            _field('Email', _emailCtrl, enabled: canManage, keyboard: TextInputType.emailAddress),
            _field('Website', _websiteCtrl, enabled: canManage, keyboard: TextInputType.url),
            const SizedBox(height: 12),
            Text('Facility categories', style: PracticeDesignTokens.sectionTitle(context)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: facilityCategoryOptions.map((opt) {
                final checked = _facilityTypes.contains(opt.id);
                return FilterChip(
                  label: Text(opt.label),
                  selected: checked,
                  onSelected: canManage
                      ? (v) {
                          setState(() {
                            if (v) {
                              _facilityTypes = [..._facilityTypes, opt.id];
                            } else {
                              _facilityTypes =
                                  _facilityTypes.where((t) => t != opt.id).toList();
                            }
                          });
                        }
                      : null,
                );
              }).toList(),
            ),
            if (canManage) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _saveGeneral,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save changes'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _logoTab(String? logoUrl, bool canManage) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Upload PNG, JPG, or WEBP (recommended 512×512). Shown on demand in the MyHealth app.',
            style: PracticeDesignTokens.metadata(context),
          ),
          const SizedBox(height: 16),
          if (logoUrl != null && logoUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                logoUrl,
                height: 96,
                width: 96,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined, size: 48),
              ),
            ),
          if (canManage) ...[
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: _logoBusy ? null : _pickLogo,
              child: Text(_logoBusy ? 'Uploading…' : 'Choose logo image'),
            ),
            if (logoUrl != null && logoUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _logoBusy ? null : _removeLogo,
                child: const Text('Remove logo'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _servicesTab(
    FacilityProfileSettings effective,
    bool canManage,
    AsyncValue<List<FacilityServiceCatalogItem>> catalogAsync,
  ) {
    return catalogAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Could not load catalog: $e',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
            Text(
              'Services patients can book. Assign providers to services on the Doctors page.',
              style: PracticeDesignTokens.metadata(context),
            ),
          ],
        ),
      ),
      data: (items) {
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Services patients can book. Assign providers to services on the Doctors page.',
                style: PracticeDesignTokens.metadata(context),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Text(
                  'No catalog services available.',
                  style: PracticeDesignTokens.metadata(context),
                )
              else
                for (final item in items)
                  CheckboxListTile(
                    value: effective.services.any((s) => s.key == item.id),
                    onChanged: canManage
                        ? (_) => _toggleCatalogService(effective, item)
                        : null,
                    title: Text(item.label),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
              if (canManage) ...[
                const SizedBox(height: 12),
                Text(
                  'Propose a service not listed above. Admin review adds it to the global catalog.',
                  style: PracticeDesignTokens.metadata(context),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customServiceCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Custom service name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: _proposingService ? null : _proposeService,
                      child: Text(_proposingService ? 'Submitting…' : 'Propose'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving
                      ? null
                      : () => _saveSettings(
                            effective,
                            effective.toPatch(services: true),
                          ),
                  child: const Text('Save services'),
                ),
              ],
              if (_proposalMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _proposalMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _medicalAidTab(
    FacilityProfileSettings effective,
    bool canManage,
    AsyncValue<List<MedicalAidCatalogItem>> catalogAsync,
    AsyncValue<List<Map<String, dynamic>>> pendingAsync,
  ) {
    return catalogAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _card(Text('Could not load medical aid catalog: $e')),
      data: (approved) {
        final pending = pendingAsync.when(
          data: (d) => d,
          loading: () => <Map<String, dynamic>>[],
          error: (_, _) => <Map<String, dynamic>>[],
        );
        final pendingKeys = pending
            .map((s) => s['proposedSchemeKey'] as String? ?? '')
            .where((k) => k.isNotEmpty)
            .toSet();
        final merged = [...approved];
        final seen = approved.map((s) => s.schemeKey).toSet();
        for (final p in pending) {
          final key = p['proposedSchemeKey'] as String? ?? '';
          final name = p['proposedName'] as String? ?? '';
          if (key.isNotEmpty && !seen.contains(key)) {
            merged.add(MedicalAidCatalogItem(schemeKey: key, name: name));
            seen.add(key);
          }
        }
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (merged.isEmpty)
                Text('No medical aid schemes loaded.',
                    style: PracticeDesignTokens.metadata(context))
              else
                for (final scheme in merged)
                  CheckboxListTile(
                    value: effective.medicalAids
                        .any((m) => m.schemeKey == scheme.schemeKey),
                    onChanged: canManage
                        ? (_) => _toggleMedicalAid(effective, scheme)
                        : null,
                    title: Text(scheme.name),
                    subtitle: pendingKeys.contains(scheme.schemeKey)
                        ? const Text('(pending review)',
                            style: TextStyle(color: Colors.amber))
                        : null,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
              if (canManage) ...[
                const SizedBox(height: 12),
                Text(
                  'Propose a medical aid scheme not listed above.',
                  style: PracticeDesignTokens.metadata(context),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customMedicalAidCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Medical aid scheme name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: _proposingMedicalAid ? null : _proposeMedicalAid,
                      child: Text(_proposingMedicalAid ? 'Submitting…' : 'Propose'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving
                      ? null
                      : () => _saveSettings(
                            effective,
                            effective.toPatch(medicalAids: true),
                          ),
                  child: const Text('Save medical aid'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _accessibilityTab(
    FacilityProfileSettings effective,
    bool canManage,
  ) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Accessibility', style: PracticeDesignTokens.sectionTitle(context)),
          for (final (key, label) in accessibilityFlags)
            CheckboxListTile(
              value: effective.accessibility[key] ?? false,
              onChanged: canManage ? (_) => _toggleFlag(effective, 'accessibility', key) : null,
              title: Text(label),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          const SizedBox(height: 16),
          Text('Emergency services', style: PracticeDesignTokens.sectionTitle(context)),
          for (final (key, label) in emergencyFlags)
            CheckboxListTile(
              value: effective.emergency[key] ?? false,
              onChanged: canManage ? (_) => _toggleFlag(effective, 'emergency', key) : null,
              title: Text(label),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          if (_facilityCategory == 'Ambulance Service') ...[
            const SizedBox(height: 16),
            Text('Ambulance service types',
                style: PracticeDesignTokens.sectionTitle(context)),
            Text(
              'Select all ambulance and rescue services your facility provides.',
              style: PracticeDesignTokens.metadata(context),
            ),
            for (final opt in ambulanceServiceTypeOptions)
              CheckboxListTile(
                value: effective.ambulanceServiceTypes.contains(opt.value),
                onChanged: canManage
                    ? (_) {
                        final current = List<String>.from(effective.ambulanceServiceTypes);
                        if (current.contains(opt.value)) {
                          current.remove(opt.value);
                        } else {
                          current.add(opt.value);
                        }
                        setState(() => _draftSettings =
                            effective.copyWith(ambulanceServiceTypes: current));
                      }
                    : null,
                title: Text(opt.value),
                subtitle: Text(opt.description,
                    style: PracticeDesignTokens.metadata(context)),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
          ],
          if (canManage)
            FilledButton(
              onPressed: _saving
                  ? null
                  : () => _saveSettings(
                        effective,
                        effective.toPatch(accessibility: true),
                      ),
              child: const Text('Save accessibility & emergency'),
            ),
          const SizedBox(height: 12),
          Text(
            'For your personal weekly availability, use More → My Schedule.',
            style: PracticeDesignTokens.metadata(context),
          ),
        ],
      ),
    );
  }

  Widget _bookingTab(FacilityProfileSettings effective, bool canManage) {
    final booking = Map<String, dynamic>.from(effective.booking);
    final enabled = booking['enabled'] != false;
    final showSlots = booking['showSlots'] != false;
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckboxListTile(
            value: enabled,
            onChanged: canManage
                ? (v) => setState(() {
                      _draftSettings = effective.copyWith(
                        booking: {...booking, 'enabled': v ?? true},
                      );
                    })
                : null,
            title: const Text('Enable online booking'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: showSlots,
            onChanged: canManage
                ? (v) => setState(() {
                      _draftSettings = effective.copyWith(
                        booking: {...booking, 'showSlots': v ?? true},
                      );
                    })
                : null,
            title: const Text('Show appointment slots on profile'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (canManage)
            FilledButton(
              onPressed: _saving
                  ? null
                  : () => _saveSettings(
                        effective,
                        effective.toPatch(booking: true),
                      ),
              child: const Text('Save booking settings'),
            ),
        ],
      ),
    );
  }

  Widget _featuresTab(FacilityProfileSettings effective, bool canManage) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (key, label) in smarthealthFeatureFlags)
            CheckboxListTile(
              value: effective.smarthealthFeatures[key] ?? false,
              onChanged: canManage
                  ? (_) => _toggleFlag(effective, 'smarthealthFeatures', key)
                  : null,
              title: Text(label),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          if (canManage)
            FilledButton(
              onPressed: _saving
                  ? null
                  : () => _saveSettings(
                        effective,
                        effective.toPatch(features: true),
                      ),
              child: const Text('Save SmartHealth features'),
            ),
          const SizedBox(height: 12),
          Text(
            'Assign providers to services on the Team / Doctors screens.',
            style: PracticeDesignTokens.metadata(context),
          ),
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

class _ReadOnlyBanner extends StatelessWidget {
  const _ReadOnlyBanner({required this.membershipRole, required this.onClaim});

  final String? membershipRole;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            membershipRole == 'receptionist' || membershipRole == 'doctor'
                ? 'Your role ($membershipRole) can view but not edit. Only facility administrators can update the profile.'
                : 'Sign in with a facility administrator account to edit details.',
            style: AppTextStyles.sm(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          if (membershipRole == 'receptionist' || membershipRole == 'doctor') ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onClaim, child: const Text('Claim facility ownership')),
          ],
        ],
      ),
    );
  }
}

class _BannerMessage extends StatelessWidget {
  const _BannerMessage({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        text,
        style: TextStyle(
          color: isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
