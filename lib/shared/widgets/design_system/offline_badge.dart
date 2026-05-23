import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/design_system_tokens.dart';

/// Compact offline indicator: "Offline • Updated X ago".
class OfflineBadge extends StatelessWidget {
  const OfflineBadge({
    super.key,
    required this.isOffline,
    this.lastUpdated,
  });

  final bool isOffline;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    final updatedLabel = _formatUpdatedAgo(lastUpdated);

    return Semantics(
      label: 'Offline. $updatedLabel',
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: DesignSystemColors.warning.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(DesignSystemMetrics.radiusMd),
          border: Border.all(
            color: DesignSystemColors.warning.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.cloud_off,
              size: 16,
              color: DesignSystemColors.textPrimary.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Offline • $updatedLabel',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DesignSystemColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatUpdatedAgo(DateTime? timestamp) {
    if (timestamp == null) return 'cache available';

    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Updated just now';
    if (diff.inMinutes < 60) {
      return 'Updated ${diff.inMinutes} min ago';
    }
    if (diff.inHours < 24) {
      return 'Updated ${diff.inHours} hr ago';
    }
    return 'Updated ${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
}
