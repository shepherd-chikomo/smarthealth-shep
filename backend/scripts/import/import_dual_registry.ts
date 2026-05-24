#!/usr/bin/env node
/**
 * Dual-registry import: HPA facilities + MDPCZ practitioners + direct-name linking
 *
 * Usage:
 *   npm run import:dual -- facilities.xlsx mdpcz_public_register.xlsx
 *   npm run import:dual -- facilities.xlsx mdpcz_public_register.xlsx --dry-run
 *   npm run import:dual -- facilities.xlsx mdpcz_public_register.xlsx --reset
 *   npm run import:dual -- facilities.xlsx mdpcz_public_register.xlsx --diff
 */
import { resolve } from 'node:path';
import { randomUUID } from 'node:crypto';
import { closePool, withTransaction } from './db.js';
import { logger } from './logger.js';
import { wipeImportedDirectoryData } from './wipe_import_data.js';
import { importHpaFacilities } from './import_hpa_facilities.js';
import { importMdpczPractitioners } from './import_mdpcz_practitioners.js';
import { linkRegistryDirectMatch } from './link_registry.js';
import { runRegistryDiff } from './registry_diff.js';
import { importPractitionerEmails } from './import_practitioner_emails.js';

function parseArgs(): {
  hpaFile: string;
  mdpczFile: string;
  emailsFile: string | null;
  dryRun: boolean;
  reset: boolean;
  diff: boolean;
} {
  const args = process.argv.slice(2).filter((a) => !a.startsWith('--'));
  const flags = new Set(process.argv.slice(2).filter((a) => a.startsWith('--')));

  if (args.length < 2) {
    console.error(`
Usage: npm run import:dual -- <facilities.xlsx> <mdpcz_public_register.xlsx> [practitioners.xlsx] [options]

Options:
  --dry-run   Validate without writing
  --reset     Full wipe before import (initial bootstrap)
  --diff      Run monthly diff instead of full import
`);
    process.exit(1);
  }

  return {
    hpaFile: resolve(args[0]),
    mdpczFile: resolve(args[1]),
    emailsFile: args[2] ? resolve(args[2]) : null,
    dryRun: flags.has('--dry-run'),
    reset: flags.has('--reset'),
    diff: flags.has('--diff'),
  };
}

async function main(): Promise<void> {
  const opts = parseArgs();
  const batchId = randomUUID();

  if (opts.diff) {
    const hpaRun = await runRegistryDiff(opts.hpaFile, 'HPA');
    const mdpczRun = await runRegistryDiff(opts.mdpczFile, 'MDPCZ');
    logger.info('Diff complete', { hpaRunId: hpaRun.runId, mdpczRunId: mdpczRun.runId });
    await closePool();
    return;
  }

  await withTransaction(async (client) => {
    if (opts.reset && !opts.dryRun) {
      await wipeImportedDirectoryData(client, false);
    }

    if (!opts.dryRun) {
      await client.query(
        `INSERT INTO public.import_logs (
           id, source_file, source_type, status, dry_run, total_rows, options
         ) VALUES ($1, $2, 'MIXED', 'running', $3, 0, $4)`,
        [
          batchId,
          `${opts.hpaFile} + ${opts.mdpczFile}`,
          opts.dryRun,
          JSON.stringify({ reset: opts.reset }),
        ],
      );
    }

    const hpaResult = await importHpaFacilities(client, opts.hpaFile, batchId, opts.dryRun);
    const mdpczResult = await importMdpczPractitioners(client, opts.mdpczFile, batchId, opts.dryRun);
    const linkResult = await linkRegistryDirectMatch(
      client,
      batchId,
      mdpczResult.providerNameIndex,
      opts.dryRun,
    );

    const emailResult = opts.emailsFile
      ? await importPractitionerEmails(client, opts.emailsFile, opts.dryRun)
      : null;

    if (!opts.dryRun) {
      await client.query(
        `UPDATE public.import_logs SET
           status = 'completed',
           facilities_created = $2,
           providers_created = $3,
           links_created = $4,
           failed_count = $5,
           completed_at = timezone('utc', now()),
           report_json = $6
         WHERE id = $1`,
        [
          batchId,
          hpaResult.created,
          mdpczResult.created,
          linkResult.linked,
          hpaResult.failed + mdpczResult.failed,
          JSON.stringify({ hpaResult, mdpczResult, linkResult, emailResult }),
        ],
      );
    }

    logger.info('Dual registry import complete', {
      batchId,
      facilities: hpaResult.created,
      practitioners: mdpczResult.created,
      links: linkResult.linked,
      ambiguous: hpaResult.ambiguous,
      manualAssociation: linkResult.manualAssociation + hpaResult.manualAssociation,
      unlinkedPractitioners: linkResult.unlinkedPractitioners,
      noEmail: mdpczResult.noEmail,
      emailsUpdated: emailResult?.updated ?? 0,
    });
  });

  await closePool();
}

main().catch((err) => {
  logger.error('Import failed', { error: err instanceof Error ? err.message : String(err), stack: err instanceof Error ? err.stack : undefined });
  process.exit(1);
});
