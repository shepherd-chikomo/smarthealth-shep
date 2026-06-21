import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/domain/models/facility_hour.dart';
import 'package:my_practice/features/facility/team_provider.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';

class FacilityHoursEditorSheet extends ConsumerStatefulWidget {
  const FacilityHoursEditorSheet({
    super.key,
    required this.initialHours,
    this.title = 'Edit working hours',
    this.onSave,
  });

  final List<FacilityHour> initialHours;
  final String title;
  final Future<void> Function(List<FacilityHour> hours)? onSave;

  @override
  ConsumerState<FacilityHoursEditorSheet> createState() =>
      _FacilityHoursEditorSheetState();
}

class _FacilityHoursEditorSheetState
    extends ConsumerState<FacilityHoursEditorSheet> {
  late List<FacilityHour> _hours;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _hours = List.of(widget.initialHours);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (widget.onSave != null) {
        await widget.onSave!(_hours);
      } else {
        await ref.read(facilityRepositoryProvider).updateFacilityHours(_hours);
        ref.invalidate(facilityHoursProvider);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              MyPracticeConfig.skipAuthForTesting
                  ? 'Hours saved locally (pilot login needed for server sync).'
                  : 'Could not save: $e',
            ),
          ),
        );
        if (MyPracticeConfig.useLocalDevSeed) {
          Navigator.pop(context, true);
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(widget.title,
                  style: PracticeDesignTokens.sectionTitle(context)),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _hours.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final h = _hours[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.label,
                          style: PracticeDesignTokens.inter(
                            weight: FontWeight.w600,
                          )),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeField(
                              label: 'Opens',
                              value: h.opensAt ?? '08:00',
                              enabled: !h.isClosed && !h.is24Hours,
                              onChanged: (v) {
                                setState(() {
                                  _hours[i] = h.copyWith(opensAt: v);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _TimeField(
                              label: 'Closes',
                              value: h.closesAt ?? '17:00',
                              enabled: !h.isClosed && !h.is24Hours,
                              onChanged: (v) {
                                setState(() {
                                  _hours[i] = h.copyWith(closesAt: v);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: h.isClosed,
                            onChanged: (v) {
                              setState(() {
                                _hours[i] = h.copyWith(isClosed: v ?? false);
                              });
                            },
                          ),
                          const Text('Closed'),
                          Checkbox(
                            value: h.is24Hours,
                            onChanged: h.isClosed
                                ? null
                                : (v) {
                                    setState(() {
                                      _hours[i] =
                                          h.copyWith(is24Hours: v ?? false);
                                    });
                                  },
                          ),
                          const Text('24 hours'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save hours'),
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'HH:MM',
      ),
      onChanged: onChanged,
    );
  }
}

Future<void> showFacilityHoursEditor(
  BuildContext context,
  List<FacilityHour> hours, {
  String title = 'Edit working hours',
  Future<void> Function(List<FacilityHour> hours)? onSave,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => FacilityHoursEditorSheet(
      initialHours: hours,
      title: title,
      onSave: onSave,
    ),
  );
}
