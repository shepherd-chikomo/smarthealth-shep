#!/usr/bin/env node
/**
 * Cross-reference all imported registers and create missing facility
 * role-holder links. Useful after uploading HPA facilities and MDPCZ
 * practitioners as separate batches (e.g. via the admin Data Import page).
 *
 * Usage:
 *   npm run import:link
 *   npm run import:link -- --dry-run
 */
import { closePool, withTransaction } from './db.js';
import { logger } from './logger.js';
import { linkUnlinkedRoleHolders } from './link_registry.js';

const dryRun = process.argv.includes('--dry-run');

withTransaction((client) => linkUnlinkedRoleHolders(client, dryRun))
  .then(async (result) => {
    logger.info('Cross-reference link pass complete', { dryRun, ...result });
    await closePool();
    process.exit(0);
  })
  .catch((err) => {
    logger.error('Cross-reference link pass failed', {
      error: err instanceof Error ? err.message : String(err),
      stack: err instanceof Error ? err.stack : undefined,
    });
    process.exit(1);
  });
