#!/usr/bin/env node
/**
 * Backfill facility_type from facility names and linked provider specialties.
 *
 * Usage:
 *   npm run classify:facilities
 *   npm run classify:facilities -- --city Harare
 *   npm run classify:facilities -- --dry-run
 *   npm run classify:facilities -- --force
 *   npm run classify:facilities -- --csv report.csv
 */
import { writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { closePool, withTransaction } from './db.js';
import {
  resolveFacilityType,
  type FacilityType,
} from './infer_facility_type.js';
import { logger } from './logger.js';

interface FacilityClassifyRow {
  id: string;
  name: string;
  facility_type: string;
  facility_category: string | null;
  specialty_signals: string[] | null;
}

interface ClassifyOptions {
  dryRun: boolean;
  onlyClinic: boolean;
  force: boolean;
  limit: number | null;
  city: string | null;
  csvPath: string | null;
}

function parseArgs(): ClassifyOptions {
  const argv = process.argv.slice(2);
  const flags = new Set(argv.filter((a) => a.startsWith('--')));

  let limit: number | null = null;
  let city: string | null = null;
  let csvPath: string | null = null;

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
    }
  }

  return {
    dryRun: flags.has('--dry-run'),
    onlyClinic: !flags.has('--force'),
    force: flags.has('--force'),
    limit: Number.isFinite(limit) && limit! > 0 ? limit : null,
    city,
    csvPath,
  };
}

const FACILITY_SELECT_BODY = `
  SELECT
    f.id,
    f.name,
    f.facility_type::text AS facility_type,
    f.facility_category,
    (
      SELECT array_agg(DISTINCT sig) FILTER (WHERE sig IS NOT NULL AND sig <> '')
      FROM (
        SELECT lower(trim(s.slug)) AS sig
        FROM public.provider_facility_links pfl
        JOIN public.providers p ON p.id = pfl.provider_id AND p.is_active = true
        JOIN public.specialties s ON s.id = p.specialty_id AND s.is_active = true
        WHERE pfl.facility_id = f.id
        UNION
        SELECT lower(trim(p.specialty)) AS sig
        FROM public.provider_facility_links pfl
        JOIN public.providers p ON p.id = pfl.provider_id AND p.is_active = true
        WHERE pfl.facility_id = f.id AND p.specialty IS NOT NULL
        UNION
        SELECT lower(trim(s2.slug)) AS sig
        FROM public.provider_facility_links pfl
        JOIN public.providers p ON p.id = pfl.provider_id AND p.is_active = true
        JOIN public.provider_specialties ps ON ps.provider_id = p.id
        JOIN public.specialties s2 ON s2.id = ps.specialty_id AND s2.is_active = true
        WHERE pfl.facility_id = f.id
        UNION
        SELECT lower(trim(s2.name)) AS sig
        FROM public.provider_facility_links pfl
        JOIN public.providers p ON p.id = pfl.provider_id AND p.is_active = true
        JOIN public.provider_specialties ps ON ps.provider_id = p.id
        JOIN public.specialties s2 ON s2.id = ps.specialty_id AND s2.is_active = true
        WHERE pfl.facility_id = f.id
      ) AS signals
    ) AS specialty_signals
  FROM public.facilities f
`;

