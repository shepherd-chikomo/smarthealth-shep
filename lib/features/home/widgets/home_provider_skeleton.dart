import 'package:flutter/material.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';

class HomeProviderSkeleton extends StatefulWidget {
  const HomeProviderSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  State<HomeProviderSkeleton> createState() => _HomeProviderSkeletonState();
}

class _HomeProviderSkeletonState extends State<HomeProviderSkeleton>
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
      builder: (context, child) {
        final opacity = 0.45 + (_controller.value * 0.35);
        return Column(
          children: List.generate(
            widget.itemCount,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SkeletonCard(opacity: opacity),
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    Color block(double alpha) =>
        HomeDashboardColors.skeleton.withValues(alpha: alpha * opacity);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HomeDashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E8EE)),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: block(1),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: block(1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: block(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 180,
                  decoration: BoxDecoration(
                    color: block(0.7),
                    borderRadius: BorderRadius.circular(4),
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
