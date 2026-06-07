import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/auth/patient_profile.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/home/providers/home_medical_summary_provider.dart';
import 'package:smarthealth_shep/features/profile/profile_edit_focus.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/features/profile/utils/condition_labels.dart';
import 'package:smarthealth_shep/features/profile/utils/condition_submission_helper.dart';
import 'package:smarthealth_shep/features/profile/utils/primary_profile_resolver.dart';
import 'package:smarthealth_shep/features/profile/utils/profile_none_sentinel.dart';
import 'package:smarthealth_shep/features/profile/widgets/profile_member_switcher.dart';
import 'package:smarthealth_shep/features/profile/models/selected_primary_provider.dart';
import 'package:smarthealth_shep/features/profile/providers/medical_aid_catalog_provider.dart';
import 'package:smarthealth_shep/features/medications/services/medication_reminder_service.dart';
import 'package:smarthealth_shep/features/medications/services/prescription_scan_service.dart';
import 'package:smarthealth_shep/features/medications/widgets/prescription_review_sheet.dart';
import 'package:smarthealth_shep/features/profile/widgets/condition_selection_sheet.dart';
import 'package:smarthealth_shep/features/profile/widgets/emergency_contacts_editor.dart';
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
  late TextEditingController _aidMemberController;
  final _prescriptionScanService = PrescriptionScanService();
  List<EmergencyContactInfo> _emergencyContacts = [];
  String? _selectedMedicalAidSchemeKey;
  bool _allergiesMarkedNone = false;
  bool _medicationsMarkedNone = false;
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
  String? _loadedMemberKey;
  bool _isEditingPrimary = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _allergiesController = TextEditingController();
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
    _prescriptionScanService.dispose();
    _aidMemberController.dispose();
    _providerPhoneController.dispose();
    for (final row in _medications) {
      row.dispose();
    }
    super.dispose();
  }

  void _resetFormState() {
    for (final row in _medications) {
      row.dispose();
    }
    _medications.clear();
    _conditions.clear();
    _customConditionLabels.clear();
    _allergiesMarkedNone = false;
    _medicationsMarkedNone = false;
    _primaryProviderMarkedNone = false;
    _selectedPrimaryProvider = null;
    _selectedMedicalAidSchemeKey = null;
    _gender = null;
    _dateOfBirth = null;
    _bloodGroup = null;
    _existingMemberId = null;
    _isEditingPrimary = true;
    _nameController.clear();
    _allergiesController.clear();
    _emergencyContacts = [];
    _aidMemberController.clear();
    _providerPhoneController.clear();
    _initialized = false;
  }

  void _loadFromMember(FamilyMemberModel member) {
    _resetFormState();
    _initFromMember(member);
    _loadedMemberKey = profileMemberSwitcherKey(member);
    _isEditingPrimary = member.isPrimaryAccountHolder;
  }

  void _initFromMember(FamilyMemberModel member) {
    if (_initialized) return;
    _initialized = true;
    _existingMemberId = member.id.isEmpty || member.id == profilePrimaryLocalId
        ? null
        : member.id;
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
    _emergencyContacts = metadata.emergencyContacts.isNotEmpty
        ? List<EmergencyContactInfo>.from(metadata.emergencyContacts)
        : (metadata.emergencyContact.hasAny
            ? [metadata.emergencyContact]
            : []);
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

    if (isMedicationsNone(metadata.medications)) {
      _medicationsMarkedNone = true;
    } else {
      for (final med in metadata.medications) {
        _medications.add(_MedicationRow.fromEntry(med));
      }
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
    setState(() {
      _medicationsMarkedNone = false;
      _medications.add(_MedicationRow());
    });
  }

  void _removeMedicationRow(int index) {
    setState(() {
      _medications[index].dispose();
      _medications.removeAt(index);
    });
  }

  Future<void> _scanPrescription() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final fields = source == ImageSource.camera
        ? await _prescriptionScanService.scanFromCamera()
        : await _prescriptionScanService.scanFromGallery();

    if (!mounted) return;
    if (fields == null || !fields.hasAny) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read prescription label')),
      );
      return;
    }

    final result = await PrescriptionReviewSheet.show(context, fields: fields);
    if (result == null || !mounted) return;

    setState(() {
      _medicationsMarkedNone = false;
      _medications.add(_MedicationRow.fromEntry(result.entry));
    });

    if (result.reminderEnabled) {
      await MedicationReminderService.instance.ensurePermission();
    }
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

    final medicationEntries = _medicationsMarkedNone
        ? [const MedicationEntry(name: profileMedicationsNoneSentinel)]
        : _medications
            .map((row) => row.toEntry())
            .where((m) => m.name.isNotEmpty)
            .toList();
    final cleanedContacts = _emergencyContacts
        .where((c) => c.hasAny)
        .take(EmergencyMedicalMetadata.maxEmergencyContacts)
        .toList();
    final primaryContact = cleanedContacts.isNotEmpty
        ? cleanedContacts.first
        : const EmergencyContactInfo();

    final metadata = EmergencyMedicalMetadata(
      bloodGroup: _bloodGroup,
      medications: medicationEntries,
      emergencyContact: primaryContact,
      emergencyContacts: cleanedContacts,
      medicalAid: medicalAid,
      primaryProvider: primaryProvider,
      customConditionLabels: _customConditionLabels,
    );

    final patient = ref.read(patientProfileProvider).value;
    final members = ref.read(familyMembersProvider).value ?? [];
    final selectedMemberId = ref.read(selectedProfileMemberIdProvider);
    final active = resolveSelectedProfileMember(
      members: members,
      patient: patient,
      selectedMemberId: selectedMemberId,
    );
    final isPrimary = active.isPrimaryAccountHolder;

    final member = FamilyMemberModel(
      id: isPrimary
          ? (_existingMemberId ?? (active.id == profilePrimaryLocalId ? '' : active.id))
          : active.id,
      name: _nameController.text.trim(),
      relationship: isPrimary
          ? FamilyRelationship.self.label
          : (active.relationship ?? FamilyRelationship.other.label),
      dateOfBirth: _dateOfBirth ?? active.dateOfBirth,
      gender: _gender ?? active.gender,
      medicalConditions: _conditions.toList(),
      allergies: _allergiesMarkedNone
          ? profileAllergiesNoneSentinel
          : (_allergiesController.text.trim().isEmpty
              ? null
              : _allergiesController.text.trim()),
      isPrimaryAccountHolder: isPrimary,
      metadata: metadata,
    );

    try {
      final repository = ref.read(familyRepositoryProvider);
      final saved = await repository.saveMember(member);
      if (_customConditionLabels.isNotEmpty) {
        await submitCustomConditionProposals(
          api: ApiService(ref.read(dioProvider)),
          customLabels: _customConditionLabels,
          familyMemberId: saved.id.isNotEmpty ? saved.id : null,
        );
      }
      invalidateFamilyProfileProviders(ref);
      if (!_medicationsMarkedNone) {
        await MedicationReminderService.instance.syncMedications(
          subjectId: saved.id.isNotEmpty ? saved.id : profilePrimaryLocalId,
          medications: medicationEntries,
        );
      }
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

    ref.listen<String?>(selectedProfileMemberIdProvider, (previous, next) {
      if (previous == next) return;
      final currentMembers = ref.read(familyMembersProvider).value;
      if (currentMembers == null) return;
      final currentPatient = ref.read(patientProfileProvider).value;
      final nextMember = resolveSelectedProfileMember(
        members: currentMembers,
        patient: currentPatient,
        selectedMemberId: next,
      );
      if (!mounted) return;
      setState(() => _loadFromMember(nextMember));
    });

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

        final memberKey = profileMemberSwitcherKey(member);

        if (!_initialized || _loadedMemberKey != memberKey) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _loadFromMember(member));
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
                    IconButton(
                      tooltip: 'Scan prescription',
                      onPressed: _medicationsMarkedNone ? null : _scanPrescription,
                      icon: const Icon(Icons.document_scanner_outlined),
                    ),
                    TextButton(
                      onPressed: _addMedicationRow,
                      child: const Text('Add'),
                    ),
                  ],
                  ),
                ),
                if (_medications.isEmpty && !_medicationsMarkedNone)
                  Text(
                    'No medications added',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                FilterChip(
                  label: const Text('No medications'),
                  selected: _medicationsMarkedNone,
                  onSelected: (selected) {
                    setState(() {
                      _medicationsMarkedNone = selected;
                      if (selected) {
                        for (final row in _medications) {
                          row.dispose();
                        }
                        _medications.clear();
                      }
                    });
                  },
                ),
                const SizedBox(height: 8),
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
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Remind me'),
                    subtitle: const Text('Local notifications for 7 days'),
                    value: _medications[i].reminderEnabled,
                    onChanged: (value) {
                      setState(() => _medications[i].reminderEnabled = value);
                      if (value) {
                        MedicationReminderService.instance.ensurePermission();
                      }
                    },
                  ),
                  if (_medications[i].reminderEnabled)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Reminder time'),
                      subtitle: Text(
                        '${_medications[i].reminderTime.hour.toString().padLeft(2, '0')}:'
                        '${_medications[i].reminderTime.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.schedule),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _medications[i].reminderTime,
                        );
                        if (picked != null && mounted) {
                          setState(() => _medications[i].reminderTime = picked);
                        }
                      },
                    ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 12),
                _sectionTitle(context, 'Emergency contacts'),
                KeyedSubtree(
                  key: _sectionKeys[ProfileEditFocus.emergencyContact],
                  child: EmergencyContactsEditor(
                    contacts: _emergencyContacts,
                    onChanged: (contacts) =>
                        setState(() => _emergencyContacts = contacts),
                  ),
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
  _MedicationRow({
    String name = '',
    String? frequency,
    this.id,
    this.reminderEnabled = false,
    this.dosesPerDay,
    this.quantity,
    TimeOfDay? reminderTime,
  })  : nameController = TextEditingController(text: name),
        frequencyController = TextEditingController(text: frequency ?? ''),
        reminderTime = reminderTime ?? const TimeOfDay(hour: 8, minute: 0);

  factory _MedicationRow.fromEntry(MedicationEntry entry) {
    TimeOfDay? time;
    if (entry.reminderTimes.isNotEmpty) {
      final parts = entry.reminderTimes.first.split(':');
      if (parts.length == 2) {
        time = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    return _MedicationRow(
      name: entry.name,
      frequency: entry.frequency,
      id: entry.id,
      reminderEnabled: entry.reminderEnabled,
      dosesPerDay: entry.dosesPerDay,
      quantity: entry.quantity,
      reminderTime: time,
    );
  }

  final TextEditingController nameController;
  final TextEditingController frequencyController;
  String? id;
  bool reminderEnabled;
  int? dosesPerDay;
  String? quantity;
  TimeOfDay reminderTime;

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  MedicationEntry toEntry() {
    final name = nameController.text.trim();
    final frequency = frequencyController.text.trim();
    id ??= 'med_${DateTime.now().microsecondsSinceEpoch}';
    return MedicationEntry(
      id: id,
      name: name,
      frequency: frequency.isEmpty ? null : frequency,
      reminderEnabled: reminderEnabled,
      reminderTimes: reminderEnabled ? [_formatTime(reminderTime)] : const [],
      dosesPerDay: dosesPerDay,
      quantity: quantity,
    );
  }

  void dispose() {
    nameController.dispose();
    frequencyController.dispose();
  }
}
