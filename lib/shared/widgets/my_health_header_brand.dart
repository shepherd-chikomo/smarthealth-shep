import 'package:flutter/material.dart';
import 'package:smarthealth_shep/shared/widgets/my_health_header_logo.dart';

/// Header brand: centred MyHealth wordmark with optional powered-by line.
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyHealthHeaderLogo(width: wordmarkWidth),
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
