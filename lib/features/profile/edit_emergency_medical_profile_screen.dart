import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/auth/patient_profile.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/home/providers/home_medical_summary_provider.dart';
import 'package:smarthealth_shep/features/profile/profile_edit_focus.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/features/profile/utils/condition_labels.dart';
import 'package:smarthealth_shep/features/profile/utils/condition_submission_helper.dart';
import 'package:smarthealth_shep/features/profile/utils/primary_profile_resolver.dart';
import 'package:smarthealth_shep/features/profile/utils/profile_none_sentinel.dart';
import 'package:smarthealth_shep/features/profile/widgets/profile_member_switcher.dart';
import 'package:smarthealth_shep/features/profile/models/selected_primary_provider.dart';
import 'package:smarthealth_shep/features/profile/providers/medical_aid_catalog_provider.dart';
import 'package:smarthealth_shep/features/profile/widgets/condition_selection_sheet.dart';
import 'package:smarthealth_shep/features/profile/widgets/medical_aid_provider_field.dart';
import 'package:smarthealth_shep/features/profile/widgets/primary_provider_field.dart';
import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';
import 'package:smarthealth_shep/shared/models/medical_aid_scheme.dart';

const _bloodGroups = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];

class EditEmergencyMedicalProfileScreen extends ConsumerStatefulWidget {
  const EditEmergencyMedicalProfileScreen({super.key, this.focusSection});

  /// Checklist item id from [ProfileEditFocus] — scrolls to that section on open.
  final String? focusSection;

  @override
  ConsumerState<EditEmergencyMedicalProfileScreen> createState() =>
      _EditEmergencyMedicalProfileScreenState();
}

