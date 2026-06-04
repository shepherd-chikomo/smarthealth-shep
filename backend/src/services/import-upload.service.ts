import { randomUUID } from 'node:crypto';
import { mkdtemp, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type pg from 'pg';
import { query, withTransaction } from '../lib/db.js';
import { ForbiddenError } from '../lib/errors.js';
import { isSuperAdmin } from '../lib/rbac.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import { importMdpczPractitioners } from '../import/import_mdpcz_practitioners.js';
import { importHpaFacilities } from '../import/import_hpa_facilities.js';
import { linkUnlinkedRoleHolders } from '../import/link_registry.js';

function requireSuperAdmin(user: AuthenticatedUser): void {
  if (!isSuperAdmin(user)) throw new ForbiddenError('Super admin access required');
}

export interface ImportUploadSummary {
  batchId: string;
  sourceType: 'MDPCZ' | 'HPA';
  dryRun: boolean;
  created: number;
  failed: number;
  details: Record<string, number>;
}

async function writeTempXlsx(buffer: Buffer, fileName: string): Promise<{ dir: string; filePath: string }> {
  const dir = await mkdtemp(join(tmpdir(), 'sh-import-'));
  const safeName = fileName.replace(/[^\w.-]/g, '_') || 'upload.xlsx';
  const filePath = join(dir, safeName);
  await writeFile(filePath, buffer);
  return { dir, filePath };
}

/**
 * Run a single-file in-process import. Creates an `import_logs` row up front
 * (committed independently) so a record persists even if the import fails,
 * then executes the importer inside a transaction and records the outcome.
 */
async function runUpload(params: {
  user: AuthenticatedUser;
  fileBuffer: Buffer;
  fileName: string;
  dryRun: boolean;
  sourceType: 'MDPCZ' | 'HPA';
  run: (
    client: pg.PoolClient,
    filePath: string,
    batchId: string,
    dryRun: boolean,
  ) => Promise<{ created: number; failed: number; details: Record<string, number> }>;
}): Promise<ImportUploadSummary> {
  const { user, fileBuffer, fileName, dryRun, sourceType, run } = params;
  requireSuperAdmin(user);

  const batchId = randomUUID();
  const { dir, filePath } = await writeTempXlsx(fileBuffer, fileName);

  await query(
    `INSERT INTO public.import_logs (
       id, source_file, source_type, status, dry_run, total_rows, options, started_by
     ) VALUES ($1, $2, $3::public.import_source_type, 'running', $4, 0, $5, $6)`,
    [batchId, fileName, sourceType, dryRun, JSON.stringify({ upload: true }), user.id],
  );

  try {
    const result = await withTransaction(async (client) => {
      const imported = await run(client, filePath, batchId, dryRun);
      // Cross-reference both registers so role-holder intents become real links
      // even though providers and facilities are uploaded as separate batches.
      const link = await linkUnlinkedRoleHolders(client, dryRun);
      return {
        ...imported,
        linked: link.linked,
        details: { ...imported.details, linked: link.linked, linkAmbiguous: link.ambiguous },
      };
    });

    await query(
      `UPDATE public.import_logs SET
         status = 'completed',
         imported_count = $2,
         facilities_created = $3,
         providers_created = $4,
         links_created = $5,
         failed_count = $6,
         completed_at = timezone('utc', now()),
         report_json = $7
       WHERE id = $1`,
      [
        batchId,
        result.created,
        sourceType === 'HPA' ? result.created : 0,
        sourceType === 'MDPCZ' ? result.created : 0,
        result.linked,
        result.failed,
        JSON.stringify({ ...result.details, dryRun }),
      ],
    );

    return {
      batchId,
      sourceType,
      dryRun,
      created: result.created,
      failed: result.failed,
      details: result.details,
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    await query(
      `UPDATE public.import_logs SET
         status = 'failed',
         error_message = $2,
         completed_at = timezone('utc', now())
       WHERE id = $1`,
      [batchId, message],
    );
    throw error;
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
}

export async function importProvidersUpload(
  user: AuthenticatedUser,
  fileBuffer: Buffer,
  fileName: string,
  dryRun: boolean,
): Promise<ImportUploadSummary> {
  return runUpload({
    user,
    fileBuffer,
    fileName,
    dryRun,
    sourceType: 'MDPCZ',
    run: async (client, filePath, batchId, dry) => {
      const r = await importMdpczPractitioners(client, filePath, batchId, dry);
      return { created: r.created, failed: r.failed, details: { created: r.created, failed: r.failed, noEmail: r.noEmail } };
    },
  });
}

export async function importFacilitiesUpload(
  user: AuthenticatedUser,
  fileBuffer: Buffer,
  fileName: string,
  dryRun: boolean,
): Promise<ImportUploadSummary> {
  return runUpload({
    user,
    fileBuffer,
    fileName,
    dryRun,
    sourceType: 'HPA',
    run: async (client, filePath, batchId, dry) => {
      const r = await importHpaFacilities(client, filePath, batchId, dry);
      return {
        created: r.created,
        failed: r.failed,
        details: { created: r.created, failed: r.failed, ambiguous: r.ambiguous, manualAssociation: r.manualAssociation },
      };
    },
  });
}
