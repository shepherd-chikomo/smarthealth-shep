import 'package:flutter/material.dart';
import 'package:smarthealth_shep/shared/models/operational_status.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/design_system_tokens.dart';

/// Semantic color tone for operational status chips.
enum StatusChipTone {
  success,
  warning,
  queue,
  emergency,
  pending,
  verified,
  neutral,
}

/// Rounded pill chip for healthcare operational states.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusChipTone.neutral,
    this.icon,
    this.compact = false,
  });

  factory StatusChip.facility(FacilityOperationalStatus status) {
    return StatusChip(
      label: _facilityLabel(status),
      tone: _facilityTone(status),
      icon: _facilityIcon(status),
      compact: true,
    );
  }

  factory StatusChip.appointment(AppointmentOperationalStatus status) {
    return StatusChip(
      label: _appointmentLabel(status),
      tone: _appointmentTone(status),
      icon: _appointmentIcon(status),
    );
  }

  factory StatusChip.claim(ClaimOperationalStatus status) {
    return StatusChip(
      label: _claimLabel(status),
      tone: _claimTone(status),
      icon: _claimIcon(status),
    );
  }

  final String label;
  final StatusChipTone tone;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _toneColor(tone);
    final fontSize = compact ? 10.0 : 11.0;
    final iconSize = compact ? 12.0 : 14.0;
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    return Semantics(
      label: label,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(
            compact ? 6 : DesignSystemMetrics.radiusPill,
          ),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: color),
              SizedBox(width: compact ? 2 : 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _toneColor(StatusChipTone tone) {
    return switch (tone) {
      StatusChipTone.success => DesignSystemColors.success,
      StatusChipTone.warning => DesignSystemColors.warning,
      StatusChipTone.queue => DesignSystemColors.primary,
      StatusChipTone.emergency => DesignSystemColors.emergency,
      StatusChipTone.pending => DesignSystemColors.pending,
      StatusChipTone.verified => DesignSystemColors.secondary,
      StatusChipTone.neutral => DesignSystemColors.textSecondary,
    };
  }

  static String _facilityLabel(FacilityOperationalStatus status) {
    return switch (status) {
      FacilityOperationalStatus.openNow => 'Open Now',
      FacilityOperationalStatus.closed => 'Closed',
      FacilityOperationalStatus.closingSoon => 'Closing Soon',
      FacilityOperationalStatus.emergencyAvailable => 'Emergency Available',
      FacilityOperationalStatus.walkInsAccepted => 'Walk-ins Accepted',
      FacilityOperationalStatus.queueAvailable => 'Queue Available',
      FacilityOperationalStatus.availableToday => 'Available Today',
    };
  }

  static StatusChipTone _facilityTone(FacilityOperationalStatus status) {
    return switch (status) {
      FacilityOperationalStatus.openNow => StatusChipTone.success,
      FacilityOperationalStatus.closed => StatusChipTone.neutral,
      FacilityOperationalStatus.closingSoon => StatusChipTone.warning,
      FacilityOperationalStatus.emergencyAvailable => StatusChipTone.emergency,
      FacilityOperationalStatus.walkInsAccepted => StatusChipTone.success,
      FacilityOperationalStatus.queueAvailable => StatusChipTone.queue,
      FacilityOperationalStatus.availableToday => StatusChipTone.success,
    };
  }

  static IconData? _facilityIcon(FacilityOperationalStatus status) {
    return switch (status) {
      FacilityOperationalStatus.emergencyAvailable => Icons.emergency_outlined,
      FacilityOperationalStatus.walkInsAccepted => Icons.directions_walk_outlined,
      FacilityOperationalStatus.queueAvailable => Icons.groups_outlined,
      _ => null,
    };
  }

  static String _appointmentLabel(AppointmentOperationalStatus status) {
    return switch (status) {
      AppointmentOperationalStatus.pending => 'Pending',
      AppointmentOperationalStatus.confirmed => 'Confirmed',
      AppointmentOperationalStatus.checkedIn => 'Checked In',
      AppointmentOperationalStatus.inQueue => 'In Queue',
      AppointmentOperationalStatus.completed => 'Completed',
      AppointmentOperationalStatus.cancelled => 'Cancelled',
      AppointmentOperationalStatus.noShow => 'No Show',
      AppointmentOperationalStatus.rescheduled => 'Rescheduled',
    };
  }

  static StatusChipTone _appointmentTone(AppointmentOperationalStatus status) {
    return switch (status) {
      AppointmentOperationalStatus.pending => StatusChipTone.pending,
      AppointmentOperationalStatus.confirmed => StatusChipTone.success,
      AppointmentOperationalStatus.checkedIn => StatusChipTone.verified,
      AppointmentOperationalStatus.inQueue => StatusChipTone.queue,
      AppointmentOperationalStatus.completed => StatusChipTone.neutral,
      AppointmentOperationalStatus.cancelled => StatusChipTone.emergency,
      AppointmentOperationalStatus.noShow => StatusChipTone.warning,
      AppointmentOperationalStatus.rescheduled => StatusChipTone.warning,
    };
  }

  static IconData? _appointmentIcon(AppointmentOperationalStatus status) {
    return switch (status) {
      AppointmentOperationalStatus.inQueue => Icons.hourglass_top_outlined,
      AppointmentOperationalStatus.cancelled => Icons.cancel_outlined,
      _ => null,
    };
  }

  static String _claimLabel(ClaimOperationalStatus status) {
    return switch (status) {
      ClaimOperationalStatus.unclaimed => 'Unclaimed',
      ClaimOperationalStatus.claimPending => 'Claim Pending',
      ClaimOperationalStatus.verifiedFacility => 'Verified Facility',
      ClaimOperationalStatus.verifiedPractitioner => 'Verified Practitioner',
    };
  }

  static StatusChipTone _claimTone(ClaimOperationalStatus status) {
    return switch (status) {
      ClaimOperationalStatus.unclaimed => StatusChipTone.neutral,
      ClaimOperationalStatus.claimPending => StatusChipTone.pending,
      ClaimOperationalStatus.verifiedFacility => StatusChipTone.verified,
      ClaimOperationalStatus.verifiedPractitioner => StatusChipTone.verified,
    };
  }

  static IconData? _claimIcon(ClaimOperationalStatus status) {
    return switch (status) {
      ClaimOperationalStatus.verifiedFacility ||
      ClaimOperationalStatus.verifiedPractitioner =>
        Icons.verified_outlined,
      ClaimOperationalStatus.claimPending => Icons.pending_actions_outlined,
      ClaimOperationalStatus.unclaimed => null,
    };
  }
}
