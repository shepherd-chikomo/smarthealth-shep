import 'package:flutter/material.dart';
import 'package:my_practice/core/config/my_practice_config.dart';

class FutureModuleScreen extends StatelessWidget {
  const FutureModuleScreen({super.key, required this.moduleKey});

  final String moduleKey;

  @override
  Widget build(BuildContext context) {
    final meta = _modules[moduleKey] ?? ('Module', 'Coming soon');

    return Scaffold(
      appBar: AppBar(title: Text(meta.$1)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meta.$1, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(meta.$2),
            const SizedBox(height: 16),
            const Text(
              'This module is registered in the architecture and hidden behind '
              'remote feature flags until regulatory and integration approval.',
            ),
          ],
        ),
      ),
    );
  }

  static const _modules = {
    'connect': (
      'SmartHealth Connect',
      'Specialist referral network, laboratory and imaging referrals, provider discovery.',
    ),
    'switch': (
      'SmartHealth Switch',
      'HL7 FHIR R4 interoperability with laboratories, pharmacies, medical aids, and government systems.',
    ),
    'insights': (
      'SmartHealth Insights',
      'Population health analytics, disease surveillance, and facility benchmarking.',
    ),
    'telemedicine': (
      'Telemedicine',
      'Remote consultations pending regulatory approval.',
    ),
    'ai_copilot': (
      'AI Clinical Copilot',
      'Clinical decision support pending approval.',
    ),
  };
}

/// Registry for future module routes (feature-flag controlled).
abstract final class FutureModuleRegistry {
  static const modules = FutureModuleScreen._modules;
}
