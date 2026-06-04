#!/usr/bin/env node
/**
 * Backfill address_line1 spacing for imported facilities.
 *
 * Usage:
 *   npm run fix:addresses
 *   npm run fix:addresses -- --dry-run
 *   npm run fix:addresses -- --import-source HPA
 *   npm run fix:addresses -- --csv changes.csv
 */
import { writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { closePool, withTransaction } from './db.js';
import {
  formatAddressLine,
  needsAddressFormatting,
} from './format_address.js';
import { logger } from './logger.js';

interface AddressRow {
  id: string;
  name: string;
  address_line1: string;
}

interface FixOptions {
  dryRun: boolean;
  importSource: string | null;
  csvPath: string | null;
}

function parseArgs(): FixOptions {
  const argv = process.argv.slice(2);
  const flags = new Set(argv.filter((a) => a.startsWith('--')));

  let importSource: string | null = 'HPA';
  let csvPath: string | null = null;

  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--import-source' && argv[i + 1]) {
      importSource = argv[i + 1];
      i++;
    } else if (argv[i] === '--csv' && argv[i + 1]) {
      csvPath = resolve(argv[i + 1]);
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
  };
}

async function run(): Promise<void> {
  const opts = parseArgs();

  const changes: Array<{
    id: string;
    name: string;
    from: string;
    to: string;
  }> = [];

  await withTransaction(async (client) => {
    const conditions = [
      'f.is_active = true',
      'f.deleted_at IS NULL',
      'f.address_line1 IS NOT NULL',
      "trim(f.address_line1) <> ''",
    ];
    const params: unknown[] = [];
    let idx = 1;

    if (opts.importSource) {
      conditions.push(`f.import_source = $${idx++}`);
      params.push(opts.importSource);
    }

    const result = await client.query<AddressRow>(
      `SELECT f.id, f.name, f.address_line1
       FROM public.facilities f
       WHERE ${conditions.join(' AND ')}
       ORDER BY f.city, f.name`,
      params,
    );

    const updates: Array<{ id: string; address: string }> = [];

    for (const row of result.rows) {
      if (!needsAddressFormatting(row.address_line1)) continue;

      const formatted = formatAddressLine(row.address_line1);
      if (formatted === row.address_line1) continue;

      updates.push({ id: row.id, address: formatted });
      changes.push({
        id: row.id,
        name: row.name,
        from: row.address_line1,
        to: formatted,
      });
    }

    logger.info('Address fix summary', {
      scanned: result.rows.length,
      needsChange: updates.length,
      dryRun: opts.dryRun,
      importSource: opts.importSource ?? 'all',
    });

    if (changes.length > 0) {
      for (const c of changes.slice(0, 15)) {
        logger.info(`  ${c.name}: "${c.from}" -> "${c.to}"`);
      }
      if (changes.length > 15) {
        logger.info(`  … and ${changes.length - 15} more`);
      }
    }

    if (!opts.dryRun && updates.length > 0) {
      for (const batch of chunk(updates, 200)) {
        await client.query(
          `UPDATE public.facilities AS f
           SET address_line1 = v.address,
               updated_at = timezone('utc', now())
           FROM (
             SELECT unnest($1::uuid[]) AS id,
                    unnest($2::text[]) AS address
           ) AS v
           WHERE f.id = v.id`,
          [batch.map((u) => u.id), batch.map((u) => u.address)],
        );
      }
      logger.info(`Updated ${updates.length} facility addresses`);
    }
  });

  if (opts.csvPath && changes.length > 0) {
    const lines = [
      'id,name,from_address,to_address',
      ...changes.map((c) => {
        const n = c.name.replace(/"/g, '""');
        const from = c.from.replace(/"/g, '""');
        const to = c.to.replace(/"/g, '""');
        return `${c.id},"${n}","${from}","${to}"`;
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
  logger.error('Address fix failed', {
    error: err instanceof Error ? err.message : String(err),
  });
  process.exit(1);
});
