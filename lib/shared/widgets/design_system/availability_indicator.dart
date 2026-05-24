import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/design_system_tokens.dart';

/// Inline operational availability summary, e.g.
/// "Open Now · Queue: 5 · Next Slot 2:30 PM".
class AvailabilityIndicator extends StatelessWidget {
  const AvailabilityIndicator({
    super.key,
    this.isOpenNow,
    this.isClosingSoon,
    this.queueLength,
    this.waitEstimateMinutes,
    this.nextAvailableSlot,
    this.textStyle,
  });

  factory AvailabilityIndicator.fromProvider(ProviderModel provider) {
    return AvailabilityIndicator(
      isOpenNow: provider.isOpenNow,
      isClosingSoon: provider.isClosingSoon,
      queueLength: provider.queueLength,
      waitEstimateMinutes: provider.waitEstimateMinutes ??
          (provider.queueLength != null && provider.queueLength! > 0
              ? provider.queueLength! * 6
              : null),
      nextAvailableSlot: provider.nextAvailableSlot,
    );
  }

  final bool? isOpenNow;
  final bool? isClosingSoon;
  final int? queueLength;
  final int? waitEstimateMinutes;
  final DateTime? nextAvailableSlot;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final segments = _buildSegments();
    if (segments.isEmpty) return const SizedBox.shrink();

    final style = textStyle ??
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: HomeDashboardColors.textSecondary,
          height: 1.3,
        );

    return Semantics(
      label: segments.join(', '),
      child: Text.rich(
        TextSpan(children: _buildSpans(segments, style)),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  List<_Segment> _buildSegments() {
    final segments = <_Segment>[];

    if (isClosingSoon == true) {
      segments.add(
        _Segment(
          'Closing Soon',
          color: DesignSystemColors.warning,
        ),
      );
    } else if (isOpenNow == true) {
      segments.add(
        _Segment(
          'Open Now',
          color: DesignSystemColors.success,
        ),
      );
    } else if (isOpenNow == false) {
      segments.add(
        _Segment(
          'Closed',
          color: HomeDashboardColors.textSecondary,
        ),
      );
    }

    if (queueLength != null && queueLength! > 0) {
      segments.add(
        _Segment(
          'Queue: $queueLength',
          color: DesignSystemColors.primary,
        ),
      );
    }

    if (waitEstimateMinutes != null && waitEstimateMinutes! > 0) {
      segments.add(
        _Segment(
          'Wait ~${waitEstimateMinutes}m',
          color: DesignSystemColors.primary,
        ),
      );
    }

    if (nextAvailableSlot != null) {
      final formatted = DateFormat.jm().format(nextAvailableSlot!.toLocal());
      segments.add(
        _Segment(
          'Next Slot $formatted',
          color: HomeDashboardColors.textSecondary,
        ),
      );
    }

    return segments;
  }

  List<InlineSpan> _buildSpans(List<_Segment> segments, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) {
        spans.add(TextSpan(text: ' · ', style: baseStyle));
      }
      spans.add(
        TextSpan(
          text: segments[i].label,
          style: baseStyle.copyWith(color: segments[i].color),
        ),
      );
    }
    return spans;
  }
}

class _Segment {
  const _Segment(this.label, {required this.color});

  final String label;
  final Color color;
}
