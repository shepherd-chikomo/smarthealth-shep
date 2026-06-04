import levenshtein from 'fast-levenshtein';
import type {
  DedupConfidence,
  DedupMatch,
  FacilityRecord,
  NormalizedFacility,
  NormalizedProvider,
  ProviderRecord,
} from './types.js';
import { buildFacilityKey, collapseWhitespace } from './normalize_data.js';

function normalizeForMatch(value: string | null | undefined): string {
  return collapseWhitespace(String(value ?? '')).toLowerCase();
}

function similarity(a: string, b: string): number {
  if (!a || !b) return 0;
  if (a === b) return 1;
  const maxLen = Math.max(a.length, b.length);
  if (maxLen === 0) return 1;
  const distance = levenshtein.get(a, b);
  return 1 - distance / maxLen;
}

function trigramSimilarity(a: string, b: string): number {
  if (a === b) return 1;
  if (a.length < 2 || b.length < 2) return similarity(a, b);

  const trigrams = (s: string): Set<string> => {
    const set = new Set<string>();
    const padded = `  ${s} `;
    for (let i = 0; i < padded.length - 2; i++) {
      set.add(padded.slice(i, i + 3));
    }
    return set;
  };

  const ta = trigrams(a);
  const tb = trigrams(b);
  let intersection = 0;
  for (const t of ta) {
    if (tb.has(t)) intersection++;
  }
  return (2 * intersection) / (ta.size + tb.size);
}

function combinedSimilarity(a: string, b: string): number {
  return Math.max(similarity(a, b), trigramSimilarity(a, b));
}

function scoreToConfidence(score: number): DedupConfidence {
  if (score >= 0.92) return 'HIGH';
  if (score >= 0.78) return 'MEDIUM';
  return 'LOW';
}

