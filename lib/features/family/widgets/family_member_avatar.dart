import 'package:flutter/material.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

/// Gender-based avatar circle for family member cards.
class FamilyMemberAvatar extends StatelessWidget {
  const FamilyMemberAvatar({
    super.key,
    required this.name,
    this.gender,
    this.size = 48,
  });

  final String name;
  final FamilyGender? gender;
  final double size;

  Color get _backgroundColor => switch (gender) {
        FamilyGender.male => const Color(0xFF1976D2),
        FamilyGender.female => const Color(0xFFE91E8C),
        FamilyGender.other => const Color(0xFF7B61FF),
        null => HomeDashboardColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _backgroundColor.withValues(alpha: 0.18),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          color: _backgroundColor,
        ),
      ),
    );
  }
}
