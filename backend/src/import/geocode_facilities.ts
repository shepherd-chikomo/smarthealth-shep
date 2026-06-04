#!/usr/bin/env node
/**
 * Backfill latitude/longitude for facilities missing coordinates.
 *
 * Uses multi-strategy Nominatim (rate-limited ~1 req/s) with geocode_cache deduplication.
 *
 * Usage:
 *   npm run geocode:facilities
 *   npm run geocode:facilities -- --city Harare --limit 50
 *   npm run geocode:facilities -- --dry-run
 *   npm run geocode:facilities -- --skip-remote
 *   npm run geocode:facilities -- --import-source HPA --reset --clear-cache --csv geocode-failures.csv
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { closePool, pool, withTransaction } from './db.js';
import {
  createCityCentroidMap,
  facilityInputSignature,
  geocodeFacilityBatch,
  isWithinZimbabwe,
} from './geocode.js';
import { logger } from './logger.js';
import type { GeocodeQuality, GeocodeResult } from './types.js';

interface FacilityRow {
  id: string;
  name: string;
  address_line1: string | null;
  city: string;
  province: string;
  city_id: string | null;
}

interface GeocodeOptions {
  dryRun: boolean;
  skipRemote: boolean;
  limit: number | null;
  city: string | null;
  csvPath: string | null;
  reset: boolean;
  clearCache: boolean;
  importSource: string | null;
  noCityFallback: boolean;
}

function parseArgs(): GeocodeOptions {
  const argv = process.argv.slice(2);
  const flags = new Set(argv.filter((a) => a.startsWith('--')));

  let limit: number | null = null;
  let city: string | null = null;
  let csvPath: string | null = null;
  let importSource: string | null = null;

  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--limit' && argv[i + 1]) {
      limit = Number.parseInt(argv[i + 1], 10);
      i++;
    } else if (argv[i] === '--city' && argv[i + 1]) {
      city = argv[i + 1];
      i++;
    } else if (argv[i] === '--csv' && argv[i + 1]) {
      csvPath = resolve(argv[i + 1]);
      i++;
    } else if (argv[i] === '--import-source' && argv[i + 1]) {
      importSource = argv[i + 1];
      i++;
    }
  }

  const reset = flags.has('--reset');
  if (reset && !importSource && !flags.has('--all-sources')) {
    importSource = 'HPA';
  }

  const noCityFallback =
    flags.has('--no-city-fallback') || (reset && !flags.has('--allow-city-fallback'));

  return {
    dryRun: flags.has('--dry-run'),
    skipRemote: flags.has('--skip-remote'),
    limit: Number.isFinite(limit) && limit! > 0 ? limit : null,
    city,
    csvPath,
    reset,
    clearCache: flags.has('--clear-cache'),
    importSource,
    noCityFallback,
  };
}

function buildScopeConditions(
  opts: GeocodeOptions,
  params: unknown[],
): { conditions: string[]; nextIdx: number } {
  const conditions = [
    'f.is_active = true',
    'f.deleted_at IS NULL',
    '(f.address_line1 IS NOT NULL OR f.city IS NOT NULL)',
  ];
  let idx = params.length + 1;

  if (!opts.reset) {
    conditions.push('(f.latitude IS NULL OR f.longitude IS NULL)');
  }

  if (opts.importSource) {
    conditions.push(`f.import_source = $${idx++}`);
    params.push(opts.importSource);
  }

  if (opts.city) {
    conditions.push(`f.city ILIKE $${idx++}`);
    params.push(opts.city);
  }

  return { conditions, nextIdx: idx };
}

async function loadCityCentroids(
  client: import('pg').PoolClient,
): Promise<ReturnType<typeof createCityCentroidMap>> {
  const result = await client.query<{
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
  return createCityCentroidMap(result.rows);
}

function cityFallback(
  facility: FacilityRow,
  cityCentroids: ReturnType<typeof createCityCentroidMap>,
): GeocodeResult | null {
  const centroid = cityCentroids.get(facility.city, facility.province);
  if (!centroid || !isWithinZimbabwe(centroid.lat, centroid.lon)) return null;

  return {
    latitude: centroid.lat,
    longitude: centroid.lon,
    formattedAddress: `${facility.city}, ${facility.province}, Zimbabwe (city centre)`,
    fromCache: false,
    quality: 'city_centre',
    provider: 'nominatim',
  };
}

const __dirname = dirname(fileURLToPath(import.meta.url));

async function ensureGeocodeQualityColumns(): Promise<void> {
  const sqlPath = resolve(
    __dirname,
    '../../../supabase/migrations/20260602100000_facility_geocode_quality.sql',
  );
  await pool.query(readFileSync(sqlPath, 'utf8'));
}

async function run(): Promise<void> {
  const opts = parseArgs();
  await ensureGeocodeQualityColumns();

  const summary = {
    scanned: 0,
    uniqueSignatures: 0,
    geocoded: 0,
    cityFallback: 0,
    failed: 0,
    skipped: 0,
    reset: 0,
  };

  const failures: Array<{ id: string; name: string; query: string | null }> = [];

  const scopeParams: unknown[] = [];
  const { conditions, nextIdx: idxStart } = buildScopeConditions(opts, scopeParams);

  await withTransaction(async (client) => {
    if (opts.reset && !opts.dryRun) {
      const resetResult = await client.query<{ count: string }>(
        `WITH updated AS (
           UPDATE public.facilities f
           SET latitude = NULL,
               longitude = NULL,
               formatted_address = NULL,
               geocode_quality = NULL,
               geocoded_at = NULL,
               updated_at = timezone('utc', now())
           WHERE ${conditions.join(' AND ')}
           RETURNING 1
         )
         SELECT COUNT(*)::text AS count FROM updated`,
        scopeParams,
      );
      summary.reset = Number(resetResult.rows[0]?.count ?? 0);
      logger.info(`Reset coordinates for ${summary.reset} facilities`);
    } else if (opts.reset) {
      const countResult = await client.query<{ count: string }>(
        `SELECT COUNT(*)::text AS count FROM public.facilities f WHERE ${conditions.join(' AND ')}`,
        scopeParams,
      );
      summary.reset = Number(countResult.rows[0]?.count ?? 0);
      logger.info(`Dry run: would reset ${summary.reset} facilities`);
    }

    if (opts.clearCache && !opts.dryRun) {
      await client.query('TRUNCATE public.geocode_cache');
      logger.info('Cleared geocode_cache');
    } else if (opts.clearCache) {
      logger.info('Dry run: would truncate geocode_cache');
    }
  });

  const params = [...scopeParams];
  let idx = idxStart;

  let limitClause = '';
  if (opts.limit) {
    limitClause = ` LIMIT $${idx++}`;
    params.push(opts.limit);
  }

  const facilities = await pool.query<FacilityRow>(
    `SELECT f.id, f.name, f.address_line1, f.city, f.province, f.city_id
     FROM public.facilities f
     WHERE ${conditions.join(' AND ')}
     ORDER BY f.city, f.name${limitClause}`,
    params,
  );

  summary.scanned = facilities.rows.length;
  if (summary.scanned === 0) {
    logger.info('No facilities need geocoding');
    await closePool();
    return;
  }

  const geocodeClient = await pool.connect();
  try {
    const cityCentroids = await loadCityCentroids(geocodeClient);

    const signatureToFacilityIds = new Map<string, string[]>();
    const facilityById = new Map<string, FacilityRow>();
    const signatureToInput = new Map<string, FacilityRow>();

    for (const row of facilities.rows) {
      facilityById.set(row.id, row);
      if (!row.city && !row.address_line1) {
        summary.skipped++;
        failures.push({ id: row.id, name: row.name, query: null });
        continue;
      }

      const input = {
        name: row.name,
        addressLine1: row.address_line1,
        city: row.city,
        province: row.province,
      };
      const sig = facilityInputSignature(input);
      signatureToInput.set(sig, row);

      const ids = signatureToFacilityIds.get(sig) ?? [];
      ids.push(row.id);
      signatureToFacilityIds.set(sig, ids);
    }

    const inputs = [...signatureToInput.values()].map((row) => ({
      name: row.name,
      addressLine1: row.address_line1,
      city: row.city,
      province: row.province,
    }));

    summary.uniqueSignatures = inputs.length;

    logger.info('Facility geocode backfill', {
      scanned: summary.scanned,
      uniqueSignatures: summary.uniqueSignatures,
      dryRun: opts.dryRun,
      skipRemote: opts.skipRemote,
      reset: opts.reset,
      clearCache: opts.clearCache,
      importSource: opts.importSource,
      noCityFallback: opts.noCityFallback,
      city: opts.city,
    });

    const geocodeResults = await geocodeFacilityBatch(
      geocodeClient,
      inputs,
      cityCentroids,
      opts.skipRemote,
    );

    const coordWhere = opts.reset
      ? ''
      : ' AND (latitude IS NULL OR longitude IS NULL)';

    for (const [sig, facilityIds] of signatureToFacilityIds) {
      let geo: GeocodeResult | null = geocodeResults.get(sig) ?? null;

      if (!geo) {
        if (!opts.noCityFallback) {
          const sample = facilityById.get(facilityIds[0]!);
          if (sample) {
            geo = cityFallback(sample, cityCentroids);
            if (geo) summary.cityFallback += facilityIds.length;
          }
        }
      } else {
        summary.geocoded += facilityIds.length;
      }

      if (!geo) {
        summary.failed += facilityIds.length;
        for (const id of facilityIds) {
          const f = facilityById.get(id);
          failures.push({
            id,
            name: f?.name ?? id,
            query: f
              ? [f.address_line1, f.city, f.province].filter(Boolean).join(', ')
              : null,
          });
        }
        continue;
      }

      if (opts.dryRun) continue;

      const quality: GeocodeQuality = geo.quality ?? 'address';

      for (const id of facilityIds) {
        await pool.query(
          `UPDATE public.facilities
           SET latitude = $1,
               longitude = $2,
               formatted_address = $3,
               geocode_quality = $4,
               geocoded_at = timezone('utc', now()),
               updated_at = timezone('utc', now())
           WHERE id = $5${coordWhere}`,
          [
            geo.latitude,
            geo.longitude,
            geo.formattedAddress,
            quality,
            id,
          ],
        );
      }
    }
  } finally {
    geocodeClient.release();
  }

  logger.info('Geocode backfill complete', summary);

  if (failures.length > 0) {
    logger.warn(`${failures.length} facilities could not be geocoded`);
    if (opts.csvPath) {
      const lines = ['id,name,query', ...failures.map((f) => {
        const q = (f.query ?? '').replace(/"/g, '""');
        const n = f.name.replace(/"/g, '""');
        return `${f.id},"${n}","${q}"`;
      })];
      writeFileSync(opts.csvPath, lines.join('\n'), 'utf8');
      logger.info(`Wrote failure report to ${opts.csvPath}`);
    }
  }

  await closePool();
}

run().catch((err) => {
  logger.error('Geocode backfill failed', {
    error: err instanceof Error ? err.message : String(err),
  });
  process.exit(1);
});
