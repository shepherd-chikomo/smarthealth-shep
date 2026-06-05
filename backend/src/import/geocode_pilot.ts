#!/usr/bin/env node
/**
 * Side-by-side Nominatim vs Google geocoding pilot (no DB writes by default).
 *
 * Usage:
 *   npm run geocode:pilot -- --limit 50 --city Harare
 *   npm run geocode:pilot -- --from-csv ../geocode-failures.csv --limit 500
 *   npm run geocode:pilot -- --import-source HPA --quality city_centre,city_only,missing
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { isTrustedGeocodeQuality } from '../lib/geocode-quality.js';
import { closePool, pool } from './db.js';
import { ensureGeocodeQualityColumns } from './ensure_geocode_quality.js';
import {
  createCityCentroidMap,
  geocodeFacilityInput,
  type FacilityAddressInput,
} from './geocode.js';
import {
  distanceBetweenResults,
  geocodeGoogleFacilityInput,
  getGoogleMapsApiKey,
} from './geocode-google.js';
import { logger } from './logger.js';
import { provinceForGeocodeQuery } from './province_resolve.js';
import type { GeocodeQuality, GeocodeResult } from './types.js';

interface PilotFacility {
  id: string;
  name: string;
  addressLine1: string | null;
  city: string;
  province: string;
}

interface PilotOptions {
  limit: number | null;
  city: string | null;
  importSource: string | null;
  fromCsv: string | null;
  qualityFilter: Set<string> | null;
  outputPath: string;
}

interface PilotRow {
  id: string;
  name: string;
  query: string;
  nominatim: GeocodeResult | null;
  google: GeocodeResult | null;
}

function parseArgs(): PilotOptions {
  const argv = process.argv.slice(2);

  let limit: number | null = null;
  let city: string | null = null;
  let importSource: string | null = null;
  let fromCsv: string | null = null;
  let qualityRaw: string | null = null;
  let outputPath = resolve(process.cwd(), 'pilot-results.csv');

  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--limit' && argv[i + 1]) {
      limit = Number.parseInt(argv[i + 1], 10);
      i++;
    } else if (argv[i] === '--city' && argv[i + 1]) {
      city = argv[i + 1];
      i++;
    } else if (argv[i] === '--import-source' && argv[i + 1]) {
      importSource = argv[i + 1];
      i++;
    } else if (argv[i] === '--from-csv' && argv[i + 1]) {
      fromCsv = resolve(argv[i + 1]);
      i++;
    } else if (argv[i] === '--quality' && argv[i + 1]) {
      qualityRaw = argv[i + 1];
      i++;
    } else if (argv[i] === '--output' && argv[i + 1]) {
      outputPath = resolve(argv[i + 1]);
      i++;
    }
  }

  if (!importSource && !fromCsv) {
    importSource = 'HPA';
  }

  const qualityFilter = qualityRaw
    ? new Set(qualityRaw.split(',').map((q) => q.trim().toLowerCase()))
    : null;

  return {
    limit: Number.isFinite(limit) && limit! > 0 ? limit : null,
    city,
    importSource,
    fromCsv,
    qualityFilter,
    outputPath,
  };
}

function buildQuery(facility: PilotFacility): string {
  const parts = [
    facility.addressLine1,
    facility.city,
    provinceForGeocodeQuery(facility.city, facility.province),
  ].filter(Boolean);
  return parts.join(', ');
}

function loadFacilitiesFromCsv(path: string, limit: number | null): PilotFacility[] {
  const text = readFileSync(path, 'utf8');
  const lines = text.split(/\r?\n/).filter((l) => l.trim().length > 0);
  const header = lines[0]?.toLowerCase() ?? '';
  const idIdx = header.includes('id') ? header.split(',').indexOf('id') : 0;
  const nameIdx = header.includes('name') ? header.split(',').indexOf('name') : 1;

  const rows: PilotFacility[] = [];
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i]!;
    const match = line.match(/^([^,]+),("(?:[^"]|"")*"|[^,]*),("(?:[^"]|"")*"|[^,]*),("(?:[^"]|"")*"|[^,]*),("(?:[^"]|"")*"|[^,]*)$/);
    if (!match) {
      const cols = line.split(',');
      const id = cols[0]?.trim();
      const name = (cols[1] ?? '').replace(/^"|"$/g, '').replace(/""/g, '"');
      const city = (cols[2] ?? 'Unknown').replace(/^"|"$/g, '').replace(/""/g, '"');
      const province = (cols[3] ?? 'Unknown').replace(/^"|"$/g, '').replace(/""/g, '"');
      const query = (cols[4] ?? '').replace(/^"|"$/g, '').replace(/""/g, '"');
      const addressLine1 = query.split(',')[0]?.trim() || null;
      if (id) {
        rows.push({ id, name, addressLine1, city, province });
      }
      continue;
    }

    const id = match[1]!.trim();
    const name = match[2]!.replace(/^"|"$/g, '').replace(/""/g, '"');
    const city = match[3]!.replace(/^"|"$/g, '').replace(/""/g, '"') || 'Unknown';
    const province = match[4]!.replace(/^"|"$/g, '').replace(/""/g, '"') || 'Unknown';
    const query = match[5]!.replace(/^"|"$/g, '').replace(/""/g, '"');
    const addressLine1 = query.split(',')[0]?.trim() || null;
    void idIdx;
    void nameIdx;
    rows.push({ id, name, addressLine1, city, province });
    if (limit && rows.length >= limit) break;
  }
  return rows;
}

async function loadFacilitiesFromDb(opts: PilotOptions): Promise<PilotFacility[]> {
  const conditions = [
    'f.is_active = true',
    'f.deleted_at IS NULL',
    '(f.address_line1 IS NOT NULL OR f.city IS NOT NULL)',
  ];
  const params: unknown[] = [];
  let idx = 1;

  if (opts.importSource) {
    conditions.push(`f.import_source = $${idx++}`);
    params.push(opts.importSource);
  }

  if (opts.city) {
    conditions.push(`f.city ILIKE $${idx++}`);
    params.push(opts.city);
  }

  if (opts.qualityFilter) {
    const parts: string[] = [];
    if (opts.qualityFilter.has('missing')) {
      parts.push('(f.latitude IS NULL OR f.longitude IS NULL)');
    }
    const qualities = [...opts.qualityFilter].filter(
      (q) => q !== 'missing',
    ) as GeocodeQuality[];
    if (qualities.length > 0) {
      parts.push(`f.geocode_quality = ANY($${idx++}::text[])`);
      params.push(qualities);
    }
    if (parts.length > 0) {
      conditions.push(`(${parts.join(' OR ')})`);
    }
  } else if (!opts.fromCsv) {
    conditions.push(
      '(f.latitude IS NULL OR f.longitude IS NULL OR f.geocode_quality IN (\'city_only\', \'city_centre\'))',
    );
  }

  let limitClause = '';
  if (opts.limit) {
    limitClause = ` LIMIT $${idx++}`;
    params.push(opts.limit);
  }

  const result = await pool.query<PilotFacility>(
    `SELECT f.id, f.name, f.address_line1 AS "addressLine1", f.city, f.province
     FROM public.facilities f
     WHERE ${conditions.join(' AND ')}
     ORDER BY f.city, f.name${limitClause}`,
    params,
  );
  return result.rows;
}

function toInput(facility: PilotFacility): FacilityAddressInput {
  return {
    name: facility.name,
    addressLine1: facility.addressLine1,
    city: facility.city,
    province: facility.province,
  };
}

function recommend(
  nominatim: GeocodeResult | null,
  google: GeocodeResult | null,
): string {
  const nomTrusted =
    nominatim && isTrustedGeocodeQuality(nominatim.quality ?? 'address');
  const googleTrusted =
    google && isTrustedGeocodeQuality(google.quality ?? 'address');

  if (!nominatim && !google) return 'both_failed';
  if (!nominatim && googleTrusted) return 'google';
  if (nominatim && !google) return 'nominatim';
  if (!nomTrusted && googleTrusted) return 'google';
  if (nomTrusted && !googleTrusted) return 'nominatim';
  if (nomTrusted && googleTrusted) {
    const dist = distanceBetweenResults(nominatim, google);
    if (dist != null && dist > 5) return 'manual_review';
    return 'google';
  }
  return 'manual_review';
}

function median(values: number[]): number | null {
  if (values.length === 0) return null;
  const sorted = [...values].sort((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0
    ? (sorted[mid - 1]! + sorted[mid]!) / 2
    : sorted[mid]!;
}

function csvEscape(value: string): string {
  return `"${value.replace(/"/g, '""')}"`;
}

function formatResult(result: GeocodeResult | null): {
  lat: string;
  lon: string;
  quality: string;
  formatted: string;
  strategy: string;
} {
  if (!result) {
    return { lat: '', lon: '', quality: '', formatted: '', strategy: '' };
  }
  return {
    lat: String(result.latitude),
    lon: String(result.longitude),
    quality: result.quality ?? 'address',
    formatted: result.formattedAddress,
    strategy: result.googleStrategy ?? '',
  };
}

async function run(): Promise<void> {
  const opts = parseArgs();
  getGoogleMapsApiKey();
  await ensureGeocodeQualityColumns(pool);

  const facilities = opts.fromCsv
    ? loadFacilitiesFromCsv(opts.fromCsv, opts.limit)
    : await loadFacilitiesFromDb(opts);

  if (facilities.length === 0) {
    logger.info('No facilities matched pilot scope');
    await closePool();
    return;
  }

  logger.info('Geocode pilot starting', {
    facilities: facilities.length,
    fromCsv: opts.fromCsv,
    importSource: opts.importSource,
    city: opts.city,
    output: opts.outputPath,
  });

  const client = await pool.connect();
  const pilotRows: PilotRow[] = [];

  try {
    const cityResult = await client.query<{
      name: string;
      province: string;
      latitude: number;
      longitude: number;
    }>(
      `SELECT name, province, latitude, longitude
       FROM public.cities
       WHERE country_code = 'ZW'
         AND latitude IS NOT NULL
         AND longitude IS NOT NULL`,
    );
    const cityCentroids = createCityCentroidMap(cityResult.rows);

    for (const facility of facilities) {
      const input = toInput(facility);
      const nominatim = await geocodeFacilityInput(client, input, cityCentroids, false);
      const google = await geocodeGoogleFacilityInput(client, input, cityCentroids, false);
      pilotRows.push({
        id: facility.id,
        name: facility.name,
        query: buildQuery(facility),
        nominatim,
        google,
      });
    }
  } finally {
    client.release();
  }

  const header = [
    'id',
    'name',
    'query',
    'nominatim_lat',
    'nominatim_lon',
    'nominatim_quality',
    'google_lat',
    'google_lon',
    'google_quality',
    'google_formatted_address',
    'google_strategy',
    'distance_km_between',
    'recommendation',
  ].join(',');

  const lines = [header];
  const distances: number[] = [];
  let googleWins = 0;
  let nominatimOnly = 0;
  let bothFailed = 0;
  let googleResolvedFromFailure = 0;

  for (const row of pilotRows) {
    const nom = formatResult(row.nominatim);
    const g = formatResult(row.google);
    const dist = distanceBetweenResults(row.nominatim, row.google);
    const rec = recommend(row.nominatim, row.google);

    if (rec === 'google') googleWins++;
    if (rec === 'nominatim' && row.nominatim && !row.google) nominatimOnly++;
    if (rec === 'both_failed') bothFailed++;
    if (!row.nominatim && row.google && isTrustedGeocodeQuality(row.google.quality ?? 'address')) {
      googleResolvedFromFailure++;
    }
    if (dist != null) distances.push(dist);

    lines.push(
      [
        row.id,
        csvEscape(row.name),
        csvEscape(row.query),
        nom.lat,
        nom.lon,
        nom.quality,
        g.lat,
        g.lon,
        g.quality,
        csvEscape(g.formatted),
        g.strategy,
        dist != null ? dist.toFixed(3) : '',
        rec,
      ].join(','),
    );
  }

  writeFileSync(opts.outputPath, lines.join('\n'), 'utf8');

  const googleResolveRate =
    pilotRows.length > 0
      ? ((googleResolvedFromFailure / pilotRows.length) * 100).toFixed(1)
      : '0';
  const googleWinRate =
    pilotRows.length > 0
      ? ((googleWins / pilotRows.length) * 100).toFixed(1)
      : '0';

  console.log('\n=== Geocode pilot summary ===\n');
  console.log(`Facilities compared: ${pilotRows.length}`);
  console.log(`Google recommended:  ${googleWins} (${googleWinRate}%)`);
  console.log(`Nominatim only:      ${nominatimOnly}`);
  console.log(`Both failed:         ${bothFailed}`);
  console.log(
    `Google resolved Nominatim failures: ${googleResolvedFromFailure} (${googleResolveRate}%)`,
  );
  const med = median(distances);
  if (med != null) {
    console.log(`Median distance when both succeed: ${med.toFixed(3)} km`);
  }
  console.log(`\nWrote ${opts.outputPath}`);

  logger.info('Geocode pilot complete', {
    facilities: pilotRows.length,
    googleWins,
    bothFailed,
    googleResolvedFromFailure,
  });

  await closePool();
}

run().catch((err) => {
  logger.error('Geocode pilot failed', {
    error: err instanceof Error ? err.message : String(err),
  });
  process.exit(1);
});
