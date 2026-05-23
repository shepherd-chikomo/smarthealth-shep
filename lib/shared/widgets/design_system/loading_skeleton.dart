import 'package:flutter/material.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/design_system_tokens.dart';

enum LoadingSkeletonVariant { list, card, lines }

/// Shimmer placeholder for lists and cards while content loads.
class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({
    super.key,
    this.variant = LoadingSkeletonVariant.list,
    this.itemCount = 3,
    this.lineCount = 3,
    this.height,
    this.borderRadius,
  });

  final LoadingSkeletonVariant variant;
  final int itemCount;
  final int lineCount;
  final double? height;
  final double? borderRadius;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      builder: (context, _) {
        final shimmer = 0.45 + (_controller.value * 0.35);
        return switch (widget.variant) {
          LoadingSkeletonVariant.list => Column(
              children: List.generate(
                widget.itemCount,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SkeletonListTile(shimmer: shimmer),
                ),
              ),
            ),
          LoadingSkeletonVariant.card => _SkeletonCard(
              shimmer: shimmer,
              height: widget.height ?? 120,
              borderRadius: widget.borderRadius,
            ),
          LoadingSkeletonVariant.lines => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                widget.lineCount,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SkeletonBox(
                    shimmer: shimmer,
                    height: 12,
                    widthFactor: index == widget.lineCount - 1 ? 0.6 : 1,
                  ),
                ),
              ),
            ),
        };
      },
    );
  }
}

class _SkeletonListTile extends StatelessWidget {
  const _SkeletonListTile({required this.shimmer});

  final double shimmer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignSystemColors.surface,
        borderRadius: BorderRadius.circular(DesignSystemMetrics.radiusMd),
        border: Border.all(color: DesignSystemColors.border),
      ),
      child: Row(
        children: [
          _SkeletonBox(shimmer: shimmer, width: 56, height: 56, radius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(shimmer: shimmer, height: 14, widthFactor: 1),
                const SizedBox(height: 8),
                _SkeletonBox(shimmer: shimmer, height: 12, widthFactor: 0.55),
                const SizedBox(height: 8),
                _SkeletonBox(shimmer: shimmer, height: 12, widthFactor: 0.75),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({
    required this.shimmer,
    required this.height,
    this.borderRadius,
  });

  final double shimmer;
  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return _SkeletonBox(
      shimmer: shimmer,
      height: height,
      widthFactor: 1,
      radius: borderRadius ?? DesignSystemMetrics.radiusMd,
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.shimmer,
    this.width,
    this.height = 12,
    this.widthFactor = 1,
    this.radius = 4,
  });

  final double shimmer;
  final double? width;
  final double height;
  final double widthFactor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = DesignSystemColors.skeletonBase.withValues(alpha: shimmer);

    return FractionallySizedBox(
      widthFactor: width == null ? widthFactor : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
