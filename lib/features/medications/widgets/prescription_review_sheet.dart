import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/medications/utils/medication_reminder_times.dart';
import 'package:smarthealth_shep/features/medications/utils/medication_schedule_utils.dart';
import 'package:smarthealth_shep/features/medications/utils/prescription_label_parser.dart';
import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';

class PrescriptionReviewResult {
  const PrescriptionReviewResult({
    required this.entry,
    required this.reminderEnabled,
  });

  final MedicationEntry entry;
  final bool reminderEnabled;
}

/// Review and confirm OCR-parsed prescription fields before adding.
class PrescriptionReviewSheet extends StatefulWidget {
  const PrescriptionReviewSheet({
    super.key,
    required this.fields,
  });

  final PrescriptionLabelFields fields;

  static Future<PrescriptionReviewResult?> show(
    BuildContext context, {
    required PrescriptionLabelFields fields,
  }) {
    return showModalBottomSheet<PrescriptionReviewResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: PrescriptionReviewSheet(fields: fields),
      ),
    );
  }

  @override
  State<PrescriptionReviewSheet> createState() =>
      _PrescriptionReviewSheetState();
}

class _PrescriptionReviewSheetState extends State<PrescriptionReviewSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _frequencyController;
  late final TextEditingController _quantityController;
  bool _reminderEnabled = false;
  List<TimeOfDay> _reminderTimes = const [TimeOfDay(hour: 8, minute: 0)];

  @override
  void initState() {
    super.initState();
    final fields = widget.fields;
    _nameController = TextEditingController(text: fields.medicationName ?? '');
    _dosageController = TextEditingController(text: fields.dosage ?? '');
    _frequencyController = TextEditingController(text: fields.frequency ?? '');
    _quantityController = TextEditingController(text: fields.quantity ?? '');
    _syncReminderSlots();
    _frequencyController.addListener(_syncReminderSlots);
  }

  @override
  void dispose() {
    _frequencyController.removeListener(_syncReminderSlots);
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _syncReminderSlots() {
    if (!_reminderEnabled) return;
    final frequency = _frequencyController.text.trim();
    final doses = MedicationScheduleUtils.dosesPerDayFromFrequency(
      frequency.isEmpty ? null : frequency,
    );
    final entry = MedicationEntry(
      name: _nameController.text.trim(),
      frequency: frequency.isEmpty ? null : frequency,
      dosesPerDay: doses,
      reminderEnabled: true,
      reminderTimes: MedicationReminderTimes.toStorage(_reminderTimes),
    );
    setState(() {
      _reminderTimes = MedicationReminderTimes.resolveSlots(
        entry: entry,
        existing: _reminderTimes,
      );
    });
  }

  Future<void> _pickReminderTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTimes[index],
    );
    if (picked != null) {
      setState(() => _reminderTimes[index] = picked);
    }
  }

  void _confirm() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final dosage = _dosageController.text.trim();
    final frequency = _frequencyController.text.trim();
    final quantity = _quantityController.text.trim();
    final displayName =
        dosage.isEmpty ? name : '$name $dosage'.trim();

    final dosesPerDay = MedicationScheduleUtils.dosesPerDayFromFrequency(
      frequency.isEmpty ? null : frequency,
    );

    final entry = MedicationEntry(
      id: 'med_${DateTime.now().microsecondsSinceEpoch}',
      name: displayName,
      frequency: frequency.isEmpty ? null : frequency,
      quantity: quantity.isEmpty ? null : quantity,
      dosesPerDay: dosesPerDay,
      reminderEnabled: _reminderEnabled,
      reminderTimes: _reminderEnabled
          ? MedicationReminderTimes.toStorage(_reminderTimes)
          : const [],
    );

    Navigator.of(context).pop(
      PrescriptionReviewResult(entry: entry, reminderEnabled: _reminderEnabled),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Symbols.document_scanner, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Review prescription',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Check scanned details before adding. Data stays on this device.',
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: _decoration(context, 'Medication name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _dosageController,
            decoration: _decoration(context, 'Dosage'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _frequencyController,
            decoration: _decoration(context, 'Frequency (e.g. OD, BD)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _quantityController,
            decoration: _decoration(context, 'Quantity'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Medication reminders'),
            subtitle: const Text('Local notifications for the next 7 days'),
            value: _reminderEnabled,
            onChanged: (value) {
              setState(() => _reminderEnabled = value);
              if (value) _syncReminderSlots();
            },
          ),
          if (_reminderEnabled)
            for (var i = 0; i < _reminderTimes.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _reminderTimes.length > 1 ? 'Reminder ${i + 1}' : 'Reminder time',
                ),
                subtitle: Text(_formatTime(_reminderTimes[i])),
                trailing: const Icon(Icons.schedule),
                onTap: () => _pickReminderTime(i),
              ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _confirm,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(AppConstants.minTapTarget),
            ),
            child: const Text('Add medication'),
          ),
        ],
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
