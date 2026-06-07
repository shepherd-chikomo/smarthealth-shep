/// Reverses over-escaped text from API sanitization for safe UI display.
String decodeStoredText(String? raw) {
  if (raw == null || raw.isEmpty) return raw ?? '';

  var text = raw;
  for (var pass = 0; pass < 4; pass++) {
    final next = text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&#x2F;', '/')
        .replaceAll('&#47;', '/');
    if (next == text) break;
    text = next;
  }
  return text.trim();
}