export function deduplicateFacilities(
  facilities: NormalizedFacility[],
  existing: FacilityRecord[] = [],
): {
  unique: NormalizedFacility[];
  merges: DedupMatch<NormalizedFacility>[];
} {
  const unique: NormalizedFacility[] = [];
  const merges: DedupMatch<NormalizedFacility>[] = [];

  const byKey = new Map<string, NormalizedFacility>();
  const blocks = new Map<string, NormalizedFacility[]>();

  function blockKeys(nameNorm: string, cityNorm: string, phoneNorm: string): string[] {
    const keys = new Set<string>();
    if (phoneNorm) keys.add(`phone:${phoneNorm}`);
    keys.add(`name:${nameNorm.slice(0, 4)}:${cityNorm.slice(0, 4)}`);
    return [...keys];
  }

  function indexFacility(
    facility: NormalizedFacility,
    nameNorm: string,
    cityNorm: string,
    phoneNorm: string,
  ): void {
    unique.push(facility);
    byKey.set(facility.key, facility);
    for (const key of blockKeys(nameNorm, cityNorm, phoneNorm)) {
      const bucket = blocks.get(key) ?? [];
      bucket.push(facility);
      blocks.set(key, bucket);
    }
  }

  function candidateFacilities(nameNorm: string, cityNorm: string, phoneNorm: string): NormalizedFacility[] {
    const seen = new Set<NormalizedFacility>();
    const candidates: NormalizedFacility[] = [];
    const add = (facility: NormalizedFacility) => {
      if (seen.has(facility)) return;
      seen.add(facility);
      candidates.push(facility);
    };

    for (const key of blockKeys(nameNorm, cityNorm, phoneNorm)) {
      for (const facility of blocks.get(key) ?? []) {
        add(facility);
      }
    }

    return candidates;
  }

  function scoreFacilityMatch(
    _facility: NormalizedFacility,
    candidate: NormalizedFacility,
    nameNorm: string,
    cityNorm: string,
    addressNorm: string,
    phoneNorm: string,
  ): number {
    const nameScore = combinedSimilarity(nameNorm, normalizeForMatch(candidate.name));
    const cityScore = cityNorm && candidate.city
      ? combinedSimilarity(cityNorm, normalizeForMatch(candidate.city))
      : 0.5;
    const addressScore = addressNorm && candidate.address
      ? combinedSimilarity(addressNorm, normalizeForMatch(candidate.address))
      : 0;
    const phoneScore = phoneNorm && candidate.phone && phoneNorm === normalizeForMatch(candidate.phone)
      ? 1
      : 0;

    return nameScore * 0.5 + cityScore * 0.2 + addressScore * 0.2 + phoneScore * 0.1;
  }

  for (const facility of facilities) {
    const nameNorm = normalizeForMatch(facility.name);
    const cityNorm = normalizeForMatch(facility.city);
    const addressNorm = normalizeForMatch(facility.address);
    const phoneNorm = normalizeForMatch(facility.phone);

    let bestMatch: DedupMatch<NormalizedFacility> | null = null;

    const exact = byKey.get(facility.key);
    if (exact) {
      bestMatch = {
        source: facility,
        target: exact,
        confidence: 'HIGH',
        score: 1,
        reason: 'facility_key_exact',
      };
    } else {
      for (const candidate of candidateFacilities(nameNorm, cityNorm, phoneNorm)) {
        const score = scoreFacilityMatch(facility, candidate, nameNorm, cityNorm, addressNorm, phoneNorm);
        if (score >= 0.78 && (!bestMatch || score > bestMatch.score)) {
          bestMatch = {
            source: facility,
            target: candidate,
            confidence: scoreToConfidence(score),
            score,
            reason: `name=${score.toFixed(2)}`,
          };
        }
      }
    }

    for (const existingFac of existing) {
      const nameScore = combinedSimilarity(nameNorm, normalizeForMatch(existingFac.name));
      const cityScore = cityNorm
        ? combinedSimilarity(cityNorm, normalizeForMatch(existingFac.city))
        : 0.5;
      const score = nameScore * 0.7 + cityScore * 0.3;
      if (score >= 0.85 && (!bestMatch || score > bestMatch.score)) {
        bestMatch = {
          source: facility,
          target: {
            ...facility,
            key: buildFacilityKey(existingFac.name, existingFac.city, existingFac.address_line1),
            name: existingFac.name,
            slug: existingFac.slug,
          },
          confidence: scoreToConfidence(score),
          score,
          reason: `existing facility match name=${nameScore.toFixed(2)}`,
        };
      }
    }

    if (bestMatch && bestMatch.confidence === 'HIGH') {
      bestMatch.target.sourceRows.push(...facility.sourceRows);
      if (!bestMatch.target.phone && facility.phone) bestMatch.target.phone = facility.phone;
      if (!bestMatch.target.address && facility.address) bestMatch.target.address = facility.address;
      merges.push(bestMatch);
    } else {
      if (bestMatch) merges.push(bestMatch);
      indexFacility(facility, nameNorm, cityNorm, phoneNorm);
    }
  }

  return { unique, merges };
}

