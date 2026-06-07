import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/profile/utils/profile_completion_calculator.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';

class ProfileCompletionWidget extends StatelessWidget {
  const ProfileCompletionWidget({
    super.key,
    required this.completion,
    this.compact = false,
  });

  final ProfileCompletionResult completion;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bandColor = completionBandColor(completion.band, context);
    final isComplete = completion.band == ProfileCompletionBand.complete;

    return Semantics(
      button: true,
      label: '${l10n.homeProfileComplete} ${completion.percentage}%',
      child: Material(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(compact ? 12 : 14),
        child: InkWell(
          onTap: () => context.go('/profile/completion'),
          borderRadius: BorderRadius.circular(compact ? 12 : 14),
          child: SizedBox(
            width: compact ? 96 : 132,
            height: compact ? 48 : null,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 10,
                vertical: compact ? 6 : 8,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: compact ? 34 : 40,
                    height: compact ? 34 : 40,
                    child: _ProgressRing(
                      percentage: completion.percentage,
                      bandColor: bandColor,
                      isComplete: isComplete,
                      compact: compact,
                    ),
                  ),
                  SizedBox(width: compact ? 6 : 8),
                  Expanded(
                    child: compact
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.homeProfileComplete,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                '${completion.percentage}%',
                                style: TextStyle(
                                  color: bandColor.withValues(alpha: 0.95),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.homeProfileComplete,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${completion.percentage}%',
                                style: TextStyle(
                                  color: bandColor.withValues(alpha: 0.95),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                l10n.homeProfileCompleteHint,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 9,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                  if (!compact)
                    Icon(
                      Symbols.chevron_right,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.percentage,
    required this.bandColor,
    required this.isComplete,
    required this.compact,
  });

  final int percentage;
  final Color bandColor;
  final bool isComplete;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: percentage / 100),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: value,
              strokeWidth: compact ? 3 : 3.5,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: bandColor,
            ),
            if (isComplete)
              Icon(
                Symbols.check_circle,
                size: compact ? 16 : 18,
                color: bandColor,
              )
            else
              Text(
                '$percentage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        );
      },
    );
  }
}
