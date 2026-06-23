import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  List<FacilityServiceCatalogItem> _serviceCatalogItems = fallbackServiceCatalogItems
      .map((e) => FacilityServiceCatalogItem(id: e.id, label: e.label, iconKey: e.iconKey))
      .toList();
  List<MedicalAidCatalogItem> _medicalAidCatalogItems = fallbackMedicalAidCatalogItems
      .map((e) => MedicalAidCatalogItem(schemeKey: e.schemeKey, name: e.name))
      .toList();
  List<Map<String, dynamic>> _medicalAidPending = [];
  String? _catalogError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: facilityProfileTabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!MyPracticeConfig.useLocalDevSeed) {
        ref.read(authStateProvider.notifier).loadProfile();
      }
      _loadCatalogs();
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

  Future<void> _loadCatalogs() async {
    final repo = ref.read(facilityRepositoryProvider);

    // Load services catalog
    try {
      final raw = await repo.getServicesCatalog().timeout(
            const Duration(seconds: 15),
          );
      List<FacilityServiceCatalogItem> mapList(String key) {
        return ((raw[key] ?? []) as List)
            .whereType<Map>()
            .map((m) => FacilityServiceCatalogItem.fromJson(
                Map<String, dynamic>.from(m)))
            .where((s) => s.id.isNotEmpty && s.label.isNotEmpty)
            .toList();
      }

      final items = [...mapList('preset'), ...mapList('other')];
      debugPrint('[FacilityProfile] Services catalog: ${items.length} items');
      if (items.isNotEmpty && mounted) {
        setState(() => _serviceCatalogItems = items);
      }
    } catch (e) {
      debugPrint('[FacilityProfile] Services catalog error: $e');
    }

    // Load medical aid catalog
    try {
      final raw = await repo.getMedicalAidCatalog().timeout(
            const Duration(seconds: 15),
          );
      final items = raw
          .map(MedicalAidCatalogItem.fromJson)
          .where((s) => s.schemeKey.isNotEmpty)
          .toList();
      debugPrint('[FacilityProfile] Medical aid catalog: ${items.length} items');
      if (items.isNotEmpty && mounted) {
        setState(() => _medicalAidCatalogItems = items);
      }
    } catch (e) {
      debugPrint('[FacilityProfile] Medical aid catalog error: $e');
    }

    // Load pending submissions (best-effort; ignore errors)
    try {
      final pending = await repo
          .getMedicalAidSubmissions(status: 'pending')
          .timeout(const Duration(seconds: 10));
      if (mounted) setState(() => _medicalAidPending = pending);
    } catch (_) {}
  }

  bool _serviceSelected(FacilityProfileSettings effective, String itemId) {
    // itemId is the catalog slug (e.g. 'gp', 'pharmacy').
    // Server entries use key=slug for preset services; iconKey also equals slug
    // for preset entries, so we check that too for backwards compatibility.
    return effective.services.any(
      (s) =>
          s.key == itemId ||
          s.id == itemId ||
          s.iconKey == itemId ||
          s.name.toLowerCase() == itemId.toLowerCase().replaceAll('-', ' '),
    );
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
    final canManage = _canManage();
    final membershipRole = _membershipRole();

    // Bind facility data to form fields exactly once, safely between frames.
    // Using ref.listen avoids scheduling addPostFrameCallback inside build(),
    // which stacks up multiple callbacks during tab animations and causes
    // !_debugDoingThisLayout assertion failures.
    ref.listen(facilityProfileProvider, (_, next) {
      if (_loaded) return;
      next.whenData((raw) {
        final settings = raw['profileSettings'] as Map<String, dynamic>?;
        final servicesList = settings?['services'];
        final medicalAidsList = settings?['medicalAids'];
        debugPrint('[FacilityProfile] profileSettings services: $servicesList');
        debugPrint('[FacilityProfile] profileSettings medicalAids: $medicalAidsList');
        final facility = raw['facility'] as Map<String, dynamic>? ?? raw;
        if (mounted) setState(() => _bindFacility(facility));
      });
    });

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
          final psRaw = raw['profileSettings'] as Map<String, dynamic>?;
          debugPrint('[FacilityProfile] build: profileSettings keys=${psRaw?.keys.toList()}');
          debugPrint('[FacilityProfile] build: services count=${(psRaw?['services'] as List?)?.length}');
          debugPrint('[FacilityProfile] build: medicalAids count=${(psRaw?['medicalAids'] as List?)?.length}');
          final serverSettings = FacilityProfileSettings.fromJson(psRaw);
          debugPrint('[FacilityProfile] build: parsed services=${serverSettings.services.length}, medicalAids=${serverSettings.medicalAids.length}');
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
                    _generalTab(facility, canManage),
                    _logoTab(logoUrl, canManage),
                    _servicesTab(effective, canManage),
                    _medicalAidTab(effective, canManage),
                    _accessibilityTab(effective, canManage),
                    _bookingTab(effective, canManage),
                    _featuresTab(effective, canManage),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Returns a scrollable ListView for a tab — guaranteed bounded width for all
  // children, including Row+TextField combos that break inside SingleChildScrollView.
  ListView _tab(List<Widget> children) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }

  // Custom checkbox row – avoids CheckboxListTile whose internal ListTile
  // fires the "background may be invisible" assertion inside decorated cards.
  Widget _checkTile({
    required bool value,
    required String label,
    String? subtitle,
    required ValueChanged<bool?>? onChanged,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onChanged != null ? () => onChanged(!value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: PracticeDesignTokens.inter(size: 14)),
                    if (subtitle != null)
                      Text(subtitle,
                          style: PracticeDesignTokens.metadata(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _generalTab(Map<String, dynamic> facility, bool canManage) {
    return Form(
      key: _formKey,
      child: _tab([
        _field('Name', _nameCtrl, enabled: canManage, required: true),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            value: _facilityCategory?.isNotEmpty == true ? _facilityCategory : null,
            decoration: const InputDecoration(
              labelText: 'Facility Classification',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Select classification…')),
              for (final c in facilityClassificationOptions)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: canManage ? (v) => setState(() => _facilityCategory = v) : null,
          ),
        ),
        _field('Description', _descriptionCtrl, enabled: canManage, maxLines: 3),
        _field('Address', _addressCtrl, enabled: canManage),
        _field('City', _cityCtrl, enabled: canManage),
        _field('Phone', _phoneCtrl, enabled: canManage, keyboard: TextInputType.phone),
        _field('WhatsApp', _whatsappCtrl, enabled: canManage, keyboard: TextInputType.phone),
        _field('Email', _emailCtrl, enabled: canManage, keyboard: TextInputType.emailAddress),
        _field('Website', _websiteCtrl, enabled: canManage, keyboard: TextInputType.url),
        const SizedBox(height: 4),
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
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _logoTab(String? logoUrl, bool canManage) {
    return _tab([
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
      const SizedBox(height: 8),
    ]);
  }

  Widget _servicesTab(FacilityProfileSettings effective, bool canManage) {
    final items = _serviceCatalogItems;
    return _tab([
      if (_catalogError != null) ...[
        Text(
          'Using offline catalog ($_catalogError)',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        const SizedBox(height: 8),
      ],
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
          _checkTile(
            value: _serviceSelected(effective, item.id),
            label: item.label,
            onChanged: canManage ? (_) => _toggleCatalogService(effective, item) : null,
          ),
      if (canManage) ...[
        const SizedBox(height: 12),
        Text(
          'Propose a service not listed above. Admin review adds it to the global catalog.',
          style: PracticeDesignTokens.metadata(context),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _customServiceCtrl,
          decoration: const InputDecoration(
            labelText: 'Custom service name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonal(
            onPressed: _proposingService ? null : _proposeService,
            child: Text(_proposingService ? 'Submitting…' : 'Propose'),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving
              ? null
              : () => _saveSettings(effective, effective.toPatch(services: true)),
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
      const SizedBox(height: 8),
    ]);
  }

  Widget _medicalAidTab(FacilityProfileSettings effective, bool canManage) {
    final pending = _medicalAidPending;
    final pendingKeys = pending
        .map((s) => s['proposedSchemeKey'] as String? ?? '')
        .where((k) => k.isNotEmpty)
        .toSet();
    final merged = [..._medicalAidCatalogItems];
    final seen = _medicalAidCatalogItems.map((s) => s.schemeKey).toSet();
    for (final p in pending) {
      final key = p['proposedSchemeKey'] as String? ?? '';
      final name = p['proposedName'] as String? ?? '';
      if (key.isNotEmpty && !seen.contains(key)) {
        merged.add(MedicalAidCatalogItem(schemeKey: key, name: name));
        seen.add(key);
      }
    }

    return _tab([
      if (merged.isEmpty)
        Text('No medical aid schemes loaded.',
            style: PracticeDesignTokens.metadata(context))
      else
        for (final scheme in merged)
          _checkTile(
            value: effective.medicalAids.any((m) => m.schemeKey == scheme.schemeKey),
            label: scheme.name,
            subtitle: pendingKeys.contains(scheme.schemeKey) ? '(pending review)' : null,
            onChanged: canManage ? (_) => _toggleMedicalAid(effective, scheme) : null,
          ),
      if (canManage) ...[
        const SizedBox(height: 12),
        Text(
          'Propose a medical aid scheme not listed above.',
          style: PracticeDesignTokens.metadata(context),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _customMedicalAidCtrl,
          decoration: const InputDecoration(
            labelText: 'Medical aid scheme name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonal(
            onPressed: _proposingMedicalAid ? null : _proposeMedicalAid,
            child: Text(_proposingMedicalAid ? 'Submitting…' : 'Propose'),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving
              ? null
              : () => _saveSettings(effective, effective.toPatch(medicalAids: true)),
          child: const Text('Save medical aid'),
        ),
      ],
      const SizedBox(height: 8),
    ]);
  }

  Widget _accessibilityTab(FacilityProfileSettings effective, bool canManage) {
    return _tab([
      Text('Accessibility', style: PracticeDesignTokens.sectionTitle(context)),
      for (final (key, label) in accessibilityFlags)
        _checkTile(
          value: effective.accessibility[key] ?? false,
          label: label,
          onChanged: canManage ? (_) => _toggleFlag(effective, 'accessibility', key) : null,
        ),
      const SizedBox(height: 16),
      Text('Emergency services', style: PracticeDesignTokens.sectionTitle(context)),
      for (final (key, label) in emergencyFlags)
        _checkTile(
          value: effective.emergency[key] ?? false,
          label: label,
          onChanged: canManage ? (_) => _toggleFlag(effective, 'emergency', key) : null,
        ),
      if (_facilityCategory == 'Ambulance Service') ...[
        const SizedBox(height: 16),
        Text('Ambulance service types', style: PracticeDesignTokens.sectionTitle(context)),
        Text(
          'Select all ambulance and rescue services your facility provides.',
          style: PracticeDesignTokens.metadata(context),
        ),
        for (final opt in ambulanceServiceTypeOptions)
          _checkTile(
            value: effective.ambulanceServiceTypes.contains(opt.value),
            label: opt.value,
            subtitle: opt.description,
            onChanged: canManage
                ? (_) {
                    final current = List<String>.from(effective.ambulanceServiceTypes);
                    if (current.contains(opt.value)) {
                      current.remove(opt.value);
                    } else {
                      current.add(opt.value);
                    }
                    setState(() =>
                        _draftSettings = effective.copyWith(ambulanceServiceTypes: current));
                  }
                : null,
          ),
      ],
      if (canManage) ...[
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving
              ? null
              : () => _saveSettings(effective, effective.toPatch(accessibility: true)),
          child: const Text('Save accessibility & emergency'),
        ),
      ],
      const SizedBox(height: 12),
      Text(
        'For your personal weekly availability, use More → My Schedule.',
        style: PracticeDesignTokens.metadata(context),
      ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _bookingTab(FacilityProfileSettings effective, bool canManage) {
    final booking = Map<String, dynamic>.from(effective.booking);
    final enabled = booking['enabled'] != false;
    final showSlots = booking['showSlots'] != false;
    return _tab([
      _checkTile(
        value: enabled,
        label: 'Enable online booking',
        onChanged: canManage
            ? (v) => setState(() {
                  _draftSettings =
                      effective.copyWith(booking: {...booking, 'enabled': v ?? true});
                })
            : null,
      ),
      _checkTile(
        value: showSlots,
        label: 'Show appointment slots on profile',
        onChanged: canManage
            ? (v) => setState(() {
                  _draftSettings =
                      effective.copyWith(booking: {...booking, 'showSlots': v ?? true});
                })
            : null,
      ),
      if (canManage) ...[
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving
              ? null
              : () => _saveSettings(effective, effective.toPatch(booking: true)),
          child: const Text('Save booking settings'),
        ),
      ],
      const SizedBox(height: 8),
    ]);
  }

  Widget _featuresTab(FacilityProfileSettings effective, bool canManage) {
    return _tab([
      for (final (key, label) in smarthealthFeatureFlags)
        _checkTile(
          value: effective.smarthealthFeatures[key] ?? false,
          label: label,
          onChanged:
              canManage ? (_) => _toggleFlag(effective, 'smarthealthFeatures', key) : null,
        ),
      if (canManage) ...[
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving
              ? null
              : () => _saveSettings(effective, effective.toPatch(features: true)),
          child: const Text('Save SmartHealth features'),
        ),
      ],
      const SizedBox(height: 12),
      Text(
        'Assign providers to services on the Team / Doctors screens.',
        style: PracticeDesignTokens.metadata(context),
      ),
      const SizedBox(height: 8),
    ]);
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
