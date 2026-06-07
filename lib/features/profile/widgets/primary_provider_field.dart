import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/location/location_providers.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/profile/models/selected_primary_provider.dart';
import 'package:smarthealth_shep/features/profile/widgets/primary_provider_selection_sheet.dart';

/// Picks a facility or doctor from the database for the emergency profile.
class PrimaryProviderField extends ConsumerWidget {
  const PrimaryProviderField({
    super.key,
    required this.selection,
    required this.onChanged,
    required this.phoneController,
    this.phoneDecoration,
  });

  final SelectedPrimaryProvider? selection;
  final ValueChanged<SelectedPrimaryProvider?> onChanged;
  final TextEditingController phoneController;
  final InputDecoration? phoneDecoration;

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    final result = await PrimaryProviderSelectionSheet.show(
      context,
      apiService: ApiService(createApiDio()),
      searchOrigin: ref.read(searchOriginResolverProvider),
    );
    if (result == null) return;
    onChanged(result);
    if (result.phone != null && result.phone!.trim().isNotEmpty) {
      phoneController.text = result.phone!.trim();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = HomeDashboardColors.of(context);
    final label = selection?.summaryLabel ?? 'Select facility or doctor';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: () => _openPicker(context, ref),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppConstants.minTapTarget),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          child: Row(
            children: [
              Icon(Symbols.local_hospital, color: colors.primaryDark, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selection?.hasSelection == true
                        ? colors.textPrimary
                        : colors.textSecondary,
                    fontWeight: selection?.hasSelection == true
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              if (selection?.hasSelection == true)
                IconButton(
                  onPressed: () {
                    onChanged(null);
                    phoneController.clear();
                  },
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Clear',
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: phoneController,
          decoration: phoneDecoration ??
              InputDecoration(
                labelText: 'Phone',
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}
