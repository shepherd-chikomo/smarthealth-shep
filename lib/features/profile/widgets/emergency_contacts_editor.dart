import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';

/// Device-local emergency contacts editor with native contact picker.
class EmergencyContactsEditor extends StatelessWidget {
  const EmergencyContactsEditor({
    super.key,
    required this.contacts,
    required this.onChanged,
  });

  final List<EmergencyContactInfo> contacts;
  final ValueChanged<List<EmergencyContactInfo>> onChanged;

  Future<void> _addFromDeviceContacts(BuildContext context) async {
    if (contacts.length >= EmergencyMedicalMetadata.maxEmergencyContacts) {
      _showLimitSnackBar(context);
      return;
    }

    final granted = await _requestContactsPermission();
    if (!granted) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission is required')),
      );
      return;
    }

    if (!context.mounted) return;
    final picked = await _pickContacts(context);
    if (picked.isEmpty) return;

    final merged = List<EmergencyContactInfo>.from(contacts);
    for (final contact in picked) {
      if (merged.length >= EmergencyMedicalMetadata.maxEmergencyContacts) break;
      if (_isDuplicate(merged, contact)) continue;
      merged.add(contact);
    }
    onChanged(merged);
  }

  Future<bool> _requestContactsPermission() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) return true;
    final result =
        await FlutterContacts.permissions.request(PermissionType.read);
    return result == PermissionStatus.granted ||
        result == PermissionStatus.limited;
  }

  Future<List<EmergencyContactInfo>> _pickContacts(BuildContext context) async {
    final deviceContacts = await FlutterContacts.getAll(
      properties: {ContactProperty.name, ContactProperty.phone},
    );
    if (!context.mounted) return const [];

    final remaining =
        EmergencyMedicalMetadata.maxEmergencyContacts - contacts.length;
    if (remaining <= 0) return const [];

    final selected = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ContactPickerSheet(
        contacts: deviceContacts,
        maxSelection: remaining,
      ),
    );
    if (selected == null || selected.isEmpty) return const [];

    return selected
        .map((index) => _mapContact(deviceContacts[index]))
        .where((c) => c.hasAny)
        .toList();
  }

  EmergencyContactInfo _mapContact(Contact contact) {
    final phone = contact.phones.isNotEmpty
        ? contact.phones.first.number.replaceAll(RegExp(r'\s+'), ' ')
        : null;
    final displayName = contact.displayName?.trim();
    return EmergencyContactInfo(
      name: displayName == null || displayName.isEmpty ? null : displayName,
      phone: phone == null || phone.trim().isEmpty ? null : phone.trim(),
    );
  }

  bool _isDuplicate(
    List<EmergencyContactInfo> existing,
    EmergencyContactInfo candidate,
  ) {
    final phone = candidate.phone?.replaceAll(RegExp(r'\D'), '');
    if (phone != null && phone.isNotEmpty) {
      return existing.any(
        (c) => c.phone?.replaceAll(RegExp(r'\D'), '') == phone,
      );
    }
    final name = candidate.name?.toLowerCase().trim();
    if (name != null && name.isNotEmpty) {
      return existing.any(
        (c) => c.name?.toLowerCase().trim() == name,
      );
    }
    return false;
  }

  void _showLimitSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Maximum ${EmergencyMedicalMetadata.maxEmergencyContacts} emergency contacts',
        ),
      ),
    );
  }

  void _updateContact(int index, EmergencyContactInfo updated) {
    final next = List<EmergencyContactInfo>.from(contacts);
    next[index] = updated;
    onChanged(next);
  }

  void _removeContact(int index) {
    final next = List<EmergencyContactInfo>.from(contacts)..removeAt(index);
    onChanged(next);
  }

  void _addManualContact() {
    if (contacts.length >= EmergencyMedicalMetadata.maxEmergencyContacts) return;
    onChanged([...contacts, const EmergencyContactInfo()]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: contacts.length >=
                        EmergencyMedicalMetadata.maxEmergencyContacts
                    ? null
                    : () => _addFromDeviceContacts(context),
                icon: const Icon(Symbols.contacts),
                label: const Text('Add from contacts'),
                style: OutlinedButton.styleFrom(
                  minimumSize:
                      const Size.fromHeight(AppConstants.minTapTarget),
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: contacts.length >=
                      EmergencyMedicalMetadata.maxEmergencyContacts
                  ? null
                  : _addManualContact,
              child: const Text('Add manual'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Up to ${EmergencyMedicalMetadata.maxEmergencyContacts} contacts · stored on this device only',
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        if (contacts.isEmpty)
          Text(
            'No emergency contacts added',
            style: TextStyle(color: colors.textSecondary),
          ),
        for (var i = 0; i < contacts.length; i++) ...[
          _EmergencyContactTile(
            contact: contacts[i],
            onChanged: (updated) => _updateContact(i, updated),
            onRemove: () => _removeContact(i),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _EmergencyContactTile extends StatefulWidget {
  const _EmergencyContactTile({
    required this.contact,
    required this.onChanged,
    required this.onRemove,
  });

  final EmergencyContactInfo contact;
  final ValueChanged<EmergencyContactInfo> onChanged;
  final VoidCallback onRemove;

  @override
  State<_EmergencyContactTile> createState() => _EmergencyContactTileState();
}

class _EmergencyContactTileState extends State<_EmergencyContactTile> {
  late TextEditingController _nameController;
  late TextEditingController _relationshipController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name ?? '');
    _relationshipController =
        TextEditingController(text: widget.contact.relationship ?? '');
    _phoneController = TextEditingController(text: widget.contact.phone ?? '');
  }

  @override
  void didUpdateWidget(covariant _EmergencyContactTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contact.name != widget.contact.name) {
      _nameController.text = widget.contact.name ?? '';
    }
    if (oldWidget.contact.relationship != widget.contact.relationship) {
      _relationshipController.text = widget.contact.relationship ?? '';
    }
    if (oldWidget.contact.phone != widget.contact.phone) {
      _phoneController.text = widget.contact.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      EmergencyContactInfo(
        name: _optional(_nameController.text),
        relationship: _optional(_relationshipController.text),
        phone: _optional(_phoneController.text),
      ),
    );
  }

  String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: _decoration(context, 'Name'),
            onChanged: (_) => _emit(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _relationshipController,
            decoration: _decoration(context, 'Relationship'),
            onChanged: (_) => _emit(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  decoration: _decoration(context, 'Phone'),
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => _emit(),
                ),
              ),
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.close),
              ),
            ],
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
      fillColor: colors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      isDense: true,
    );
  }
}

