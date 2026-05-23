import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/theme/app_colors.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/shared/models/emergency_service_model.dart';
import 'package:smarthealth_shep/shared/widgets/pulse_emergency.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyTile extends StatelessWidget {
  const EmergencyTile({
    super.key,
    required this.service,
    this.pulse = false,
  });

  final EmergencyServiceModel service;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appColors;
    final leading = pulse
        ? PulseEmergency(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tokens.emergencySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Symbols.emergency, color: tokens.emergency, size: 22),
            ),
          )
        : Icon(Symbols.emergency, color: tokens.emergency);

    return Semantics(
      button: true,
      label: '${service.name}, call ${service.phone}',
      child: ListTile(
        minTileHeight: AppConstants.minTapTarget,
        leading: leading,
        title: Text(service.name),
        subtitle: Text(service.phone),
        trailing: const Icon(Symbols.call),
        onTap: () => _call(service.phone),
      ),
    );
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
