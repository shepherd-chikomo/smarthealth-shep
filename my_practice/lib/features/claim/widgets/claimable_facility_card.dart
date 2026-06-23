import 'package:flutter/material.dart';
import 'package:my_practice/domain/models/portal_profile.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

/// Card for a registry-linked facility on the claim / picker screens.
class ClaimableFacilityCard extends StatelessWidget {
  const ClaimableFacilityCard({
    super.key,
    required this.facility,
    required this.claiming,
    required this.onClaim,
    required this.onOpenOwned,
  });

  final LinkedFacility facility;
  final bool claiming;
  final VoidCallback onClaim;
  final VoidCallback onOpenOwned;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppTheme.themedCard(
        context: context,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                facility.name,
                style: AppTextStyles.base(fontWeight: AppTextStyles.bold),
              ),
              if (facility.city != null)
                Text(
                  facility.city!,
                  style: AppTextStyles.sm(
                    color: context.appColors.mutedForeground,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                facility.statusLabel,
                style: AppTextStyles.xs(
                  color: context.appColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              if (facility.isOwnedByMe)
                FilledButton(
                  onPressed: claiming ? null : onOpenOwned,
                  child: const Text('Open facility'),
                )
              else if (facility.canClaimOwnership)
                FilledButton(
                  onPressed: claiming ? null : onClaim,
                  child: claiming
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Claim ownership'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