class _ContactPickerSheet extends StatefulWidget {
  const _ContactPickerSheet({
    required this.contacts,
    required this.maxSelection,
  });

  final List<Contact> contacts;
  final int maxSelection;

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  final Set<int> _selected = {};
  String _query = '';

  List<Contact> get _filtered {
    if (_query.trim().isEmpty) return widget.contacts;
    final q = _query.toLowerCase();
    return widget.contacts
        .where((c) => (c.displayName ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search contacts',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select up to ${widget.maxSelection}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final contact = filtered[index];
                  final sourceIndex = widget.contacts.indexOf(contact);
                  final phone = contact.phones.isNotEmpty
                      ? contact.phones.first.number
                      : '';
                  final checked = _selected.contains(sourceIndex);
                  return CheckboxListTile(
                    value: checked,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          if (_selected.length >= widget.maxSelection) return;
                          _selected.add(sourceIndex);
                        } else {
                          _selected.remove(sourceIndex);
                        }
                      });
                    },
                    title: Text(contact.displayName ?? 'Unknown'),
                    subtitle: phone.isEmpty ? null : Text(phone),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => Navigator.pop(context, _selected),
                  style: FilledButton.styleFrom(
                    minimumSize:
                        const Size.fromHeight(AppConstants.minTapTarget),
                  ),
                  child: Text('Add ${_selected.length} contact(s)'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
