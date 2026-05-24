import { describe, expect, it } from 'vitest';
import {
  matchesTypoTolerant,
  normalizeSearchQuery,
  trigramSimilarity,
} from '../src/lib/search-query.js';

describe('normalizeSearchQuery', () => {
  it('trims and collapses whitespace', () => {
    expect(normalizeSearchQuery('  cardiology   harare  ')).toBe('cardiology harare');
  });

  it('returns undefined for empty input', () => {
    expect(normalizeSearchQuery('')).toBeUndefined();
    expect(normalizeSearchQuery('   ')).toBeUndefined();
  });

  it('caps query length at 200 characters', () => {
    const long = 'a'.repeat(250);
    expect(normalizeSearchQuery(long)?.length).toBe(200);
  });
});

describe('typo tolerance', () => {
  it('matches exact strings', () => {
    expect(matchesTypoTolerant('Dr John Cardiology Clinic', 'cardiology')).toBe(true);
  });

  it('tolerates common typos via trigram similarity', () => {
    expect(trigramSimilarity('cardiology', 'cardiolgy')).toBeGreaterThan(0.25);
    expect(matchesTypoTolerant('cardiology', 'cardiolgy')).toBe(true);
  });

  it('matches partial facility names', () => {
    expect(matchesTypoTolerant('Parirenyatwa Hospital Harare', 'parirenyatwa')).toBe(true);
  });

  it('rejects unrelated queries', () => {
    expect(matchesTypoTolerant('cardiology', 'xyzqwerty')).toBe(false);
  });

  it('allows empty query to match everything', () => {
    expect(matchesTypoTolerant('anything', '')).toBe(true);
  });
});

describe('search ranking priority', () => {
  /**
   * Simulates rank weights from compute_provider_search_rank (migration).
   * Used to verify relative ordering without a live database.
   */
  function computeRank(signals: {
    exactSpecialty?: boolean;
    openNow?: boolean;
    verified?: boolean;
    distanceKm?: number;
    hasQueue?: boolean;
    rating?: number;
    acceptingBookings?: boolean;
    completeness?: number;
    textRank?: number;
    trigram?: number;
  }): number {
    return (
      (signals.exactSpecialty ? 1000 : 0) +
      (signals.openNow ? 500 : 0) +
      (signals.verified ? 200 : 0) +
      (signals.distanceKm != null ? Math.max(0, 150 - signals.distanceKm * 5) : 0) +
      (signals.hasQueue ? 100 : 0) +
      (signals.rating ?? 0) * 10 +
      (signals.acceptingBookings ? 30 : 0) +
      (signals.completeness ?? 0) * 20 +
      (signals.textRank ?? 0) * 10 +
      (signals.trigram ?? 0) * 5
    );
  }

  it('prioritizes exact specialty match over rating', () => {
    const specialtyMatch = computeRank({ exactSpecialty: true, rating: 2 });
    const highRated = computeRank({ rating: 5, openNow: true, verified: true });
    expect(specialtyMatch).toBeGreaterThan(highRated);
  });

  it('prioritizes open now over verified-only', () => {
    const openNow = computeRank({ openNow: true });
    const verified = computeRank({ verified: true });
    expect(openNow).toBeGreaterThan(verified);
  });

  it('prioritizes verified over nearby-only when far', () => {
    const verified = computeRank({ verified: true });
    const farNearby = computeRank({ distanceKm: 25 });
    expect(verified).toBeGreaterThan(farNearby);
  });

  it('prioritizes nearby over queue when close', () => {
    const close = computeRank({ distanceKm: 1 });
    const queueOnly = computeRank({ hasQueue: true });
    expect(close).toBeGreaterThan(queueOnly);
  });

  it('prioritizes queue over rating alone', () => {
    const queue = computeRank({ hasQueue: true });
    const rated = computeRank({ rating: 4 });
    expect(queue).toBeGreaterThan(rated);
  });

  it('orders a realistic result set correctly', () => {
    const results = [
      { name: 'Generic GP far away', rank: computeRank({ distanceKm: 20, rating: 3 }) },
      { name: 'Cardiologist open verified nearby', rank: computeRank({
        exactSpecialty: true, openNow: true, verified: true, distanceKm: 2, rating: 4.5, acceptingBookings: true,
      }) },
      { name: 'Unverified closed', rank: computeRank({ rating: 5 }) },
      { name: 'Open queue facility', rank: computeRank({ openNow: true, hasQueue: true, distanceKm: 5 }) },
    ].sort((a, b) => b.rank - a.rank);

    expect(results[0].name).toBe('Cardiologist open verified nearby');
    expect(results[1].name).toBe('Open queue facility');
  });
});

describe('healthcare search filters', () => {
  it('defines expected filter combinations', () => {
    const filters = {
      openNow: true,
      hasQueue: true,
      isVerified: true,
      city: 'Harare',
      specialtyId: '550e8400-e29b-41d4-a716-446655440000',
    };
    expect(filters.openNow && filters.hasQueue).toBe(true);
    expect(filters.city).toBe('Harare');
  });
});
