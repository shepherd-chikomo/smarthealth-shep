import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_service.dart';
import 'package:smarthealth_shep/shared/utils/maps_launcher.dart';
import 'package:smarthealth_shep/features/emergency/widgets/emergency_hub_widgets.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyServiceDetailScreen extends StatelessWidget {
  const EmergencyServiceDetailScreen({
    super.key,
    required this.service,
  });

  final EmergencyService service;

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _directions() async {
    final query = service.nearestLatitude != null &&
            service.nearestLongitude != null
        ? '${service.nearestLatitude},${service.nearestLongitude}'
        : service.nearestProviderName;
    if (query == null) return;
    await openInMaps(query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppShellScaffold(      backgroundColor: HomeDashboardColors.of(context).background,
      appBar: AppBar(
        title: Text(service.name),
        backgroundColor: HomeDashboardColors.of(context).background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SvgPicture.asset(
                emergencyIconAsset(service.kind),
                width: 88,
                height: 88,
              ),
            ),            SizedBox(height: 16),
            Text(
              service.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: HomeDashboardColors.of(context).textPrimary,
              ),
            ),
            SizedBox(height: 24),
            if (service.nearestProviderName != null) ...[
              Text(
                l10n.emergencyNearestProvider,
                style: TextStyle(
                  fontSize: 13,
                  color: HomeDashboardColors.of(context).textSecondary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                service.nearestProviderName!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                l10n.emergencyNearestDistance(service.nearestDistanceKm),
                style: TextStyle(
                  fontSize: 14,
                  color: HomeDashboardColors.of(context).textSecondary,
                ),
              ),
            ],
            Spacer(),
            if (service.phone.trim().isNotEmpty) ...[
              Text(
                service.phone,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: HomeDashboardColors.of(context).textPrimary,
                ),
              ),
              SizedBox(height: 16),
            ],
            EmergencyCallNowButton(
              label: l10n.emergencyCallNow,
              onPressed: service.phone.trim().isNotEmpty
                  ? () => _call(service.phone)
                  : null,
            ),
            SizedBox(height: 12),
            SizedBox(
              height: AppConstants.minTapTarget,
              child: OutlinedButton(
                onPressed: _directions,
                style: OutlinedButton.styleFrom(
                  foregroundColor: HomeDashboardColors.of(context).primary,
                  side: BorderSide(color: HomeDashboardColors.of(context).primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.emergencyShowDirections),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