async function run(): Promise<void> {
  const opts = parseArgs();

  const summary = {
    scanned: 0,
    changed: 0,
    unchanged: 0,
    byNewType: new Map<FacilityType, number>(),
  };

  const changes: Array<{
    id: string;
    name: string;
    from: string;
    to: FacilityType;
  }> = [];

  await withTransaction(async (client) => {
    const conditions = [
      'f.is_active = true',
      'f.deleted_at IS NULL',
    ];
    const params: unknown[] = [];
    let idx = 1;

    if (opts.city) {
      conditions.push(`f.city ILIKE $${idx++}`);
      params.push(opts.city);
    }

    if (opts.onlyClinic && !opts.force) {
      conditions.push(`f.facility_type = 'clinic'::public.facility_type`);
    }

    let limitClause = '';
    if (opts.limit) {
      limitClause = ` LIMIT $${idx++}`;
      params.push(opts.limit);
    }

    const sql = `${FACILITY_SELECT_BODY}
       WHERE ${conditions.join(' AND ')}
       ORDER BY f.city, f.name${limitClause}`;

    const result = await client.query<FacilityClassifyRow>(sql, params);
    summary.scanned = result.rows.length;

    const updates: Array<{ id: string; type: FacilityType }> = [];

    for (const row of result.rows) {
      const inferred = resolveFacilityType({
        name: row.name,
        facilityCategory: row.facility_category,
        specialtyTexts: row.specialty_signals ?? [],
      });

      if (inferred === row.facility_type) {
        summary.unchanged++;
        continue;
      }

      updates.push({ id: row.id, type: inferred });
      changes.push({
        id: row.id,
        name: row.name,
        from: row.facility_type,
        to: inferred,
      });
      summary.byNewType.set(
        inferred,
        (summary.byNewType.get(inferred) ?? 0) + 1,
      );
    }

    summary.changed = updates.length;

    if (opts.dryRun) {
      logger.info(`Dry run: would update ${updates.length} of ${summary.scanned} facilities`);
    } else if (updates.length > 0) {
      for (const batch of chunk(updates, 200)) {
        const ids = batch.map((u) => u.id);
        const types = batch.map((u) => u.type);
        await client.query(
          `UPDATE public.facilities AS f
           SET facility_type = v.new_type::public.facility_type,
               facility_types = ARRAY[v.new_type::public.facility_type],
               updated_at = timezone('utc', now())
           FROM (
             SELECT unnest($1::uuid[]) AS id,
                    unnest($2::text[]) AS new_type
           ) AS v
           WHERE f.id = v.id`,
          [ids, types],
        );
      }
      logger.info(`Updated ${updates.length} facilities`);
    }

    if (changes.length > 0) {
      const sample = changes.slice(0, 15);
      for (const c of sample) {
        logger.info(`  ${c.name}: ${c.from} → ${c.to}`);
      }
      if (changes.length > sample.length) {
        logger.info(`  … and ${changes.length - sample.length} more`);
      }
    }

    const dist = await client.query<{ facility_type: string; count: string }>(
      `SELECT facility_type::text, COUNT(*)::text AS count
       FROM public.facilities f
       WHERE f.is_active = true AND f.deleted_at IS NULL
         ${opts.city ? 'AND f.city ILIKE $1' : ''}
       GROUP BY facility_type
       ORDER BY COUNT(*) DESC`,
      opts.city ? [opts.city] : [],
    );

    logger.info('Distribution after run:');
    for (const row of dist.rows) {
      logger.info(`  ${row.facility_type}: ${row.count}`);
    }
  });

  logger.info('Classify summary', {
    scanned: summary.scanned,
    changed: summary.changed,
    unchanged: summary.unchanged,
    dryRun: opts.dryRun,
    byNewType: Object.fromEntries(summary.byNewType),
  });

  if (opts.csvPath && changes.length > 0) {
    const lines = [
      'id,name,from_type,to_type',
      ...changes.map((c) => {
        const n = c.name.replace(/"/g, '""');
        return `${c.id},"${n}",${c.from},${c.to}`;
      }),
    ];
    writeFileSync(opts.csvPath, lines.join('\n'), 'utf8');
    logger.info(`Wrote ${changes.length} rows to ${opts.csvPath}`);
  }

  await closePool();
}

function chunk<T>(items: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < items.length; i += size) {
    out.push(items.slice(i, i + size));
  }
  return out;
}

run().catch((err) => {
  logger.error('Classify backfill failed', {
    error: err instanceof Error ? err.message : String(err),
  });
  process.exit(1);
});
