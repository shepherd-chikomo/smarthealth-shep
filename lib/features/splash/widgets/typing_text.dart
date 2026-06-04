import 'package:flutter/material.dart';

/// Reveals [text] character-by-character for a typewriter effect.
class TypingText extends StatelessWidget {
  const TypingText({
    super.key,
    required this.text,
    required this.style,
    required this.visibleCharCount,
    this.textAlign = TextAlign.center,
    this.showCursor = false,
  });

  final String text;
  final TextStyle style;
  final int visibleCharCount;
  final TextAlign textAlign;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    final count = visibleCharCount.clamp(0, text.length);
    final visible = text.substring(0, count);
    final typing = showCursor && count < text.length;

    return RepaintBoundary(
      child: Text.rich(
        textAlign: textAlign,
        TextSpan(
          style: style,
          children: [
            TextSpan(text: visible),
            if (typing)
              TextSpan(
                text: '|',
                style: style.copyWith(
                  color: style.color?.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w300,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
