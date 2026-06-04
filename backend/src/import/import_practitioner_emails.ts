import type pg from 'pg';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadExcel } from './load_excel.js';
import { logger } from './logger.js';
import { normalizePersonName } from './normalize_registry.js';
import { validateEmail } from './validate.js';
import { closePool, normalizePhoneDb, withTransaction } from './db.js';

export interface PractitionerEmailImportResult {
  totalRows: number;
  matched: number;
  updated: number;
  skippedNoEmail: number;
  skippedInvalidEmail: number;
  unmatched: number;
  phonesUpdated: number;
  queuesResolved: number;
  unmatchedNames: string[];
}

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function extractEmail(raw: unknown): string | null {
  if (!raw) return null;
  const text = String(raw).trim().toLowerCase();
  if (!text || text === 'nil' || text === 'email_address') return null;

  const candidates = text
    .split(/[\s,;/]+/)
    .map((part) => part.replace(/[()]/g, '').trim())
    .filter(Boolean);

  for (const candidate of candidates) {
    if (EMAIL_PATTERN.test(candidate)) return candidate;
  }

  // Try to find embedded email in messy strings (e.g. "077... user@gmail.com")
  const embedded = text.match(/[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}/i);
  return embedded?.[0]?.toLowerCase() ?? null;
}

export async function importPractitionerEmails(
  client: pg.PoolClient,
  filePath: string,
  dryRun: boolean,
): Promise<PractitionerEmailImportResult> {
  const rawRows = loadExcel(filePath);

  const providers = await client.query<{ id: string; name: string; email: string | null }>(
    `SELECT id, name, email FROM public.providers
     WHERE deleted_at IS NULL AND import_source = 'MDPCZ'`,
  );

  const byName = new Map<string, { id: string; name: string; email: string | null }>();
  for (const p of providers.rows) {
    byName.set(normalizePersonName(p.name), p);
  }

  const result: PractitionerEmailImportResult = {
    totalRows: rawRows.length,
    matched: 0,
    updated: 0,
    skippedNoEmail: 0,
    skippedInvalidEmail: 0,
    unmatched: 0,
    phonesUpdated: 0,
    queuesResolved: 0,
    unmatchedNames: [],
  };

  for (const row of rawRows) {
    const nameRaw = row.raw.practitionerName ?? row.raw.name;
    if (!nameRaw) {
      result.unmatched++;
      continue;
    }

    const nameKey = normalizePersonName(String(nameRaw));
    const provider = byName.get(nameKey);
    if (!provider) {
      result.unmatched++;
      if (result.unmatchedNames.length < 25) {
        result.unmatchedNames.push(String(nameRaw));
      }
      continue;
    }

    result.matched++;

    const email = extractEmail(row.raw.email);
    if (!email) {
      result.skippedNoEmail++;
      continue;
    }

    const emailCheck = validateEmail(email);
    if (!emailCheck.valid) {
      result.skippedInvalidEmail++;
      logger.warn(`Invalid email on row ${row.rowNumber}`, { name: nameRaw, email });
      continue;
    }

    const phoneRaw = row.raw.phone ? String(row.raw.phone).trim() : null;
    const phone = phoneRaw ? await normalizePhoneDb(phoneRaw) : null;

    if (dryRun) {
      result.updated++;
      if (phone) result.phonesUpdated++;
      continue;
    }

    const update = await client.query<{ id: string }>(
      `UPDATE public.providers SET
         email = $2,
         phone = COALESCE($3, phone),
         updated_at = timezone('utc', now())
       WHERE id = $1
       RETURNING id`,
      [provider.id, email, phone],
    );

    if (update.rowCount) {
      result.updated++;
      if (phone) result.phonesUpdated++;
    }

    const queue = await client.query<{ id: string }>(
      `UPDATE public.import_review_queue SET
         status = 'resolved',
         resolved_at = timezone('utc', now()),
         resolution_notes = 'Email imported from practitioners spreadsheet'
       WHERE provider_id = $1
         AND queue_type = 'no_email_practitioner'
         AND status = 'pending'
       RETURNING id`,
      [provider.id],
    );
    result.queuesResolved += queue.rowCount ?? 0;
  }

  logger.info('Practitioner email import complete', result);
  return result;
}

const isDirectExecution =
  process.argv[1] != null &&
  resolve(process.argv[1]) === resolve(fileURLToPath(import.meta.url));

if (isDirectExecution) {
  const args = process.argv.slice(2).filter((a) => !a.startsWith('--'));
  const dryRun = process.argv.includes('--dry-run');

  if (args.length === 0) {
    console.error('Usage: npm run import:emails -- <practitioners.xlsx> [--dry-run]');
    process.exit(1);
  }

  withTransaction(async (client) => importPractitionerEmails(client, resolve(args[0]), dryRun))
    .then(() => closePool())
    .catch((err) => {
      logger.error('Email import failed', { error: err instanceof Error ? err.message : String(err) });
      process.exit(1);
    });
}
