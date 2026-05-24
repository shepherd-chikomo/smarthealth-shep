/**
 * Builds PostgreSQL text-search and trigram match conditions.
 */

export interface TextMatchParams {
  query?: string;
  /** Parameter index for the raw query string */
  queryParamIdx: number;
  providerVectorCol?: string;
  facilityVectorCol?: string;
  providerNameCol?: string;
  providerSpecialtyCol?: string;
  facilityNameCol?: string;
  facilityCityCol?: string;
}

/**
 * Returns SQL condition using DB function search_text_matches for typo tolerance.
 */
export function buildTextMatchCondition(opts: TextMatchParams): string {
  if (!opts.query) return 'TRUE';

  const pv = opts.providerVectorCol ?? 'p.search_vector';
  const fv = opts.facilityVectorCol ?? 'f.search_vector';
  const pn = opts.providerNameCol ?? 'p.name';
  const ps = opts.providerSpecialtyCol ?? 'p.specialty';
  const fn = opts.facilityNameCol ?? 'f.name';
  const fc = opts.facilityCityCol ?? 'f.city';

  return `public.search_text_matches($${opts.queryParamIdx}, ${pv}, ${fv}, ${pn}, ${ps}, ${fn}, ${fc})`;
}

export function normalizeSearchQuery(q?: string): string | undefined {
  if (!q) return undefined;
  const trimmed = q.trim().replace(/\s+/g, ' ');
  return trimmed.length > 0 ? trimmed.slice(0, 200) : undefined;
}

/**
 * Simple client-side typo similarity (Levenshtein ratio approximation) for tests.
 */
export function trigramSimilarity(a: string, b: string): number {
  const sa = a.toLowerCase().trim();
  const sb = b.toLowerCase().trim();
  if (sa === sb) return 1;
  if (!sa || !sb) return 0;

  if (sa.includes(sb) || sb.includes(sa)) return 0.8;

  const maxLen = Math.max(sa.length, sb.length);
  let matches = 0;
  const shorter = sa.length <= sb.length ? sa : sb;
  const longer = sa.length <= sb.length ? sb : sa;
  for (let i = 0; i < shorter.length; i++) {
    if (longer.includes(shorter[i]!)) matches++;
  }
  return matches / maxLen;
}

export function matchesTypoTolerant(haystack: string, query: string, threshold = 0.25): boolean {
  const h = haystack.toLowerCase();
  const q = query.toLowerCase().trim();
  if (!q) return true;
  if (h.includes(q)) return true;
  return trigramSimilarity(h, q) >= threshold;
}
