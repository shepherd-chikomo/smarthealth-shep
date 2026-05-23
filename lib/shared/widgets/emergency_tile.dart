import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/theme/app_colors.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/shared/models/emergency_service_model.dart';
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
    final child = Semantics(
      button: true,
      label: '${service.name}, call ${service.phone}',
      child: ListTile(
        minTileHeight: AppConstants.minTapTarget,
        leading: Icon(
          Symbols.emergency,
          color: AppColors.emergency,
        ),
        title: Text(service.name),
        subtitle: Text(service.phone),
        trailing: const Icon(Symbols.call),
        onTap: () => _call(service.phone),
      ),
    );

    if (!pulse) return child;

    return _EmergencyPulse(child: child);
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// Single allowed non-Material emergency pulse animation.
class _EmergencyPulse extends StatefulWidget {
  const _EmergencyPulse({required this.child});

  final Widget child;

  @override
  State<_EmergencyPulse> createState() => _EmergencyPulseState();
}

class _EmergencyPulseState extends State<_EmergencyPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1 + (_controller.value * 0.02);
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}
