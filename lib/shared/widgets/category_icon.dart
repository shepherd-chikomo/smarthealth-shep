import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';

/// Renders a bundled category SVG with optional tint.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.assetPath,
    this.size = 18,
    this.color = HomeDashboardColors.primary,
  });

  final String assetPath;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
