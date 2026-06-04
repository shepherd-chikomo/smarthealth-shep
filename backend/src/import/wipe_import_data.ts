#!/usr/bin/env node
/**
 * Full wipe of imported directory data (initial bootstrap only).
 *
 * Usage: tsx src/import/wipe_import_data.ts [--dry-run]
 */
import type pg from 'pg';
import { closePool, withTransaction } from './db.js';
import { logger } from './logger.js';

export async function wipeImportedDirectoryData(
  client: pg.PoolClient,
  dryRun = false,
): Promise<void> {
  const tables = [
    'public.facility_practitioner_invitations',
    'public.facility_admin_invitations',
    'public.practitioner_claim_sessions',
    'public.manual_validation_tickets',
    'public.registry_diff_items',
    'public.registry_diff_runs',
    'public.import_review_queue',
    'public.facility_role_holder_intents',
    'public.provider_facility_links',
    'public.provider_specialties',
    'public.facility_branches',
    'public.provider_claims',
    'public.facility_claims',
    'public.failed_imports',
    'public.import_duplicate_reviews',
    'public.import_unmatched_specialties',
    'public.providers',
    'public.facilities',
    'public.import_logs',
  ];

  logger.warn(`Wiping imported directory data${dryRun ? ' (dry run)' : ''}...`);

  for (const table of tables) {
    const countResult = await client.query<{ count: string }>(
      `SELECT COUNT(*)::text AS count FROM ${table}`,
    );
    const count = countResult.rows[0]?.count ?? '0';
    logger.info(`  ${table}: ${count} rows`);
    if (!dryRun) {
      await client.query(`DELETE FROM ${table}`);
    }
  }

  if (!dryRun) {
    await client.query(`
      DELETE FROM public.facility_memberships fm
      WHERE NOT EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = fm.user_id AND p.primary_role = 'super_admin'
      )
    `);
  }

  logger.info('Wipe complete.');
}

async function main(): Promise<void> {
  const dryRun = process.argv.includes('--dry-run');
  await withTransaction(async (client) => {
    await wipeImportedDirectoryData(client, dryRun);
  });
  await closePool();
}

if (import.meta.url === `file://${process.argv[1]?.replace(/\\/g, '/')}` ||
    process.argv[1]?.endsWith('wipe_import_data.ts')) {
  main().catch((err) => {
    logger.error('Wipe failed', { error: String(err) });
    process.exit(1);
  });
}
