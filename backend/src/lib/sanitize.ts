const HTML_ESCAPE_MAP: Record<string, string> = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#x27;',
  '/': '&#x2F;',
};

export function escapeHtml(input: string): string {
  return input.replace(/[&<>"'/]/g, (char) => HTML_ESCAPE_MAP[char] ?? char);
}

export function stripHtmlTags(input: string): string {
  return input.replace(/<[^>]*>/g, '');
}

export function sanitizeUserInput(input: string, maxLength = 10_000): string {
  const trimmed = input.trim().slice(0, maxLength);
  return escapeHtml(stripHtmlTags(trimmed));
}

export function sanitizeObjectStrings<T extends Record<string, unknown>>(
  obj: T,
  keys: (keyof T)[],
): T {
  const result = { ...obj };
  for (const key of keys) {
    const value = result[key];
    if (typeof value === 'string') {
      result[key] = sanitizeUserInput(value) as T[keyof T];
    }
  }
  return result;
}
