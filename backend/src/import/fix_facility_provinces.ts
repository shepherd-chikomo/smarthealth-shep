#!/usr/bin/env node
/**
 * Backfill facility provinces from Nominatim city lookups.
 *
 * Usage:
 *   npm run fix:provinces
 *   npm run fix:provinces -- --dry-run
 *   npm run fix:provinces -- --import-source HPA --limit 20
 *   npm run fix:provinces -- --csv /tmp/provinces-fixed.csv
 */
import { writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { closePool, pool, withTransaction } from './db.js';
import { logger } from './logger.js';
import {
  inferProvinceFromCitySync,
  lookupCityProvinceFromNominatim,
  lookupProvinceFromDb,
  type ZimbabweProvince,
} from './province_resolve.js';

interface FixOptions {
  dryRun: boolean;
  importSource: string | null;
  csvPath: string | null;
  unresolvedPath: string | null;
  limit: number | null;
}

interface CityRow {
  city: string;
  facility_count: string;
  current_province: string;
}

interface ProvinceChange {
  city: string;
  oldProvince: string;
  newProvince: string;
  nominatimQuery: string;
  nominatimStateRaw: string | null;
  facilityCount: number;
  source: 'curated' | 'db' | 'nominatim' | 'skipped';
}

/** Known coordinates for curated city→province overrides (see province_resolve CITY_TO_PROVINCE). */
const CURATED_CITY_COORDINATES: Record<string, { latitude: number; longitude: number }> = {
  domboshava: { latitude: -17.6247, longitude: 31.0714 },
};

function parseArgs(): FixOptions {
  const argv = process.argv.slice(2);
  const flags = new Set(argv.filter((a) => a.startsWith('--')));

  let importSource: string | null = 'HPA';
  let csvPath: string | null = null;
  let unresolvedPath: string | null = null;
  let limit: number | null = null;

  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--import-source' && argv[i + 1]) {
      importSource = argv[i + 1];
      i++;
    } else if (argv[i] === '--csv' && argv[i + 1]) {
      csvPath = resolve(argv[i + 1]);
      i++;
    } else if (argv[i] === '--unresolved-csv' && argv[i + 1]) {
      unresolvedPath = resolve(argv[i + 1]);
      i++;
    } else if (argv[i] === '--limit' && argv[i + 1]) {
      limit = Number.parseInt(argv[i + 1], 10);
      i++;
    }
  }

  if (flags.has('--all-sources')) {
    importSource = null;
  }

  return {
    dryRun: flags.has('--dry-run'),
    importSource,
    csvPath,
    unresolvedPath,
    limit: Number.isFinite(limit) && limit! > 0 ? limit : null,
  };
}

async function upsertCityCache(
  city: string,
  province: ZimbabweProvince,
  latitude: number,
  longitude: number,
): Promise<void> {
  await pool.query(
    `INSERT INTO public.cities (country_code, name, province, latitude, longitude)
     VALUES ('ZW', $1, $2, $3, $4)
     ON CONFLICT (country_code, name, province) DO UPDATE SET
       latitude = COALESCE(public.cities.latitude, EXCLUDED.latitude),
       longitude = COALESCE(public.cities.longitude, EXCLUDED.longitude),
       updated_at = timezone('utc', now())`,
    [city, province, latitude, longitude],
  );
}

async function updateFacilitiesProvince(city: string, province: ZimbabweProvince): Promise<number> {
  const result = await pool.query<{ count: string }>(
    `WITH updated AS (
       UPDATE public.facilities
       SET province = $2::public.zimbabwe_province,
           updated_at = timezone('utc', now())
       WHERE lower(city) = lower($1)
         AND is_active = true
         AND deleted_at IS NULL
         AND province::text IS DISTINCT FROM $2
       RETURNING 1
     )
     SELECT COUNT(*)::text AS count FROM updated`,
    [city, province],
  );
  return Number(result.rows[0]?.count ?? 0);
}

