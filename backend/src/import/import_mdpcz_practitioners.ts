import { createHash } from 'node:crypto';
import type pg from 'pg';
import { loadExcel } from './load_excel.js';
import { logger } from './logger.js';
import { parseName } from './normalize_data.js';
import {
  buildFullNameKey,
  buildProviderRegistryKey,
  normalizeMdpczNumber,
  reverseNameKey,
} from './normalize_registry.js';
import { createSpecialtyMapper, loadSpecialtyData } from './specialty_mapper.js';
import { generateProviderSlug, ensureUniqueSlug } from './generate_slugs.js';
import { query } from './db.js';
import { fetchImportResolutionRule } from './import_resolution_rules.js';
import type { RawSpreadsheetRow, NormalizedProvider } from './types.js';

export interface MdpczPractitionerRow {
  rowNumber: number;
  name: NonNullable<ReturnType<typeof parseName>>;
  registrationNumber: string;
  gender: string | null;
  qualification: string | null;
  specialtyRaw: string | null;
  specialtyNormalized: string | null;
  specialtySlug: string | null;
  specialtyId: string | null;
  email: string | null;
  normalizedNameKey: string;
  registryKey: string;
  rowHash: string;
  raw: Record<string, unknown>;
}

function parseGender(raw: unknown): string | null {
  if (!raw) return null;
  const g = String(raw).trim().toLowerCase();
  if (g.startsWith('m')) return 'male';
  if (g.startsWith('f')) return 'female';
  if (g === 'other') return 'other';
  return null;
}

export function parseMdpczRows(
  rawRows: RawSpreadsheetRow[],
  specialtyMapper: ReturnType<typeof createSpecialtyMapper>['map'],
  specialtySlugToId: Map<string, string>,
): {
  valid: MdpczPractitionerRow[];
  failed: { rowNumber: number; error: string; raw: Record<string, unknown> }[];
} {
  const valid: MdpczPractitionerRow[] = [];
  const failed: { rowNumber: number; error: string; raw: Record<string, unknown> }[] = [];

  for (const row of rawRows) {
    const regRaw = row.raw.registrationNumber ?? row.raw.mdpczNumber;
    const registrationNumber = regRaw ? normalizeMdpczNumber(String(regRaw)) : '';

    if (!registrationNumber) {
      failed.push({
        rowNumber: row.rowNumber,
        error: 'Missing registration number',
        raw: row.raw,
      });
      continue;
    }

    const nameRaw = row.raw.practitionerName ?? row.raw.name;
    const parsed = parseName(nameRaw ? String(nameRaw) : null);
    if (!parsed) {
      failed.push({
        rowNumber: row.rowNumber,
        error: 'Missing or invalid practitioner name',
        raw: row.raw,
      });
      continue;
    }

    const specialtyRaw = row.raw.specialty ? String(row.raw.specialty).trim() : null;
    const specialtyResult = specialtyMapper(specialtyRaw);

    valid.push({
      rowNumber: row.rowNumber,
      name: parsed,
      registrationNumber,
      gender: parseGender(row.raw.gender),
      qualification: row.raw.qualification ? String(row.raw.qualification).trim() : null,
      specialtyRaw,
      specialtyNormalized: specialtyResult.name,
      specialtySlug: specialtyResult.slug,
      specialtyId: specialtyResult.slug ? specialtySlugToId.get(specialtyResult.slug) ?? null : null,
      email: row.raw.email ? String(row.raw.email).trim().toLowerCase() : null,
      normalizedNameKey: buildFullNameKey(parsed.firstName, parsed.lastName),
      registryKey: buildProviderRegistryKey(registrationNumber),
      rowHash: createHash('sha256').update(JSON.stringify(row.raw)).digest('hex'),
      raw: row.raw,
    });
  }

  return { valid, failed };
}

