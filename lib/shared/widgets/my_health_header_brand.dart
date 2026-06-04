import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/shared/widgets/my_health_header_logo.dart';

/// Header brand: extracted cross mark left of MyHealth wordmark.
class MyHealthHeaderBrand extends StatelessWidget {
  const MyHealthHeaderBrand({
    super.key,
    required this.wordmarkWidth,
    this.showPoweredBy = true,
    this.poweredByText,
  });

  final double wordmarkWidth;
  final bool showPoweredBy;
  final String? poweredByText;

  @override
  Widget build(BuildContext context) {
    final markSize = (wordmarkWidth * 0.26).clamp(40.0, 56.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: markSize,
              height: markSize,
              child: Image.asset(
                AppAssets.headerCrossLogo,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            SizedBox(width: markSize * 0.18),
            MyHealthHeaderLogo(width: wordmarkWidth),
          ],
        ),
        if (showPoweredBy) ...[
          const SizedBox(height: 4),
          Text(
            poweredByText ?? 'Powered by SmartHealth',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
