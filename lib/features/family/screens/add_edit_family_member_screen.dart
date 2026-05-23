import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/family/bloc/family_bloc.dart';
import 'package:smarthealth_shep/features/family/bloc/family_event.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/search/search_filter_options.dart';
import 'package:smarthealth_shep/features/search/widgets/search_filter_chip.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

/// Add or edit a family member (full-screen form).
class AddEditFamilyMemberScreen extends StatefulWidget {
  const AddEditFamilyMemberScreen({super.key, this.member});

  final FamilyMemberModel? member;

  bool get isEditing => member != null;

  @override
  State<AddEditFamilyMemberScreen> createState() =>
      _AddEditFamilyMemberScreenState();
}

class _AddEditFamilyMemberScreenState extends State<AddEditFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _allergiesController;

  FamilyRelationship _relationship = FamilyRelationship.child;
  FamilyGender _gender = FamilyGender.other;
  DateTime? _dateOfBirth;
  final Set<String> _conditions = {};

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

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    final dob = DateFormat('yyyy-MM-dd').format(_dateOfBirth!);
    final isPrimary = _relationship == FamilyRelationship.self ||
        (widget.member?.isPrimaryAccountHolder ?? false);

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
    );

    final bloc = context.read<FamilyBloc>();
    if (widget.isEditing) {
      bloc.add(UpdateMember(member));
    } else {
      bloc.add(AddMember(member));
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeDashboardColors.background,
      appBar: AppBar(
        backgroundColor: HomeDashboardColors.surface,
        foregroundColor: HomeDashboardColors.textPrimary,
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
              initialValue: _relationship,
              decoration: _fieldDecoration('Relationship'),
              items: FamilyRelationship.values
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
            const SizedBox(height: 16),
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
                        ? HomeDashboardColors.textPrimary
                        : HomeDashboardColors.textSecondary,
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
            const SizedBox(height: 16),
            Text(
              'Age group',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  _ageGroup?.label ?? 'Set date of birth',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                backgroundColor: HomeDashboardColors.secondary
                    .withValues(alpha: 0.12),
                side: BorderSide(
                  color: HomeDashboardColors.secondary.withValues(alpha: 0.4),
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SearchFilterOptions.conditions.map((option) {
                return SearchFilterChip(
                  label: option.label,
                  selected: _conditions.contains(option.id),
                  onTap: () {
                    setState(() {
                      if (_conditions.contains(option.id)) {
                        _conditions.remove(option.id);
                      } else {
                        _conditions.add(option.id);
                      }
                    });
                  },
                );
              }).toList(),
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
                          const Size.fromHeight(AppConstants.minTapTarget),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: HomeDashboardColors.secondary,
                      foregroundColor: Colors.white,
                      minimumSize:
                          const Size.fromHeight(AppConstants.minTapTarget),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save'),
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
      fillColor: HomeDashboardColors.surface,
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
  const _GenderTile({
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
          ? HomeDashboardColors.primary.withValues(alpha: 0.08)
          : HomeDashboardColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSelected,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? HomeDashboardColors.primary
                  : const Color(0xFFE5E8EE),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? HomeDashboardColors.primary
                    : HomeDashboardColors.textSecondary,
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