async function run(): Promise<void> {
  const opts = parseArgs();
  const changes: ProvinceChange[] = [];
  const unresolved: Array<{ city: string; facilityCount: number; currentProvince: string }> = [];

  const conditions = [
    'f.is_active = true',
    'f.deleted_at IS NULL',
    'f.city IS NOT NULL',
    "trim(f.city) <> ''",
  ];
  const params: unknown[] = [];
  let idx = 1;

  if (opts.importSource) {
    conditions.push(`f.import_source = $${idx++}`);
    params.push(opts.importSource);
  }

  let limitClause = '';
  if (opts.limit) {
    limitClause = ` LIMIT $${idx++}`;
    params.push(opts.limit);
  }

  const cities = await pool.query<CityRow>(
    `SELECT f.city,
            COUNT(*)::text AS facility_count,
            mode() WITHIN GROUP (ORDER BY f.province::text) AS current_province
     FROM public.facilities f
     WHERE ${conditions.join(' AND ')}
     GROUP BY f.city
     ORDER BY f.city${limitClause}`,
    params,
  );

  logger.info('Province backfill starting', {
    uniqueCities: cities.rows.length,
    dryRun: opts.dryRun,
    importSource: opts.importSource ?? 'all',
  });

  for (const row of cities.rows) {
    const facilityCount = Number(row.facility_count);
    const curatedProvince = inferProvinceFromCitySync(row.city);
    if (curatedProvince) {
      const coords = CURATED_CITY_COORDINATES[row.city.trim().toLowerCase()];
      if (curatedProvince !== row.current_province) {
        changes.push({
          city: row.city,
          oldProvince: row.current_province,
          newProvince: curatedProvince,
          nominatimQuery: '',
          nominatimStateRaw: null,
          facilityCount,
          source: 'curated',
        });
        if (!opts.dryRun) {
          await withTransaction(async () => {
            await pool.query(
              `DELETE FROM public.cities
               WHERE country_code = 'ZW' AND lower(name) = lower($1)`,
              [row.city],
            );
            if (coords) {
              await upsertCityCache(row.city, curatedProvince, coords.latitude, coords.longitude);
            }
            await updateFacilitiesProvince(row.city, curatedProvince);
          });
        }
      } else if (!opts.dryRun && coords) {
        await upsertCityCache(row.city, curatedProvince, coords.latitude, coords.longitude);
      }
      continue;
    }

    const existingProvince = await lookupProvinceFromDb(pool, row.city);

    if (existingProvince && existingProvince !== row.current_province) {
      changes.push({
        city: row.city,
        oldProvince: row.current_province,
        newProvince: existingProvince,
        nominatimQuery: '',
        nominatimStateRaw: null,
        facilityCount,
        source: 'db',
      });

      if (!opts.dryRun) {
        await updateFacilitiesProvince(row.city, existingProvince);
      }
      continue;
    }

    if (existingProvince) {
      continue;
    }

    const lookup = await lookupCityProvinceFromNominatim(row.city);
    if (!lookup) {
      unresolved.push({
        city: row.city,
        facilityCount,
        currentProvince: row.current_province,
      });
      continue;
    }

    if (lookup.province === row.current_province) {
      if (!opts.dryRun) {
        await upsertCityCache(row.city, lookup.province, lookup.latitude, lookup.longitude);
      }
      continue;
    }

    changes.push({
      city: row.city,
      oldProvince: row.current_province,
      newProvince: lookup.province,
      nominatimQuery: lookup.query,
      nominatimStateRaw: lookup.rawState,
      facilityCount,
      source: 'nominatim',
    });

    if (!opts.dryRun) {
      await withTransaction(async () => {
        await upsertCityCache(row.city, lookup.province, lookup.latitude, lookup.longitude);
        await updateFacilitiesProvince(row.city, lookup.province);
      });
    }
  }

  logger.info('Province backfill complete', {
    citiesScanned: cities.rows.length,
    updated: changes.length,
    unresolved: unresolved.length,
    dryRun: opts.dryRun,
  });

  if (changes.length > 0) {
    for (const c of changes.slice(0, 20)) {
      logger.info(`  ${c.city}: ${c.oldProvince} -> ${c.newProvince} (${c.source}, ${c.facilityCount} facilities)`);
    }
    if (changes.length > 20) {
      logger.info(`  … and ${changes.length - 20} more`);
    }
  }

  if (opts.csvPath && changes.length > 0) {
    const lines = [
      'city,old_province,new_province,nominatim_query,nominatim_state_raw,facility_count,source',
      ...changes.map((c) => {
        const q = c.nominatimQuery.replace(/"/g, '""');
        const raw = (c.nominatimStateRaw ?? '').replace(/"/g, '""');
        return `"${c.city.replace(/"/g, '""')}","${c.oldProvince}","${c.newProvince}","${q}","${raw}",${c.facilityCount},${c.source}`;
      }),
    ];
    writeFileSync(opts.csvPath, lines.join('\n'), 'utf8');
    logger.info(`Wrote ${changes.length} rows to ${opts.csvPath}`);
  }

  if (opts.unresolvedPath && unresolved.length > 0) {
    const lines = [
      'city,current_province,facility_count',
      ...unresolved.map((u) =>
        `"${u.city.replace(/"/g, '""')}","${u.currentProvince}",${u.facilityCount}`,
      ),
    ];
    writeFileSync(opts.unresolvedPath, lines.join('\n'), 'utf8');
    logger.info(`Wrote ${unresolved.length} unresolved cities to ${opts.unresolvedPath}`);
  }

  await closePool();
}

run().catch((err) => {
  logger.error('Province backfill failed', {
    error: err instanceof Error ? err.message : String(err),
  });
  process.exit(1);
});