export async function importMdpczPractitioners(
  client: pg.PoolClient,
  filePath: string,
  batchId: string,
  dryRun: boolean,
): Promise<{
  created: number;
  failed: number;
  noEmail: number;
  providerNameIndex: Map<string, string>;
}> {
  const rawRows = loadExcel(filePath);
  const { specialties, aliases } = await loadSpecialtyData(query);
  const specialtyMapper = createSpecialtyMapper(specialties, aliases);
  const specialtySlugToId = new Map(specialties.map((s) => [s.slug, s.id]));

  const { valid, failed } = parseMdpczRows(rawRows, specialtyMapper.map, specialtySlugToId);

  logger.info(`MDPCZ: ${valid.length} practitioners, ${failed.length} failed`);

  const providerNameIndex = new Map<string, string>();
  let created = 0;
  let noEmail = 0;

  if (dryRun) {
    for (const row of valid) {
      providerNameIndex.set(row.normalizedNameKey, `dry-run-${row.registrationNumber}`);
    }
    return {
      created: valid.length,
      failed: failed.length,
      noEmail: valid.filter((r) => !r.email).length,
      providerNameIndex,
    };
  }

  for (const fail of failed) {
    await client.query(
      `INSERT INTO public.failed_imports (
         import_batch_id, row_number, entity_type, raw_data, error_code, error_message
       ) VALUES ($1, $2, 'provider', $3, 'VALIDATION_FAILED', $4)`,
      [batchId, fail.rowNumber, JSON.stringify(fail.raw), fail.error],
    );
  }

  const slugUsed = new Set<string>();
  // Seed with slugs already persisted so re-imports don't collide on the
  // unique provider slug constraint (new rows get a -N suffix).
  const existingProviderSlugs = await client.query<{ slug: string }>(
    `SELECT slug FROM public.providers WHERE slug IS NOT NULL`,
  );
  for (const r of existingProviderSlugs.rows) slugUsed.add(r.slug);

  for (const row of valid) {
    const slug = ensureUniqueSlug(
      generateProviderSlug({
        rowNumber: row.rowNumber,
        rowHash: row.rowHash,
        source: 'MDPCZ',
        name: row.name,
        facilityName: null,
        registrationNumber: row.registrationNumber,
        mdpczNumber: row.registrationNumber,
        specialtyRaw: row.specialtyRaw,
        specialtyNormalized: row.specialtyNormalized,
        specialtySlug: row.specialtySlug,
        profession: null,
        address: null,
        province: null,
        city: null,
        phone: null,
        email: row.email,
        licenseStatus: null,
        practiceType: null,
        facilityCategory: null,
        ownershipType: null,
        latitude: null,
        longitude: null,
        gpsRaw: null,
        slug: null,
        searchKeywords: [],
        validationErrors: [],
        warnings: [],
      } as NormalizedProvider),
      slugUsed,
    );

    const insert = await client.query<{ id: string }>(
      `INSERT INTO public.providers (
         name, slug, title, first_name, middle_name, last_name,
         registration_number, mdpcz_number, specialty, specialty_id,
         gender, qualification, email,
         is_verified, is_claimed, verified_source, verified_status,
         facility_id, tenant_id,
         import_batch_id, import_source, import_row_hash, registry_key,
         search_keywords
       ) VALUES (
         $1, $2, $3, $4, $5, $6,
         $7, $8, $9, $10,
         $11::public.gender, $12, $13,
         false, false, 'MDPCZ', 'pending',
         NULL, NULL,
         $14, 'MDPCZ', $15, $16,
         $17
       )
       ON CONFLICT (registry_key) WHERE registry_key IS NOT NULL AND deleted_at IS NULL
       DO UPDATE SET
         name = EXCLUDED.name,
         specialty = EXCLUDED.specialty,
         specialty_id = EXCLUDED.specialty_id,
         gender = EXCLUDED.gender,
         qualification = EXCLUDED.qualification,
         email = COALESCE(EXCLUDED.email, providers.email),
         import_batch_id = EXCLUDED.import_batch_id
       RETURNING id`,
      [
        row.name.fullName,
        slug,
        row.name.title,
        row.name.firstName,
        row.name.middleName,
        row.name.lastName,
        row.registrationNumber,
        row.registrationNumber,
        row.specialtyNormalized,
        row.specialtyId,
        row.gender,
        row.qualification,
        row.email,
        batchId,
        row.rowHash,
        row.registryKey,
        [
          row.name.fullName.toLowerCase(),
          row.registrationNumber.toLowerCase(),
          row.specialtyNormalized?.toLowerCase() ?? '',
        ].filter(Boolean),
      ],
    );

    const providerId = insert.rows[0].id;
    providerNameIndex.set(row.normalizedNameKey, providerId);
    const reversedKey = reverseNameKey(row.normalizedNameKey);
    if (reversedKey !== row.normalizedNameKey) {
      providerNameIndex.set(reversedKey, providerId);
    }
    created++;

    if (row.specialtyId) {
      await client.query(
        `INSERT INTO public.provider_specialties (provider_id, specialty_id, is_primary, source, import_batch_id)
         VALUES ($1, $2, true, 'MDPCZ', $3)
         ON CONFLICT (provider_id, specialty_id) DO NOTHING`,
        [providerId, row.specialtyId, batchId],
      );
    }

    if (!row.email) {
      const emailRule = await fetchImportResolutionRule(client, 'provider_email_override', row.registryKey);
      const manualRule = await fetchImportResolutionRule(client, 'provider_manual_claim_allowed', row.registryKey);
      if (emailRule?.payload?.email) {
        await client.query(`UPDATE public.providers SET email = $2 WHERE id = $1`, [
          providerId,
          String(emailRule.payload.email),
        ]);
      } else if (!manualRule) {
        noEmail++;
        await client.query(
          `INSERT INTO public.import_review_queue (
             queue_type, provider_id, import_batch_id, row_number, raw_data, notes
           ) VALUES ('no_email_practitioner', $1, $2, $3, $4, 'No email — manual claim only')`,
          [providerId, batchId, row.rowNumber, JSON.stringify(row.raw)],
        );
      }
    }
  }

  return { created, failed: failed.length, noEmail, providerNameIndex };
}
