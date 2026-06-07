import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/family/bloc/family_bloc.dart';
import 'package:smarthealth_shep/features/family/bloc/family_event.dart';
import 'package:smarthealth_shep/features/family/bloc/family_state.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/profile/utils/condition_labels.dart';
import 'package:smarthealth_shep/features/profile/utils/condition_submission_helper.dart';
import 'package:smarthealth_shep/features/profile/utils/profile_none_sentinel.dart';
import 'package:smarthealth_shep/features/profile/widgets/condition_selection_sheet.dart';
import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

/// Add or edit a family member (full-screen form).
class AddEditFamilyMemberScreen extends ConsumerStatefulWidget {
  const AddEditFamilyMemberScreen({super.key, this.member});

  final FamilyMemberModel? member;

  bool get isEditing => member != null;

  @override
  ConsumerState<AddEditFamilyMemberScreen> createState() =>
      _AddEditFamilyMemberScreenState();
}

class _AddEditFamilyMemberScreenState extends ConsumerState<AddEditFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _allergiesController;

  FamilyRelationship _relationship = FamilyRelationship.child;
  FamilyGender _gender = FamilyGender.other;
  DateTime? _dateOfBirth;
  final Set<String> _conditions = {};
  Map<String, String> _customConditionLabels = {};

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    _nameController = TextEditingController(text: member?.name ?? '');
    _allergiesController =
        TextEditingController(text: member?.allergies ?? '');

    if (member != null) {
      _relationship =
          member.relationshipEnum ?? FamilyRelationship.other;
      _gender = member.gender ?? FamilyGender.other;
      _conditions.addAll(member.medicalConditions);
      _customConditionLabels = Map<String, String>.from(
        member.metadata?.customConditionLabels ?? const {},
      );
      if (member.dateOfBirth != null) {
        _dateOfBirth = DateTime.tryParse(member.dateOfBirth!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  FamilyAgeGroup? get _ageGroup => ageGroupFromDateOfBirth(
        _dateOfBirth?.toIso8601String().split('T').first,
      );

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
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
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    final dob = DateFormat('yyyy-MM-dd').format(_dateOfBirth!);
    final isPrimary = widget.isEditing &&
        (widget.member?.isPrimaryAccountHolder ?? false);

    final existingMetadata = widget.member?.metadata;
    final metadata = _customConditionLabels.isNotEmpty
        ? (existingMetadata ?? const EmergencyMedicalMetadata()).copyWith(
            customConditionLabels: _customConditionLabels,
          )
        : existingMetadata;

    final member = FamilyMemberModel(
      id: widget.member?.id ?? '',
      name: _nameController.text.trim(),
      relationship: _relationship.label,
      dateOfBirth: dob,
      gender: _gender,
      medicalConditions: _conditions.toList(),
      allergies: _allergiesController.text.trim().isEmpty
          ? null
          : _allergiesController.text.trim(),
      isPrimaryAccountHolder: isPrimary,
      metadata: metadata,
    );

    final bloc = context.read<FamilyBloc>();
    if (widget.isEditing) {
      bloc.add(UpdateMember(member));
    } else {
      bloc.add(AddMember(member));
    }

    final result = await bloc.stream.firstWhere(
      (state) =>
          state.status == FamilyStatus.loaded ||
          state.status == FamilyStatus.error,
    );

    if (!mounted) return;
    if (result.status == FamilyStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Failed to save family member'),
        ),
      );
      return;
    }

    final savedMember = widget.isEditing
        ? result.members.firstWhere(
            (m) => m.id == widget.member!.id,
            orElse: () => member,
          )
        : result.members.firstWhere(
            (m) =>
                m.name == member.name &&
                m.dateOfBirth == member.dateOfBirth &&
                !m.isPrimaryAccountHolder,
            orElse: () => member,
          );

    if (_customConditionLabels.isNotEmpty &&
        !hasConditionsNone(_conditions)) {
      await submitCustomConditionProposals(
        api: ApiService(ref.read(dioProvider)),
        customLabels: _customConditionLabels,
        familyMemberId: savedMember.id.isNotEmpty ? savedMember.id : null,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeDashboardColors.of(context).background,
      appBar: AppBar(
        backgroundColor: HomeDashboardColors.of(context).surface,
        foregroundColor: HomeDashboardColors.of(context).textPrimary,
        title: Text(widget.isEditing ? 'Edit Family Member' : 'Add Family Member'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: _fieldDecoration('Full Name'),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FamilyRelationship>(
              value: _relationship,
              decoration: _fieldDecoration('Relationship'),
              items: (widget.isEditing
                      ? FamilyRelationship.values
                      : FamilyRelationship.values
                          .where((r) => r != FamilyRelationship.self))
                  .map(
                    (r) => DropdownMenuItem(
                      value: r,
                      child: Text(r.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _relationship = value);
              },
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: _pickDateOfBirth,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: _fieldDecoration('Date of Birth'),
                child: Text(
                  _dateOfBirth != null
                      ? DateFormat('d MMM yyyy').format(_dateOfBirth!)
                      : 'Select date',
                  style: TextStyle(
                    color: _dateOfBirth != null
                        ? HomeDashboardColors.of(context).textPrimary
                        : HomeDashboardColors.of(context).textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gender',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ...FamilyGender.values.map((gender) {
              return _GenderTile(
                gender: gender,
                selected: _gender == gender,
                onSelected: () => setState(() => _gender = gender),
              );
            }),
            SizedBox(height: 16),
            Text(
              'Age group',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  _ageGroup?.label ?? 'Set date of birth',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                backgroundColor: HomeDashboardColors.of(context).secondary
                    .withValues(alpha: 0.12),
                side: BorderSide(
                  color: HomeDashboardColors.of(context).secondary.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Medical conditions',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _pickConditions,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppConstants.minTapTarget),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _conditions.isEmpty
                      ? 'Select conditions'
                      : ConditionLabels.joinLabels(
                          _conditions,
                          customLabels: _customConditionLabels,
                        ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _allergiesController,
              decoration: _fieldDecoration('Allergies'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize:
                          Size.fromHeight(AppConstants.minTapTarget),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: HomeDashboardColors.of(context).secondary,
                      foregroundColor: Colors.white,
                      minimumSize:
                          const Size.fromHeight(AppConstants.minTapTarget),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: HomeDashboardColors.of(context).surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E8EE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E8EE)),
      ),
    );
  }
}

class _GenderTile extends StatelessWidget {
  _GenderTile({
    required this.gender,
    required this.selected,
    required this.onSelected,
  });

  final FamilyGender gender;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? HomeDashboardColors.of(context).primary.withValues(alpha: 0.08)
          : HomeDashboardColors.of(context).surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSelected,
        child: Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? HomeDashboardColors.of(context).primary
                  : Color(0xFFE5E8EE),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? HomeDashboardColors.of(context).primary
                    : HomeDashboardColors.of(context).textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                gender.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
