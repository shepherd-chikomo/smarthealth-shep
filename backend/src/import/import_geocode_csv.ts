#!/usr/bin/env node
/**
 * Apply manual latitude/longitude overrides from CSV.
 *
 * CSV columns (header required):
 *   facility_id,latitude,longitude
 * or:
 *   name,city,latitude,longitude
 *
 * Usage:
 *   npm run geocode:import-csv -- --file coords.csv
 *   npm run geocode:import-csv -- --file coords.csv --dry-run
 */
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { closePool, withTransaction } from './db.js';
import { isWithinZimbabwe } from './geocode.js';
import { logger } from './logger.js';

interface CsvRow {
  facilityId?: string;
  name?: string;
  city?: string;
  latitude: number;
  longitude: number;
}

function parseArgs(): { filePath: string; dryRun: boolean } {
  const argv = process.argv.slice(2);
  const flags = new Set(argv.filter((a) => a.startsWith('--')));
  let filePath: string | null = null;

  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--file' && argv[i + 1]) {
      filePath = resolve(argv[i + 1]);
      i++;
    }
  }

  if (!filePath) {
    console.error('Usage: npm run geocode:import-csv -- --file <path.csv> [--dry-run]');
    process.exit(1);
  }

  return { filePath, dryRun: flags.has('--dry-run') };
}

function parseCsv(content: string): CsvRow[] {
  const lines = content.split(/\r?\n/).filter((l) => l.trim());
  if (lines.length < 2) return [];

  const header = lines[0]!.split(',').map((h) => h.trim().toLowerCase());
  const idIdx = header.indexOf('facility_id');
  const nameIdx = header.indexOf('name');
  const cityIdx = header.indexOf('city');
  const latIdx = header.indexOf('latitude');
  const lonIdx = header.indexOf('longitude');

  if (latIdx < 0 || lonIdx < 0) {
    throw new Error('CSV must include latitude and longitude columns');
  }
  if (idIdx < 0 && (nameIdx < 0 || cityIdx < 0)) {
    throw new Error('CSV must include facility_id or name+city columns');
  }

  const rows: CsvRow[] = [];
  for (let i = 1; i < lines.length; i++) {
    const cols = lines[i]!.split(',').map((c) => c.trim().replace(/^"|"$/g, ''));
    const lat = Number.parseFloat(cols[latIdx] ?? '');
    const lon = Number.parseFloat(cols[lonIdx] ?? '');
    if (!Number.isFinite(lat) || !Number.isFinite(lon)) continue;

    rows.push({
      facilityId: idIdx >= 0 ? cols[idIdx] : undefined,
      name: nameIdx >= 0 ? cols[nameIdx] : undefined,
      city: cityIdx >= 0 ? cols[cityIdx] : undefined,
      latitude: lat,
      longitude: lon,
    });
  }
  return rows;
}

async function run(): Promise<void> {
  const { filePath, dryRun } = parseArgs();
  const rows = parseCsv(readFileSync(filePath, 'utf8'));

  if (rows.length === 0) {
    logger.warn('No rows to import');
    await closePool();
    return;
  }

  let updated = 0;
  let skipped = 0;

  await withTransaction(async (client) => {
    for (const row of rows) {
      if (!isWithinZimbabwe(row.latitude, row.longitude)) {
        skipped++;
        continue;
      }

      let facilityId = row.facilityId;
      if (!facilityId && row.name && row.city) {
        const lookup = await client.query<{ id: string }>(
          `SELECT id FROM public.facilities
           WHERE is_active = true
             AND deleted_at IS NULL
             AND name ILIKE $1
             AND city ILIKE $2
           LIMIT 1`,
          [row.name, row.city],
        );
        facilityId = lookup.rows[0]?.id;
      }

      if (!facilityId) {
        skipped++;
        continue;
      }

      if (dryRun) {
        updated++;
        continue;
      }

      const result = await client.query(
        `UPDATE public.facilities
         SET latitude = $1,
             longitude = $2,
             geocode_quality = 'manual',
             geocoded_at = timezone('utc', now()),
             formatted_address = COALESCE(formatted_address, $3),
             updated_at = timezone('utc', now())
         WHERE id = $4`,
        [
          row.latitude,
          row.longitude,
          `Manual coordinates (${row.latitude}, ${row.longitude})`,
          facilityId,
        ],
      );
      if ((result.rowCount ?? 0) > 0) updated++;
      else skipped++;
    }
  });

  logger.info('Manual geocode import complete', {
    filePath,
    dryRun,
    rows: rows.length,
    updated,
    skipped,
  });

  await closePool();
}

run().catch((err) => {
  logger.error('Manual geocode import failed', {
    error: err instanceof Error ? err.message : String(err),
  });
  process.exit(1);
});
