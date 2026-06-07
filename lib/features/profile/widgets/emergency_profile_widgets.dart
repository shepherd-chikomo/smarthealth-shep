import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/auth/patient_profile.dart';
import 'package:smarthealth_shep/core/patient_id/smarthealth_patient_id.dart';
import 'package:smarthealth_shep/features/family/widgets/family_member_avatar.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/profile/utils/condition_labels.dart';
import 'package:smarthealth_shep/features/profile/utils/display_text.dart';
import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';
import 'package:url_launcher/url_launcher.dart';

String formatPatientId(String? profileId) {
  if (SmartHealthPatientId.isValid(profileId)) {
    return SmartHealthPatientId.format(profileId);
  }
  return SmartHealthPatientId.prefix + '0000000000';
}

class EmergencyProfileHeaderBanner extends StatelessWidget {
  const EmergencyProfileHeaderBanner({super.key, this.updatedAt});

  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);
    final updatedLabel = updatedAt != null
        ? DateFormat('dd MMM yyyy • HH:mm').format(updatedAt!.toLocal())
        : 'Not yet saved';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.emergency,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Symbols.emergency, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EMERGENCY PROFILE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last Updated: $updatedLabel',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmergencyPatientIdentityCard extends StatelessWidget {
  const EmergencyPatientIdentityCard({
    super.key,
    required this.member,
    this.patientProfile,
    this.patientId,
  });

  final FamilyMemberModel member;
  final PatientProfile? patientProfile;
  final String? patientId;

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);
    final metadata = member.metadata ?? const EmergencyMedicalMetadata();
    final genderLabel = member.gender?.label ?? '—';
    final age = member.ageYears;
    final demographics = age != null ? '$genderLabel • $age Years' : genderLabel;
    final displayName = decodeStoredText(member.name);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primaryDark.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FamilyMemberAvatar(name: displayName, gender: member.gender, size: 68),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.primaryDark,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  demographics,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Patient ID: ${formatPatientId(patientId)}',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                if (metadata.bloodGroup != null &&
                    metadata.bloodGroup!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Symbols.bloodtype, color: colors.emergency, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Blood Group: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                      Text(
                        decodeStoredText(metadata.bloodGroup),
                        style: TextStyle(
                          color: colors.emergency,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TintedSectionCard extends StatelessWidget {
  const _TintedSectionCard({
    required this.title,
    required this.icon,
    required this.tint,
    required this.border,
    required this.titleColor,
    required this.child,
    this.compact = false,
  });

  final String title;
  final IconData icon;
  final Color tint;
  final Color border;
  final Color titleColor;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: titleColor, size: compact ? 18 : 22),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 10 : 13,
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 10),
          child,
        ],
      ),
    );
  }
}

