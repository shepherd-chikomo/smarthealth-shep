import type {
  CityRecord,
  DedupConfidence,
  FacilityRecord,
  NormalizedFacility,
  NormalizedProvider,
} from './types.js';
import { combinedSimilarity } from './deduplicate.js';
import { collapseWhitespace } from './normalize_data.js';

export interface FacilityMatchResult {
  facility: NormalizedFacility | null;
  facilityId: string | null;
  confidence: DedupConfidence;
  score: number;
  reason: string;
}

function normalize(value: string | null | undefined): string {
  return collapseWhitespace(String(value ?? '')).toLowerCase();
}

export function matchProviderToFacility(
  provider: NormalizedProvider,
  facilities: NormalizedFacility[],
  existingFacilities: FacilityRecord[] = [],
): FacilityMatchResult {
  if (!provider.facilityName && !provider.address) {
    return {
      facility: null,
      facilityId: null,
      confidence: 'LOW',
      score: 0,
      reason: 'no_facility_reference',
    };
  }

  const providerName = normalize(provider.facilityName);
  const providerCity = normalize(provider.city);
  const providerAddress = normalize(provider.address);
  const providerPhone = normalize(provider.phone);

  let best: FacilityMatchResult = {
    facility: null,
    facilityId: null,
    confidence: 'LOW',
    score: 0,
    reason: 'no_match',
  };

  for (const facility of facilities) {
    const nameScore = providerName
      ? combinedSimilarity(providerName, normalize(facility.name))
      : 0;
    const cityScore = providerCity && facility.city
      ? combinedSimilarity(providerCity, normalize(facility.city))
      : 0.5;
    const addressScore = providerAddress && facility.address
      ? combinedSimilarity(providerAddress, normalize(facility.address))
      : 0;
    const phoneScore = providerPhone && facility.phone && providerPhone === normalize(facility.phone)
      ? 1
      : 0;

    const score = nameScore * 0.45 + cityScore * 0.2 + addressScore * 0.25 + phoneScore * 0.1;

    if (score > best.score) {
      best = {
        facility,
        facilityId: null,
        confidence: score >= 0.92 ? 'HIGH' : score >= 0.78 ? 'MEDIUM' : 'LOW',
        score,
        reason: `name=${nameScore.toFixed(2)} city=${cityScore.toFixed(2)} address=${addressScore.toFixed(2)} phone=${phoneScore.toFixed(2)}`,
      };
    }
  }

  for (const existing of existingFacilities) {
    const nameScore = providerName
      ? combinedSimilarity(providerName, normalize(existing.name))
      : 0;
    const cityScore = providerCity
      ? combinedSimilarity(providerCity, normalize(existing.city))
      : 0.5;
    const score = nameScore * 0.7 + cityScore * 0.3;

    if (score > best.score && score >= 0.78) {
      best = {
        facility: null,
        facilityId: existing.id,
        confidence: score >= 0.92 ? 'HIGH' : 'MEDIUM',
        score,
        reason: `existing_facility name=${nameScore.toFixed(2)} city=${cityScore.toFixed(2)}`,
      };
    }
  }

  return best;
}

export function extractFacilitiesFromProviders(
  providers: NormalizedProvider[],
): NormalizedFacility[] {
  const facilityMap = new Map<string, NormalizedFacility>();

  for (const provider of providers) {
    const name = provider.facilityName ?? `${provider.name.fullName} — Independent Practice`;
    const key = `${normalize(name)}|${normalize(provider.city)}|${normalize(provider.address)}`;

    if (!facilityMap.has(key)) {
      facilityMap.set(key, {
        key,
        name,
        slug: '',
        facilityType: inferTypeFromProvider(provider),
        address: provider.address,
        province: provider.province,
        city: provider.city,
        phone: provider.phone,
        email: provider.email,
        facilityCategory: provider.facilityCategory,
        ownershipType: provider.ownershipType,
        latitude: provider.latitude,
        longitude: provider.longitude,
        formattedAddress: null,
        searchKeywords: [],
        sourceRows: [provider.rowNumber],
      });
    } else {
      facilityMap.get(key)!.sourceRows.push(provider.rowNumber);
    }
  }

  return [...facilityMap.values()];
}

function inferTypeFromProvider(provider: NormalizedProvider): string {
  const combined = `${provider.facilityCategory ?? ''} ${provider.practiceType ?? ''} ${provider.specialtyNormalized ?? ''}`.toLowerCase();
  if (combined.includes('hospital')) return 'hospital';
  if (combined.includes('pharmacy')) return 'pharmacy';
  if (combined.includes('lab')) return 'laboratory';
  if (combined.includes('dental')) return 'dental';
  return 'clinic';
}

export function resolveCityId(
  cityName: string | null,
  province: string | null,
  cities: CityRecord[],
): { cityId: string | null; missing: boolean } {
  if (!cityName) return { cityId: null, missing: true };

  const normalized = normalize(cityName);
  const match = cities.find(
    (c) => normalize(c.name) === normalized &&
      (!province || !c.province || normalize(c.province) === normalize(province)),
  );

  if (match) return { cityId: match.id, missing: false };

  const fuzzy = cities.find((c) => combinedSimilarity(normalize(c.name), normalized) >= 0.9);
  if (fuzzy) return { cityId: fuzzy.id, missing: false };

  return { cityId: null, missing: true };
}

export function buildProviderFacilityLinks(
  providerId: string,
  primaryFacilityId: string,
  additionalFacilityIds: string[],
  confidence: DedupConfidence,
  batchId: string,
): Array<{
  providerId: string;
  facilityId: string;
  isPrimary: boolean;
  confidence: DedupConfidence;
  batchId: string;
}> {
  const links = [{
    providerId,
    facilityId: primaryFacilityId,
    isPrimary: true,
    confidence,
    batchId,
  }];

  for (const facilityId of additionalFacilityIds) {
    if (facilityId !== primaryFacilityId) {
      links.push({
        providerId,
        facilityId,
        isPrimary: false,
        confidence: 'MEDIUM' as DedupConfidence,
        batchId,
      });
    }
  }

  return links;
}
