#!/usr/bin/env node
/**
 * Correct "Murewa" → "Murehwa" spelling and Mashonaland East province for Murehwa-area facilities.
 * Also fixes known mis-province rows (e.g. Claremont Estate Clinic → Manicaland).
 *
 * Usage:
 *   npm run fix:murehwa -- --dry-run
 *   npm run fix:murehwa
 */
import { closePool, pool } from './db.js';
import { logger } from './logger.js';

const dryRun = process.argv.includes('--dry-run');

async function run(): Promise<void> {
  const client = await pool.connect();
  try {
    const murewaCount = await client.query<{ count: string }>(
      `SELECT COUNT(*)::text AS count FROM public.facilities
       WHERE deleted_at IS NULL
         AND (
           city ILIKE '%Murewa%'
           OR address_line1 ILIKE '%Murewa%'
           OR name ILIKE '%Murewa%'
         )`,
    );

    logger.info('Murewa spelling fixes', {
      dryRun,
      affected: Number(murewaCount.rows[0]?.count ?? 0),
    });

    if (!dryRun) {
      const spelling = await client.query(
        `UPDATE public.facilities
         SET
           name = regexp_replace(name, 'Murewa', 'Murehwa', 'gi'),
           city = regexp_replace(city, 'Murewa', 'Murehwa', 'gi'),
           address_line1 = regexp_replace(address_line1, 'Murewa', 'Murehwa', 'gi'),
           updated_at = timezone('utc', now())
         WHERE deleted_at IS NULL
           AND (
             city ILIKE '%Murewa%'
             OR address_line1 ILIKE '%Murewa%'
             OR name ILIKE '%Murewa%'
           )`,
      );

      const province = await client.query(
        `UPDATE public.facilities
         SET province = 'Mashonaland East'::public.zimbabwe_province,
             updated_at = timezone('utc', now())
         WHERE deleted_at IS NULL
           AND (
             city ILIKE '%Murehwa%'
             OR address_line1 ILIKE '%Murehwa%'
             OR name ILIKE '%Murehwa%'
           )
           AND province = 'Harare'::public.zimbabwe_province`,
      );

      const claremont = await client.query(
        `UPDATE public.facilities
         SET province = 'Manicaland'::public.zimbabwe_province,
             city = CASE WHEN city ILIKE '%Nyanga%' OR city = 'Harare' THEN 'Nyanga' ELSE city END,
             updated_at = timezone('utc', now())
         WHERE deleted_at IS NULL
           AND name ILIKE '%Claremont Estate Clinic%'`,
      );

      logger.info('Updates applied', {
        spellingRows: spelling.rowCount,
        provinceRows: province.rowCount,
        claremontRows: claremont.rowCount,
      });
    }
  } finally {
    client.release();
    await closePool();
  }
}

run().catch((err) => {
  logger.error('fix:murehwa failed', {
    error: err instanceof Error ? err.message : String(err),
  });
  process.exit(1);
});