class _OutlinedSectionCard extends StatelessWidget {
  const _OutlinedSectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primaryDark.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primaryDark, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class SevereAllergyCard extends StatelessWidget {
  const SevereAllergyCard({super.key, this.allergy});

  final String? allergy;

  @override
  Widget build(BuildContext context) {
    if (allergy == null || allergy!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final colors = HomeDashboardColors.of(context);
    return _TintedSectionCard(
      title: 'SEVERE ALLERGY',
      icon: Symbols.warning,
      tint: colors.emergencySoft,
      border: colors.emergency.withValues(alpha: 0.45),
      titleColor: colors.emergency,
      child: Text(
        decodeStoredText(allergy),
        style: TextStyle(
          color: colors.emergency,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

class HighRiskConditionsCard extends StatelessWidget {
  const HighRiskConditionsCard({
    super.key,
    required this.conditionIds,
    this.customLabels = const {},
  });

  final List<String> conditionIds;
  final Map<String, String> customLabels;

  @override
  Widget build(BuildContext context) {
    if (conditionIds.isEmpty) return const SizedBox.shrink();
    final colors = HomeDashboardColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _TintedSectionCard(
      title: 'HIGH RISK CONDITIONS',
      icon: Symbols.cardiology,
      tint: isDark
          ? const Color(0xFF3D2E1A)
          : colors.warning.withValues(alpha: 0.12),
      border: colors.warning.withValues(alpha: 0.5),
      titleColor: colors.warning,
      child: Text(
        ConditionLabels.joinLabels(conditionIds, customLabels: customLabels),
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}

class CurrentMedicationsCard extends StatelessWidget {
  const CurrentMedicationsCard({super.key, required this.medications});

  final List<MedicationEntry> medications;

  @override
  Widget build(BuildContext context) {
    if (medications.isEmpty) return const SizedBox.shrink();
    final colors = HomeDashboardColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _TintedSectionCard(
      title: 'CURRENT MEDICATIONS',
      icon: Symbols.medication,
      tint: isDark ? const Color(0xFF1A2A3D) : colors.primary.withValues(alpha: 0.08),
      border: colors.primary.withValues(alpha: 0.35),
      titleColor: colors.primary,
      child: Column(
        children: [
          for (var i = 0; i < medications.length; i++) ...[
            if (i > 0) Divider(color: colors.primary.withValues(alpha: 0.15)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    decodeStoredText(medications[i].name),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                if (medications[i].frequency != null &&
                    medications[i].frequency!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      decodeStoredText(medications[i].frequency),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard({super.key, required this.contact, this.compact = false});

  final EmergencyContactInfo contact;
  final bool compact;

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    if (!contact.hasAny) return const SizedBox.shrink();
    const green = Color(0xFF2E7D32);
    return _TintedSectionCard(
      title: 'EMERGENCY CONTACT',
      icon: Symbols.person,
      tint: const Color(0xFFE8F5E9),
      border: green.withValues(alpha: 0.35),
      titleColor: green,
      compact: compact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contact.name != null)
            Text(
              decodeStoredText(contact.name),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: compact ? 13 : 15,
                color: const Color(0xFF1A2138),
              ),
            ),
          if (contact.relationship != null)
            Text(
              decodeStoredText(contact.relationship),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4A5568),
              ),
            ),
          if (contact.phone != null) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: () => _call(contact.phone!),
              child: Row(
                children: [
                  const Icon(Symbols.call, color: green, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      decodeStoredText(contact.phone),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MedicalAidCard extends StatelessWidget {
  const MedicalAidCard({super.key, required this.medicalAid, this.compact = false});

  final MedicalAidInfo medicalAid;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!medicalAid.hasAny) return const SizedBox.shrink();
    const purple = Color(0xFF6A1B9A);
    const valueColor = Color(0xFF1A2138);
    const labelColor = Color(0xFF5C6370);
    return _TintedSectionCard(
      title: 'MEDICAL AID',
      icon: Symbols.shield,
      tint: const Color(0xFFF3E5F5),
      border: purple.withValues(alpha: 0.3),
      titleColor: purple,
      compact: compact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (medicalAid.provider != null) ...[
            const Text('Provider', style: TextStyle(fontSize: 10, color: labelColor)),
            Text(
              decodeStoredText(medicalAid.provider),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: compact ? 12 : 13,
                color: valueColor,
              ),
            ),
          ],
          if (medicalAid.memberNumber != null) ...[
            const SizedBox(height: 6),
            const Text(
              'Member Number',
              style: TextStyle(fontSize: 10, color: labelColor),
            ),
            Text(
              decodeStoredText(medicalAid.memberNumber),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: compact ? 12 : 13,
                color: valueColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MedicalHistoryCard extends StatelessWidget {
  const MedicalHistoryCard({
    super.key,
    required this.conditionIds,
    this.customLabels = const {},
  });

  final List<String> conditionIds;
  final Map<String, String> customLabels;

  @override
  Widget build(BuildContext context) {
    if (conditionIds.isEmpty) return const SizedBox.shrink();
    final colors = HomeDashboardColors.of(context);
    return _OutlinedSectionCard(
      title: 'MEDICAL HISTORY',
      icon: Symbols.assignment,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: conditionIds
            .map(
              (id) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  customLabels[id] ?? ConditionLabels.labelFor(id),
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class PrimaryProviderCard extends StatelessWidget {
  const PrimaryProviderCard({super.key, required this.provider});

  final PrimaryProviderInfo provider;

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  String _providerLabel() {
    final facility = decodeStoredText(provider.facilityName);
    final doctor = decodeStoredText(provider.doctorName);
    if (doctor.isNotEmpty && facility.isNotEmpty) return '$doctor · $facility';
    if (facility.isNotEmpty) return facility;
    if (doctor.isNotEmpty) return doctor;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (!provider.hasAny) return const SizedBox.shrink();
    final colors = HomeDashboardColors.of(context);
    final label = _providerLabel();
    return _OutlinedSectionCard(
      title: 'PRIMARY PROVIDER',
      icon: Symbols.local_hospital,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: colors.textPrimary,
                height: 1.25,
              ),
            ),
          ),
          if (provider.phone != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _call(provider.phone!),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Symbols.call, color: colors.primaryDark, size: 18),
                    const SizedBox(height: 2),
                    Text(
                      decodeStoredText(provider.phone),
                      style: TextStyle(
                        color: colors.primaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Side-by-side emergency contact and medical aid row matching the mockup.
class EmergencyContactMedicalAidRow extends StatelessWidget {
  const EmergencyContactMedicalAidRow({
    super.key,
    required this.contact,
    required this.medicalAid,
  });

  final EmergencyContactInfo contact;
  final MedicalAidInfo medicalAid;

  @override
  Widget build(BuildContext context) {
    final showContact = contact.hasAny;
    final showAid = medicalAid.hasAny;
    if (!showContact && !showAid) return const SizedBox.shrink();
    if (!showContact) return MedicalAidCard(medicalAid: medicalAid);
    if (!showAid) return EmergencyContactCard(contact: contact);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 360;
        if (stacked) {
          return Column(
            children: [
              EmergencyContactCard(contact: contact),
              const SizedBox(height: 10),
              MedicalAidCard(medicalAid: medicalAid),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: EmergencyContactCard(contact: contact, compact: true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MedicalAidCard(medicalAid: medicalAid, compact: true),
            ),
          ],
        );
      },
    );
  }
}