class _EditEmergencyMedicalProfileScreenState
    extends ConsumerState<EditEmergencyMedicalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _sectionKeys = <String, GlobalKey>{
    ProfileEditFocus.name: GlobalKey(),
    ProfileEditFocus.gender: GlobalKey(),
    ProfileEditFocus.dob: GlobalKey(),
    ProfileEditFocus.bloodGroup: GlobalKey(),
    ProfileEditFocus.allergies: GlobalKey(),
    ProfileEditFocus.conditions: GlobalKey(),
    ProfileEditFocus.medications: GlobalKey(),
    ProfileEditFocus.emergencyContact: GlobalKey(),
    ProfileEditFocus.medicalAid: GlobalKey(),
    ProfileEditFocus.primaryProvider: GlobalKey(),
  };
  bool _initialized = false;
  bool _saving = false;
  bool _didScrollToFocus = false;

  late TextEditingController _nameController;
  late TextEditingController _allergiesController;
  late TextEditingController _ecNameController;
  late TextEditingController _ecRelationshipController;
  late TextEditingController _ecPhoneController;
  late TextEditingController _aidMemberController;
  String? _selectedMedicalAidSchemeKey;
  bool _allergiesMarkedNone = false;
  bool _primaryProviderMarkedNone = false;
  late TextEditingController _providerPhoneController;
  SelectedPrimaryProvider? _selectedPrimaryProvider;

  FamilyGender? _gender;
  String? _dateOfBirth;
  String? _bloodGroup;
  final Set<String> _conditions = {};
  Map<String, String> _customConditionLabels = {};
  final List<_MedicationRow> _medications = [];
  String? _existingMemberId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _allergiesController = TextEditingController();
    _ecNameController = TextEditingController();
    _ecRelationshipController = TextEditingController();
    _ecPhoneController = TextEditingController();
    _aidMemberController = TextEditingController();
    _providerPhoneController = TextEditingController();
  }

  void _scrollToFocusSection() {
    final section = widget.focusSection;
    if (section == null || _didScrollToFocus) return;
    final key = _sectionKeys[section];
    final context = key?.currentContext;
    if (context == null) return;
    _didScrollToFocus = true;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.08,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _allergiesController.dispose();
    _ecNameController.dispose();
    _ecRelationshipController.dispose();
    _ecPhoneController.dispose();
    _aidMemberController.dispose();
    _providerPhoneController.dispose();
    for (final row in _medications) {
      row.dispose();
    }
    super.dispose();
  }

  void _initFromMember(FamilyMemberModel member) {
    if (_initialized) return;
    _initialized = true;
    _existingMemberId = member.id.isEmpty ? null : member.id;
    _nameController.text = member.name;
    _allergiesMarkedNone = isAllergiesNone(member.allergies);
    _allergiesController.text = _allergiesMarkedNone
        ? ''
        : (member.allergies ?? '');
    _gender = member.gender;
    _dateOfBirth = member.dateOfBirth;
    _conditions.addAll(member.medicalConditions);

    final metadata = member.metadata ?? const EmergencyMedicalMetadata();
    _customConditionLabels =
        Map<String, String>.from(metadata.customConditionLabels);
    _bloodGroup = metadata.bloodGroup;
    _ecNameController.text = metadata.emergencyContact.name ?? '';
    _ecRelationshipController.text =
        metadata.emergencyContact.relationship ?? '';
    _ecPhoneController.text = metadata.emergencyContact.phone ?? '';
    _selectedMedicalAidSchemeKey = _resolveMedicalAidSchemeKey(metadata.medicalAid);
    if (isMedicalAidNone(metadata.medicalAid.schemeKey)) {
      _selectedMedicalAidSchemeKey = profileMedicalAidNoneKey;
    }
    _aidMemberController.text = metadata.medicalAid.memberNumber ?? '';
    _primaryProviderMarkedNone =
        isPrimaryProviderNone(metadata.primaryProvider);
    _selectedPrimaryProvider = _primaryProviderMarkedNone
        ? SelectedPrimaryProvider.none()
        : SelectedPrimaryProvider.fromInfo(metadata.primaryProvider);
    _providerPhoneController.text = metadata.primaryProvider.phone ?? '';

    for (final med in metadata.medications) {
      _medications.add(_MedicationRow(name: med.name, frequency: med.frequency));
    }
  }

  String? _resolveMedicalAidSchemeKey(MedicalAidInfo medicalAid) {
    final key = medicalAid.schemeKey?.trim();
    if (key != null && key.isNotEmpty) return key;

    final provider = medicalAid.provider?.trim();
    if (provider == null || provider.isEmpty) return null;

    for (final scheme in defaultMedicalAidSchemes) {
      if (scheme.name.toLowerCase() == provider.toLowerCase()) {
        return scheme.schemeKey;
      }
    }
    return null;
  }

  MedicalAidScheme? _selectedMedicalAidScheme(List<MedicalAidScheme> schemes) {
    final key = _selectedMedicalAidSchemeKey;
    if (key == null) return null;
    for (final scheme in schemes) {
      if (scheme.schemeKey == key) return scheme;
    }
    return null;
  }

  void _addMedicationRow() {
    setState(() => _medications.add(_MedicationRow()));
  }

  void _removeMedicationRow(int index) {
    setState(() {
      _medications[index].dispose();
      _medications.removeAt(index);
    });
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _pickDateOfBirth() async {
    final initial = _dateOfBirth != null
        ? DateTime.tryParse(_dateOfBirth!)
        : null;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      final month = picked.month.toString().padLeft(2, '0');
      final day = picked.day.toString().padLeft(2, '0');
      _dateOfBirth = '${picked.year}-$month-$day';
    });
  }

  Future<void> _pickConditions() async {
    final result = await ConditionSelectionSheet.show(
      context,
      selectedIds: _conditions,
      customLabels: _customConditionLabels,
    );
    if (result == null) return;
    setState(() {
      _conditions
        ..clear()
        ..addAll(result.selectedIds);
      _customConditionLabels = Map<String, String>.from(result.customLabels);
      _customConditionLabels.removeWhere(
        (slug, _) => !_conditions.contains(slug),
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;

    setState(() => _saving = true);

    final schemes =
        ref.read(medicalAidCatalogProvider).value ?? defaultMedicalAidSchemes;
    final selectedScheme = _selectedMedicalAidSchemeKey == profileMedicalAidNoneKey
        ? null
        : _selectedMedicalAidScheme(schemes);
    final medicalAid = _selectedMedicalAidSchemeKey == profileMedicalAidNoneKey
        ? const MedicalAidInfo(
            schemeKey: profileMedicalAidNoneKey,
            provider: profileNoneDisplayLabel,
          )
        : MedicalAidInfo(
            schemeKey: selectedScheme?.schemeKey,
            provider: selectedScheme?.name,
            memberNumber: _aidMemberController.text.trim().isEmpty
                ? null
                : _aidMemberController.text.trim(),
          );
    final primaryProvider = _primaryProviderMarkedNone
        ? const PrimaryProviderInfo(
            facilityName: profilePrimaryProviderNoneSentinel,
          )
        : (_selectedPrimaryProvider ?? const SelectedPrimaryProvider())
            .toInfo(phoneOverride: _providerPhoneController.text);

    final metadata = EmergencyMedicalMetadata(
      bloodGroup: _bloodGroup,
      medications: _medications
          .map(
            (row) => MedicationEntry(
              name: row.nameController.text.trim(),
              frequency: row.frequencyController.text.trim().isEmpty
                  ? null
                  : row.frequencyController.text.trim(),
            ),
          )
          .where((m) => m.name.isNotEmpty)
          .toList(),
      emergencyContact: EmergencyContactInfo(
        name: _optionalText(_ecNameController.text),
        relationship: _optionalText(_ecRelationshipController.text),
        phone: _optionalText(_ecPhoneController.text),
      ),
      medicalAid: medicalAid,
      primaryProvider: primaryProvider,
      customConditionLabels: _customConditionLabels,
    );

    final patient = ref.read(patientProfileProvider).value;
    final base = buildPrimaryMemberFromProfile(patient);

    final member = FamilyMemberModel(
      id: _existingMemberId ?? '',
      name: _nameController.text.trim(),
      relationship: FamilyRelationship.self.label,
      dateOfBirth: _dateOfBirth ?? base.dateOfBirth,
      gender: _gender ?? base.gender,
      medicalConditions: _conditions.toList(),
      allergies: _allergiesMarkedNone
          ? profileAllergiesNoneSentinel
          : (_allergiesController.text.trim().isEmpty
              ? null
              : _allergiesController.text.trim()),
      isPrimaryAccountHolder: true,
      metadata: metadata,
    );

    try {
      final repository = ref.read(familyRepositoryProvider);
      final saved = await repository.saveMember(member);
      if (_customConditionLabels.isNotEmpty) {
        await submitCustomConditionProposals(
          api: ApiService(createApiDio()),
          customLabels: _customConditionLabels,
          familyMemberId: saved.id.isNotEmpty ? saved.id : null,
        );
      }
      invalidateFamilyProfileProviders(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency profile saved')),
      );
      context.pop();
    } on DioException catch (error) {
      if (mounted) {
        final message = error.response?.statusCode == 401
            ? 'Session expired — please sign in again'
            : 'Failed to save profile (${error.response?.statusCode ?? 'network'})';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);
    final patient = ref.watch(patientProfileProvider).value;
    final membersAsync = ref.watch(familyMembersProvider);

    final selectedMemberId = ref.watch(selectedProfileMemberIdProvider);

    return membersAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text(error.toString())),
      ),
      data: (members) {
        final member = resolveSelectedProfileMember(
          members: members,
          patient: patient,
          selectedMemberId: selectedMemberId,
        );

        if (!_initialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _initialized) return;
            _initFromMember(member);
            setState(() {});
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _scrollToFocusSection();
            });
          });
        }

        if (!_initialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            title: const Text('Edit Emergency Profile'),
            actions: [
              TextButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                const ProfileMemberSwitcher(),
                const SizedBox(height: 12),
                _sectionTitle(context, 'Identity'),
                KeyedSubtree(
                  key: _sectionKeys[ProfileEditFocus.name],
                  child: TextFormField(
                  controller: _nameController,
                  decoration: _decoration(context, 'Full name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 12),
                KeyedSubtree(
                  key: _sectionKeys[ProfileEditFocus.gender],
                  child: DropdownButtonFormField<FamilyGender>(
                  value: _gender,
                  decoration: _decoration(context, 'Gender'),
                  items: FamilyGender.values
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(g.label),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _gender = v),
                  ),
                ),
                const SizedBox(height: 12),
                KeyedSubtree(
                  key: _sectionKeys[ProfileEditFocus.dob],
                  child: InkWell(
                  onTap: _pickDateOfBirth,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _decoration(context, 'Date of birth'),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dateOfBirth ?? 'Select date of birth',
                            style: TextStyle(
                              color: _dateOfBirth == null
                                  ? colors.textSecondary
                                  : colors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                  ),
                ),
                const SizedBox(height: 12),
                KeyedSubtree(
                  key: _sectionKeys[ProfileEditFocus.bloodGroup],
                  child: DropdownButtonFormField<String>(
                  value: _bloodGroup,
                  decoration: _decoration(context, 'Blood group'),
                  items: _bloodGroups
                      .map(
                        (g) => DropdownMenuItem(value: g, child: Text(g)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _bloodGroup = v),
                  ),
                ),
                const SizedBox(height: 20),
                _sectionTitle(context, 'Allergies'),
                KeyedSubtree(
                  key: _sectionKeys[ProfileEditFocus.allergies],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _allergiesController,
                        decoration: _decoration(context, 'Severe allergy'),
                        maxLines: 2,
                        enabled: !_allergiesMarkedNone,
                      ),
                      const SizedBox(height: 8),
                      FilterChip(
                        label: const Text('No known allergies'),
                        selected: _allergiesMarkedNone,
                        onSelected: (selected) {
                          setState(() {
                            _allergiesMarkedNone = selected;
                            if (selected) _allergiesController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionTitle(context, 'Conditions'),
                KeyedSubtree(
                  key: _sectionKeys[ProfileEditFocus.conditions],
                  child: OutlinedButton(
                  onPressed: _pickConditions,
                  style: OutlinedButton.styleFrom(
                    minimumSize:
                        const Size.fromHeight(AppConstants.minTapTarget),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _conditions.isEmpty
                          ? 'Select conditions'
                          : hasConditionsNone(_conditions)
                              ? profileNoneDisplayLabel
                              : ConditionLabels.joinLabels(
                                  _conditions,
                                  customLabels: _customConditionLabels,
                                ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ),
                ),
                const SizedBox(height: 20),
                KeyedSubtree(
                  key: _sectionKeys[ProfileEditFocus.medications],
                  child: Row(
                  children: [
                    Expanded(child: _sectionTitle(context, 'Medications')),
                    TextButton(
                      onPressed: _addMedicationRow,
                      child: const Text('Add'),
                    ),
                  ],
                  ),
                ),
                if (_medications.isEmpty)
                  Text(
                    'No medications added',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                for (var i = 0; i < _medications.length; i++) ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _medications[i].nameController,
                          decoration: _decoration(context, 'Medication name'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _medications[i].frequencyController,
                          decoration: _decoration(context, 'Freq'),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeMedicationRow(i),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 12),
                _sectionTitle(context, 'Emergency contact'),
                KeyedSubtree(
                  key: _sectionKeys[ProfileEditFocus.emergencyContact],
                  child: TextFormField(
                  controller: _ecNameController,
                  decoration: _decoration(context, 'Name'),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ecRelationshipController,
                  decoration: _decoration(context, 'Relationship'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ecPhoneController,
                  decoration: _decoration(context, 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _sectionTitle(context, 'Medical aid'),
                KeyedSubtree(
                  key: _sectionKeys[ProfileEditFocus.medicalAid],
                  child: MedicalAidProviderField(
                  selectedSchemeKey: _selectedMedicalAidSchemeKey,
                  decoration: _decoration(context, 'Medical aid provider'),
                  onChanged: (scheme) {
                    setState(() {
                      if (scheme == null &&
                          _selectedMedicalAidSchemeKey != profileMedicalAidNoneKey) {
                        _selectedMedicalAidSchemeKey = null;
                        return;
                      }
                      _selectedMedicalAidSchemeKey = scheme?.schemeKey;
                    });
                  },
                  onNoneSelected: () {
                    setState(() {
                      _selectedMedicalAidSchemeKey = profileMedicalAidNoneKey;
                      _aidMemberController.clear();
                    });
                  },
                  noneSelected:
                      _selectedMedicalAidSchemeKey == profileMedicalAidNoneKey,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _aidMemberController,
                  decoration: _decoration(context, 'Member number'),
                ),
                const SizedBox(height: 20),
                _sectionTitle(context, 'Primary provider'),
                KeyedSubtree(
                  key: _sectionKeys[ProfileEditFocus.primaryProvider],
                  child: PrimaryProviderField(
                  selection: _selectedPrimaryProvider,
                  noneSelected: _primaryProviderMarkedNone,
                  phoneController: _providerPhoneController,
                  phoneDecoration: _decoration(context, 'Phone'),
                  onChanged: (value) {
                    setState(() {
                      _primaryProviderMarkedNone = false;
                      _selectedPrimaryProvider = value;
                    });
                  },
                  onNoneSelected: () {
                    setState(() {
                      _primaryProviderMarkedNone = true;
                      _selectedPrimaryProvider = SelectedPrimaryProvider.none();
                      _providerPhoneController.clear();
                    });
                  },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  InputDecoration _decoration(BuildContext context, String label) {
    final colors = HomeDashboardColors.of(context);
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: colors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _MedicationRow {
  _MedicationRow({String name = '', String? frequency})
      : nameController = TextEditingController(text: name),
        frequencyController = TextEditingController(text: frequency ?? '');

  final TextEditingController nameController;
  final TextEditingController frequencyController;

  void dispose() {
    nameController.dispose();
    frequencyController.dispose();
  }
}
