import 'package:flutter/material.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class PracticeKpiCard extends StatelessWidget {
  const PracticeKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    this.icon,
    this.accentColor,
    this.sparkline,
  });

  final String label;
  final String value;
  final String? trend;
  final IconData? icon;
  final Color? accentColor;
  final List<double>? sparkline;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = accentColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(icon, size: 18, color: accent),
                ),
              const Spacer(),
              if (sparkline != null)
                SizedBox(
                  width: 56,
                  height: 24,
                  child: CustomPaint(
                    painter: _SparklinePainter(
                      values: sparkline!,
                      color: accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(value, style: PracticeDesignTokens.kpiValue(context)),
          const SizedBox(height: 4),
          Text(label,
              style: PracticeDesignTokens.inter(
                size: 13,
                color: colors.mutedForeground,
              )),
          if (trend != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  trend!.startsWith('+') || trend!.contains('priority')
                      ? Icons.trending_up
                      : Icons.trending_flat,
                  size: 14,
                  color: trend!.contains('overdue')
                      ? colors.emergency
                      : colors.success,
                ),
                const SizedBox(width: 4),
                Text(trend!,
                    style: PracticeDesignTokens.inter(
                      size: 12,
                      color: colors.mutedForeground,
                    )),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final range = (max - min).clamp(0.001, double.infinity);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - min) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PracticeStatusChip extends StatelessWidget {
  const PracticeStatusChip({
    super.key,
    required this.label,
    this.tone = PracticeStatusTone.neutral,
  });

  final String label;
  final PracticeStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final color = tone.color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label,
          style: PracticeDesignTokens.inter(
            size: 11,
            weight: FontWeight.w600,
            color: color,
          )),
    );
  }

  static PracticeStatusTone toneForClaimStatus(String status) {
    return switch (status) {
      'paid' || 'approved' => PracticeStatusTone.success,
      'under review' || 'checked in' => PracticeStatusTone.warning,
      'rejected' => PracticeStatusTone.danger,
      'in consult' => PracticeStatusTone.info,
      'scheduled' => PracticeStatusTone.neutral,
      'waiting' => PracticeStatusTone.queue,
      _ => PracticeStatusTone.neutral,
    };
  }
}

class PracticeSectionHeader extends StatelessWidget {
  const PracticeSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(title, style: PracticeDesignTokens.sectionTitle(context)),
          const Spacer(),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class PracticeEmptyState extends StatelessWidget {
  const PracticeEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: PracticeDesignTokens.sectionTitle(context)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: PracticeDesignTokens.metadata(context)),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: () {}, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class PracticeBarChart extends StatelessWidget {
  const PracticeBarChart({
    super.key,
    required this.labels,
    required this.values,
    this.maxY = 100,
    this.title,
  });

  final List<String> labels;
  final List<double> values;
  final double maxY;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: PracticeDesignTokens.sectionTitle(context)),
            const SizedBox(height: 16),
          ],
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < values.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: (values[i] / maxY).clamp(0.05, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.85),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(labels[i],
                              style: PracticeDesignTokens.inter(size: 10)),
                        ],
                      ),
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

class PracticeAvatar extends StatelessWidget {
  const PracticeAvatar({super.key, required this.initials, this.size = 40});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: context.appColors.primarySoft,
      child: Text(initials,
          style: PracticeDesignTokens.inter(
            size: size * 0.32,
            weight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          )),
    );
  }
}
