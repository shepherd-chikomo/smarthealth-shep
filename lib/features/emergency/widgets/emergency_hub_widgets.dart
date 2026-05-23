import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_service.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';

Color emergencyKindColor(EmergencyServiceKind kind) {
  return HomeDashboardColors.emergency;
}

String emergencyIconAsset(EmergencyServiceKind kind) {
  return switch (kind) {
    EmergencyServiceKind.ambulance => AppAssets.emergencyAmbulance,
    EmergencyServiceKind.police => AppAssets.emergencyPolice,
    EmergencyServiceKind.fireRescue => AppAssets.emergencyFire,
    EmergencyServiceKind.rescueTeam => AppAssets.emergencyRescue,
  };
}

class EmergencyWarningBanner extends StatelessWidget {
  const EmergencyWarningBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        color: HomeDashboardColors.emergencySoft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: HomeDashboardColors.emergency,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: HomeDashboardColors.emergency,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyServiceGridCard extends StatelessWidget {
  const EmergencyServiceGridCard({
    super.key,
    required this.service,
    required this.distanceLabel,
    required this.onTap,
  });

  final EmergencyService service;
  final String distanceLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${service.name}, $distanceLabel',
      child: Material(
        color: HomeDashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E8EE)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: SvgPicture.asset(
                    emergencyIconAsset(service.kind),
                    width: 52,
                    height: 52,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  service.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: HomeDashboardColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  distanceLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HomeDashboardColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmergencyFacilityCard extends StatelessWidget {
  const EmergencyFacilityCard({
    super.key,
    required this.name,
    required this.type,
    required this.distanceLabel,
    required this.callLabel,
    required this.directionsLabel,
    required this.onCall,
    required this.onDirections,
  });

  final String name;
  final String type;
  final String distanceLabel;
  final String callLabel;
  final String directionsLabel;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeDashboardColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: HomeDashboardColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type,
                        style: const TextStyle(
                          fontSize: 13,
                          color: HomeDashboardColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        distanceLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: HomeDashboardColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: callLabel,
                  child: FilledButton(
                    onPressed: onCall,
                    style: FilledButton.styleFrom(
                      backgroundColor: HomeDashboardColors.emergency,
                      minimumSize: const Size(72, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(
                      callLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Semantics(
                button: true,
                label: directionsLabel,
                child: TextButton(
                  onPressed: onDirections,
                  child: Text(directionsLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyCallNowButton extends StatelessWidget {
  const EmergencyCallNowButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: double.infinity,
        height: AppConstants.minTapTarget,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: HomeDashboardColors.emergency,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