export function deduplicateProviders(
  providers: NormalizedProvider[],
  existing: ProviderRecord[] = [],
): {
  unique: NormalizedProvider[];
  merges: DedupMatch<NormalizedProvider>[];
  reviews: DedupMatch<NormalizedProvider>[];
} {
  const unique: NormalizedProvider[] = [];
  const merges: DedupMatch<NormalizedProvider>[] = [];
  const reviews: DedupMatch<NormalizedProvider>[] = [];

  const byReg = new Map<string, NormalizedProvider>();
  const byPhone = new Map<string, NormalizedProvider>();
  const blocks = new Map<string, NormalizedProvider[]>();

  const existingByReg = new Map<string, ProviderRecord>();
  for (const existingProv of existing) {
    const reg = normalizeForMatch(existingProv.registration_number ?? existingProv.mdpcz_number);
    if (reg) existingByReg.set(reg, existingProv);
  }

  function blockKeys(nameNorm: string, specialtyNorm: string, phoneNorm: string): string[] {
    const keys = new Set<string>();
    if (phoneNorm) keys.add(`phone:${phoneNorm}`);
    keys.add(`name:${nameNorm.slice(0, 4)}:${specialtyNorm.slice(0, 4)}`);
    const lastToken = nameNorm.split(' ').pop() ?? nameNorm.slice(0, 4);
    keys.add(`last:${lastToken}:${specialtyNorm.slice(0, 4)}`);
    return [...keys];
  }

  function indexProvider(
    provider: NormalizedProvider,
    nameNorm: string,
    specialtyNorm: string,
    regNorm: string,
    phoneNorm: string,
  ): void {
    unique.push(provider);
    if (regNorm) byReg.set(regNorm, provider);
    if (phoneNorm) byPhone.set(phoneNorm, provider);
    for (const key of blockKeys(nameNorm, specialtyNorm, phoneNorm)) {
      const bucket = blocks.get(key) ?? [];
      bucket.push(provider);
      blocks.set(key, bucket);
    }
  }

  function candidateProviders(
    nameNorm: string,
    specialtyNorm: string,
    phoneNorm: string,
  ): NormalizedProvider[] {
    const seen = new Set<NormalizedProvider>();
    const candidates: NormalizedProvider[] = [];
    const add = (provider: NormalizedProvider) => {
      if (seen.has(provider)) return;
      seen.add(provider);
      candidates.push(provider);
    };

    for (const key of blockKeys(nameNorm, specialtyNorm, phoneNorm)) {
      for (const provider of blocks.get(key) ?? []) {
        add(provider);
      }
    }

    return candidates;
  }

  function scoreProviderMatch(
    _provider: NormalizedProvider,
    candidate: NormalizedProvider,
    regNorm: string,
    phoneNorm: string,
    nameNorm: string,
    specialtyNorm: string,
    facilityNorm: string,
  ): { score: number; reason: string } {
    const candReg = normalizeForMatch(candidate.registrationNumber ?? candidate.mdpczNumber);
    if (regNorm && candReg && regNorm === candReg) {
      return { score: 1, reason: 'registration_number_exact' };
    }

    const phoneScore =
      phoneNorm && candidate.phone && phoneNorm === normalizeForMatch(candidate.phone) ? 1 : 0;
    const nameScore = combinedSimilarity(nameNorm, normalizeForMatch(candidate.name.fullName));
    const specScore =
      specialtyNorm && candidate.specialtyNormalized
        ? combinedSimilarity(specialtyNorm, normalizeForMatch(candidate.specialtyNormalized))
        : 0.5;
    const facScore =
      facilityNorm && candidate.facilityName
        ? combinedSimilarity(facilityNorm, normalizeForMatch(candidate.facilityName))
        : 0.3;

    return {
      score: phoneScore * 0.35 + nameScore * 0.35 + specScore * 0.15 + facScore * 0.15,
      reason: `phone=${phoneScore} name=${nameScore.toFixed(2)} specialty=${specScore.toFixed(2)} facility=${facScore.toFixed(2)}`,
    };
  }

  for (const provider of providers) {
    let bestMatch: DedupMatch<NormalizedProvider> | null = null;

    const regNorm = normalizeForMatch(provider.registrationNumber ?? provider.mdpczNumber);
    const phoneNorm = normalizeForMatch(provider.phone);
    const nameNorm = normalizeForMatch(provider.name.fullName);
    const specialtyNorm = normalizeForMatch(provider.specialtyNormalized);
    const facilityNorm = normalizeForMatch(provider.facilityName);

    if (regNorm && existingByReg.has(regNorm)) {
      bestMatch = {
        source: provider,
        target: provider,
        confidence: 'HIGH',
        score: 1,
        reason: 'existing_registration_number',
      };
    } else if (regNorm && byReg.has(regNorm)) {
      bestMatch = {
        source: provider,
        target: byReg.get(regNorm)!,
        confidence: 'HIGH',
        score: 1,
        reason: 'registration_number_exact',
      };
    } else {
      for (const candidate of candidateProviders(nameNorm, specialtyNorm, phoneNorm)) {
        const { score, reason } = scoreProviderMatch(
          provider,
          candidate,
          regNorm,
          phoneNorm,
          nameNorm,
          specialtyNorm,
          facilityNorm,
        );

        if (score >= 0.75 && (!bestMatch || score > bestMatch.score)) {
          bestMatch = {
            source: provider,
            target: candidate,
            confidence: scoreToConfidence(score),
            score,
            reason,
          };
        }
      }
    }

    if (bestMatch?.confidence === 'HIGH') {
      merges.push(bestMatch);
    } else if (bestMatch) {
      reviews.push(bestMatch);
      indexProvider(provider, nameNorm, specialtyNorm, regNorm, phoneNorm);
    } else {
      indexProvider(provider, nameNorm, specialtyNorm, regNorm, phoneNorm);
    }
  }

  return { unique, merges, reviews };
}

export { combinedSimilarity, scoreToConfidence };
