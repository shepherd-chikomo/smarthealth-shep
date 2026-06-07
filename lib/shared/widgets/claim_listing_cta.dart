import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/config/portal_config.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/operational_status.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lightweight patient-app CTA that routes owners to the facility claim portal.
class ClaimListingCta extends StatelessWidget {
  const ClaimListingCta({
    super.key,
    required this.targetId,
    this.claimType = 'provider',
    this.claimStatus,
    this.isFacilityListing = false,
  });

  final String targetId;
  final String claimType;
  final ClaimOperationalStatus? claimStatus;
  final bool isFacilityListing;

  Future<void> _openPortal(BuildContext context) async {
    final uri = Uri.parse(PortalConfig.claimUrl(type: claimType, targetId: targetId));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = claimStatus ?? ClaimOperationalStatus.unclaimed;

    if (status == ClaimOperationalStatus.verifiedFacility ||
        status == ClaimOperationalStatus.verifiedPractitioner) {
      return SizedBox.shrink();
    }

    if (status == ClaimOperationalStatus.claimPending) {
      return Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text(
          'Claim pending review',
          style: TextStyle(
            fontSize: 13,
            color: HomeDashboardColors.of(context).textSecondary.withValues(alpha: 0.85),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isFacilityListing ? 'Own this facility?' : 'Own this listing?',
              style: TextStyle(
                fontSize: 13,
                color: HomeDashboardColors.of(context).textSecondary.withValues(alpha: 0.75),
              ),
            ),
            SizedBox(height: 4),
            Semantics(
              button: true,
              label: 'Claim listing',
              child: TextButton(
                onPressed: () => _openPortal(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: HomeDashboardColors.of(context).textSecondary,
                ),
                child: Text(
                  'Claim listing',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: HomeDashboardColors.of(context).textSecondary
                        .withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
