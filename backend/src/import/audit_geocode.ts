#!/usr/bin/env node
/**
 * Report facility geocoding quality (coverage, duplicate coords, city-centre rows).
 *
 * Usage:
 *   npm run audit:geocode
 *   npm run audit:geocode -- --import-source HPA
 */
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { closePool, pool, query } from './db.js';
import { logger } from './logger.js';

const __dirname = dirname(fileURLToPath(import.meta.url));

async function ensureGeocodeQualityColumns(): Promise<void> {
  const sqlPath = resolve(
    __dirname,
    '../../../supabase/migrations/20260602100000_facility_geocode_quality.sql',
  );
  await pool.query(readFileSync(sqlPath, 'utf8'));
}

function parseImportSource(): string | null {
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--import-source' && argv[i + 1]) return argv[i + 1];
  }
  return 'HPA';
}

async function run(): Promise<void> {
  await ensureGeocodeQualityColumns();
  const importSource = parseImportSource();
  const sourceClause = importSource ? 'AND f.import_source = $1' : '';
  const sourceParams = importSource ? [importSource] : [];

  const totals = await query<{
    total: string;
    with_coords: string;
    city_centre_label: string;
    low_quality: string;
  }>(
    `SELECT
       COUNT(*)::text AS total,
       COUNT(*) FILTER (WHERE f.latitude IS NOT NULL AND f.longitude IS NOT NULL)::text AS with_coords,
       COUNT(*) FILTER (
         WHERE f.formatted_address ILIKE '%(city centre)%'
       )::text AS city_centre_label,
       COUNT(*) FILTER (
         WHERE f.geocode_quality IN ('city_only', 'city_centre')
       )::text AS low_quality
     FROM public.facilities f
     WHERE f.is_active = true
       AND f.deleted_at IS NULL
       ${sourceClause}`,
    sourceParams,
  );

  const row = totals.rows[0];
  const total = Number(row?.total ?? 0);
  const withCoords = Number(row?.with_coords ?? 0);
  const pct = total > 0 ? ((withCoords / total) * 100).toFixed(1) : '0';

  console.log('\n=== Geocode audit ===\n');
  if (importSource) console.log(`Scope: import_source = ${importSource}`);
  console.log(`Active facilities:     ${total}`);
  console.log(`With coordinates:    ${withCoords} (${pct}%)`);
  console.log(`City-centre label:   ${row?.city_centre_label ?? 0}`);
  console.log(`Low geocode_quality: ${row?.low_quality ?? 0}`);

  const clusters = await query<{
    latitude: number;
    longitude: number;
    facility_count: string;
    sample_names: string;
  }>(
    `SELECT
       ROUND(f.latitude::numeric, 5) AS latitude,
       ROUND(f.longitude::numeric, 5) AS longitude,
       COUNT(*)::text AS facility_count,
       string_agg(f.name, ' | ' ORDER BY f.name) FILTER (WHERE true) AS sample_names
     FROM public.facilities f
     WHERE f.is_active = true
       AND f.deleted_at IS NULL
       AND f.latitude IS NOT NULL
       AND f.longitude IS NOT NULL
       ${sourceClause}
     GROUP BY ROUND(f.latitude::numeric, 5), ROUND(f.longitude::numeric, 5)
     HAVING COUNT(*) > 1
     ORDER BY COUNT(*) DESC
     LIMIT 10`,
    sourceParams,
  );

  console.log('\nTop duplicate coordinate clusters:');
  if (clusters.rows.length === 0) {
    console.log('  (none)');
  } else {
    for (const c of clusters.rows) {
      const names = (c.sample_names ?? '').slice(0, 120);
      console.log(
        `  ${c.facility_count} @ (${c.latitude}, ${c.longitude}) — ${names}${names.length >= 120 ? '…' : ''}`,
      );
    }
  }

  const centroidMatches = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count
     FROM public.facilities f
     JOIN public.cities c
       ON c.country_code = 'ZW'
      AND lower(c.name) = lower(f.city)
      AND c.province::text = f.province::text
      AND c.latitude IS NOT NULL
      AND c.longitude IS NOT NULL
     WHERE f.is_active = true
       AND f.deleted_at IS NULL
       AND f.latitude IS NOT NULL
       AND f.longitude IS NOT NULL
       AND ABS(f.latitude - c.latitude) < 0.0001
       AND ABS(f.longitude - c.longitude) < 0.0001
       ${sourceClause}`,
    sourceParams,
  );
  console.log(`\nFacilities at exact city centroid: ${centroidMatches.rows[0]?.count ?? 0}`);

  const qualityBreakdown = await query<{ geocode_quality: string | null; count: string }>(
    `SELECT f.geocode_quality, COUNT(*)::text AS count
     FROM public.facilities f
     WHERE f.is_active = true
       AND f.deleted_at IS NULL
       ${sourceClause}
     GROUP BY f.geocode_quality
     ORDER BY COUNT(*) DESC`,
    sourceParams,
  );
  console.log('\ngeocode_quality breakdown:');
  for (const q of qualityBreakdown.rows) {
    console.log(`  ${q.geocode_quality ?? '(null)'}: ${q.count}`);
  }

  logger.info('Geocode audit complete');
  await closePool();
}

run().catch((err) => {
  logger.error('Geocode audit failed', {
    error: err instanceof Error ? err.message : String(err),
  });
  process.exit(1);
});
