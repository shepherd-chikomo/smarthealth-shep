import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_service.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';

Color emergencyKindColor(BuildContext context, EmergencyServiceKind kind) {
  return HomeDashboardColors.of(context).emergency;
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
  EmergencyWarningBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        color: HomeDashboardColors.of(context).emergencySoft,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: HomeDashboardColors.of(context).emergency,
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: HomeDashboardColors.of(context).emergency,
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
    this.onCall,
  });

  final EmergencyService service;
  final String distanceLabel;
  final VoidCallback onTap;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${service.name}, $distanceLabel',
      child: Material(
        color: HomeDashboardColors.of(context).surface,
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
                SizedBox(height: 10),
                Text(
                  service.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: HomeDashboardColors.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  distanceLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: HomeDashboardColors.of(context).textSecondary,
                  ),
                ),
                if (service.phone.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.phone,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: HomeDashboardColors.of(context).textPrimary,
                    ),
                  ),
                ],
                if (onCall != null) ...[
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: onCall,
                    style: FilledButton.styleFrom(
                      backgroundColor: HomeDashboardColors.of(context).emergency,
                      minimumSize: const Size(64, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text(
                      'Call',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmergencyLocationPrompt extends StatelessWidget {
  const EmergencyLocationPrompt({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onRequestLocation,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onRequestLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HomeDashboardColors.of(context).primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E8EE)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: HomeDashboardColors.of(context).primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: HomeDashboardColors.of(context).textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: onRequestLocation,
            child: Text(actionLabel),
          ),
        ],
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
    this.sourceBadge,
  });

  final String name;
  final String type;
  final String? sourceBadge;
  final String distanceLabel;
  final String callLabel;
  final String directionsLabel;
  final VoidCallback? onCall;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeDashboardColors.of(context).surface,
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: HomeDashboardColors.of(context).textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 13,
                          color: HomeDashboardColors.of(context).textSecondary,
                        ),
                      ),
                      if (sourceBadge != null) ...[
                        SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: HomeDashboardColors.of(context)
                                .emergencySoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            sourceBadge!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: HomeDashboardColors.of(context).emergency,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 4),
                      Text(
                        distanceLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: HomeDashboardColors.of(context).textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onCall != null)
                  Semantics(
                    button: true,
                    label: callLabel,
                    child: FilledButton(
                      onPressed: onCall,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            HomeDashboardColors.of(context).emergency,
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
  final VoidCallback? onPressed;

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
            backgroundColor: HomeDashboardColors.of(context).emergency,
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
