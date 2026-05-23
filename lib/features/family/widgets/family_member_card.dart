import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/family/widgets/family_member_avatar.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

/// List card for a single family member.
class FamilyMemberCard extends StatelessWidget {
  const FamilyMemberCard({
    super.key,
    required this.member,
    required this.onEdit,
  });

  final FamilyMemberModel member;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final dobLabel = member.dateOfBirth != null
        ? DateFormat('d MMM yyyy').format(DateTime.parse(member.dateOfBirth!))
        : 'Not set';

    return Material(
      color: HomeDashboardColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: member.isPrimaryAccountHolder
                ? HomeDashboardColors.primary
                : const Color(0xFFE5E8EE),
            width: member.isPrimaryAccountHolder ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FamilyMemberAvatar(name: member.name, gender: member.gender),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (member.isPrimaryAccountHolder)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: HomeDashboardColors.primary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Primary',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: HomeDashboardColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.relationship,
                    style: const TextStyle(
                      fontSize: 13,
                      color: HomeDashboardColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MetaRow(
                    icon: Symbols.cake,
                    label: 'DOB: $dobLabel',
                  ),
                  if (member.ageGroupLabel != null) ...[
                    const SizedBox(height: 4),
                    _MetaRow(
                      icon: Symbols.groups,
                      label: 'Age group: ${member.ageGroupLabel}',
                    ),
                  ],
                ],
              ),
            ),
            TextButton(
              onPressed: onEdit,
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: HomeDashboardColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: HomeDashboardColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
