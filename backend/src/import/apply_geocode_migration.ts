#!/usr/bin/env node
/** Apply facility geocode_quality migration (local dev helper). */
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { pool } from '../lib/db.js';
import { logger } from './logger.js';

const __dirname = dirname(fileURLToPath(import.meta.url));

async function run(): Promise<void> {
  const sqlPath = resolve(
    __dirname,
    '../../../supabase/migrations/20260602100000_facility_geocode_quality.sql',
  );
  const sql = readFileSync(sqlPath, 'utf8');
  await pool.query('SET lock_timeout = 10000');
  try {
    await pool.query(sql);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes('lock timeout') || msg.includes('canceling statement')) {
      logger.error(
        'Migration blocked by another session (likely a stuck geocode import). Restart local Supabase, then rerun: npm run db:migrate:geocode-quality',
      );
    }
    throw err;
  }
  logger.info('Applied geocode_quality migration');
  await pool.end();
}

run().catch((err) => {
  logger.error('Migration failed', {
    error: err instanceof Error ? err.message : String(err),
  });
  process.exit(1);
});
