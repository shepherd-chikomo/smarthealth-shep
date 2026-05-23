import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/theme/app_colors.dart';
import 'package:smarthealth_shep/core/theme/app_radii.dart';
import 'package:smarthealth_shep/core/theme/app_text_styles.dart';
import 'package:smarthealth_shep/core/theme/app_theme.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/pulse_emergency.dart';

/// Design system preview — card, primary button, pulsing emergency circle.
class DesignSystemDemoScreen extends StatelessWidget {
  const DesignSystemDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return AppShellScaffold(
      appBar: AppBar(title: const Text('Design System')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'SmartHealth tokens',
              style: AppTextStyles.xxl(color: tokens.foreground),
            ),
            const SizedBox(height: 8),
            Text(
              'Mirrors the web preview — colors, radii, shadows.',
              style: AppTextStyles.sm(color: tokens.mutedForeground),
            ),
            const SizedBox(height: 24),
            AppTheme.themedCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Healthcare directory',
                    style: AppTextStyles.lg(
                      fontWeight: AppTextStyles.semibold,
                      color: tokens.cardForeground,
                      isHeading: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Card radius ${AppRadii.xl.toInt()}px with layered shadow.',
                    style: AppTextStyles.sm(color: tokens.mutedForeground),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Primary action'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: PulseEmergency(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: tokens.emergency,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emergency,
                    color: tokens.emergencyForeground,
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Emergency pulse glow',
              textAlign: TextAlign.center,
              style: AppTextStyles.xs(color: tokens.mutedForeground),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Swatch('Primary', scheme.primary),
                _Swatch('Secondary', scheme.secondary),
                _Swatch('Emergency', tokens.emergency),
                _Swatch('Success', tokens.success),
                _Swatch('Warning', tokens.warning),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.xs()),
      ],
    );
  }
}
