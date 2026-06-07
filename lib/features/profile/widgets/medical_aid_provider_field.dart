import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/profile/providers/medical_aid_catalog_provider.dart';
import 'package:smarthealth_shep/features/profile/utils/profile_none_sentinel.dart';
import 'package:smarthealth_shep/shared/models/medical_aid_scheme.dart';

/// Dropdown for selecting a medical aid scheme from the platform catalog.
class MedicalAidProviderField extends ConsumerWidget {
  const MedicalAidProviderField({
    super.key,
    required this.selectedSchemeKey,
    required this.onChanged,
    this.decoration,
    this.noneSelected = false,
    this.onNoneSelected,
  });

  final String? selectedSchemeKey;
  final ValueChanged<MedicalAidScheme?> onChanged;
  final InputDecoration? decoration;
  final bool noneSelected;
  final VoidCallback? onNoneSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(medicalAidCatalogProvider);

    return catalogAsync.when(
      loading: () => InputDecorator(
        decoration: decoration ?? const InputDecoration(labelText: 'Medical aid'),
        child: const SizedBox(
          height: 20,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (error, stackTrace) =>
          _buildDropdown(context, defaultMedicalAidSchemes),
      data: (schemes) => _buildDropdown(context, schemes),
    );
  }

  Widget _buildDropdown(BuildContext context, List<MedicalAidScheme> schemes) {
    final colors = HomeDashboardColors.of(context);
    final keys = schemes.map((s) => s.schemeKey).toSet();
    final value = noneSelected
        ? profileMedicalAidNoneKey
        : (selectedSchemeKey != null && keys.contains(selectedSchemeKey)
            ? selectedSchemeKey
            : null);

    return DropdownButtonFormField<String>(
      value: value,
      decoration: decoration ??
          InputDecoration(
            labelText: 'Medical aid',
            filled: true,
            fillColor: colors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Select medical aid'),
        ),
        DropdownMenuItem<String>(
          value: profileMedicalAidNoneKey,
          child: Text(profileNoneDisplayLabel),
        ),
        ...schemes.map(
          (scheme) => DropdownMenuItem<String>(
            value: scheme.schemeKey,
            child: Text(scheme.name),
          ),
        ),
      ],
      onChanged: (key) {
        if (key == null) {
          onChanged(null);
          return;
        }
        if (key == profileMedicalAidNoneKey) {
          onNoneSelected?.call();
          return;
        }
        final scheme = schemes.firstWhere((s) => s.schemeKey == key);
        onChanged(scheme);
      },
    );
  }
}
