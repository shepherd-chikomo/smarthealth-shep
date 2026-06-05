#!/usr/bin/env node
/** Apply facility geocode_quality migration (local dev helper). */
import { pool } from '../lib/db.js';
import { ensureGeocodeQualityColumns } from './ensure_geocode_quality.js';
import { logger } from './logger.js';

async function run(): Promise<void> {
  await pool.query('SET lock_timeout = 10000');
  try {
    await ensureGeocodeQualityColumns(pool);
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
