import { randomUUID } from 'node:crypto';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadExcel } from './load_excel.js';
import { logger } from './logger.js';
import { query, closePool } from './db.js';
import { parseHpaFacilityRows } from './import_hpa_facilities.js';
import { parseMdpczRows } from './import_mdpcz_practitioners.js';
import { createSpecialtyMapper, loadSpecialtyData } from './specialty_mapper.js';
import type { ImportSource } from './types.js';

export async function runRegistryDiff(
  filePath: string,
  sourceType: ImportSource,
): Promise<{ runId: string; added: number; updated: number; removed: number }> {
  const runId = randomUUID();
  const rawRows = loadExcel(filePath);

  await query(
    `INSERT INTO public.registry_diff_runs (id, source_type, source_file, status)
     VALUES ($1, $2, $3, 'running')`,
    [runId, sourceType, filePath],
  );

  let added = 0;
  let updated = 0;
  let removed = 0;

  if (sourceType === 'HPA') {
    const { valid, ambiguous } = parseHpaFacilityRows(rawRows);
    const incomingKeys = new Map(valid.map((r) => [r.registryKey, r]));

    for (const group of ambiguous) {
      await query(
        `INSERT INTO public.registry_diff_items (
           run_id, entity_type, change_type, stable_key, raw_data, review_notes
         ) VALUES ($1, 'facility', 'added', $2, $3, 'Ambiguous facility in diff — manual review')`,
        [runId, `ambiguous-${group[0].rowNumber}`, JSON.stringify(group.map((g) => g.raw))],
      );
      added++;
    }

    const existing = await query<{ id: string; registry_key: string; name: string; address_line1: string; city: string }>(
      `SELECT id, registry_key, name, address_line1, city
       FROM public.facilities
       WHERE registry_key IS NOT NULL AND deleted_at IS NULL AND import_source = 'HPA'`,
    );

    const existingKeys = new Set(existing.rows.map((r) => r.registry_key));

    for (const row of valid) {
      if (!existingKeys.has(row.registryKey)) {
        await query(
          `INSERT INTO public.registry_diff_items (
             run_id, entity_type, change_type, stable_key, raw_data
           ) VALUES ($1, 'facility', 'added', $2, $3)`,
          [runId, row.registryKey, JSON.stringify(row.raw)],
        );
        added++;
      } else {
        const ex = existing.rows.find((r) => r.registry_key === row.registryKey)!;
        const changes: Record<string, { old: string; new: string }> = {};
        if (ex.name !== row.facilityName) changes.name = { old: ex.name, new: row.facilityName };
        if ((ex.address_line1 ?? '') !== row.address) changes.address = { old: ex.address_line1 ?? '', new: row.address };
        if ((ex.city ?? '') !== (row.city ?? '')) changes.city = { old: ex.city ?? '', new: row.city ?? '' };
        if (Object.keys(changes).length > 0) {
          await query(
            `INSERT INTO public.registry_diff_items (
               run_id, entity_type, change_type, entity_id, stable_key, field_changes, raw_data
             ) VALUES ($1, 'facility', 'updated', $2, $3, $4, $5)`,
            [runId, ex.id, row.registryKey, JSON.stringify(changes), JSON.stringify(row.raw)],
          );
          updated++;
        }
      }
    }

    for (const ex of existing.rows) {
      if (!incomingKeys.has(ex.registry_key)) {
        const claimed = await query<{ is_claimed: boolean }>(
          `SELECT is_claimed FROM public.facilities WHERE id = $1`,
          [ex.id],
        );
        await query(
          `INSERT INTO public.registry_diff_items (
             run_id, entity_type, change_type, entity_id, stable_key, field_changes, raw_data
           ) VALUES ($1, 'facility', 'removed', $2, $3, $4, $5)`,
          [
            runId,
            ex.id,
            ex.registry_key,
            JSON.stringify({ isClaimed: claimed.rows[0]?.is_claimed ?? false }),
            JSON.stringify({ note: 'Removed from HPA file — not auto-deleted' }),
          ],
        );
        removed++;
      }
    }
  } else if (sourceType === 'MDPCZ') {
    const { specialties, aliases } = await loadSpecialtyData(query);
    const specialtyMapper = createSpecialtyMapper(specialties, aliases);
    const specialtySlugToId = new Map(specialties.map((s) => [s.slug, s.id]));
    const { valid } = parseMdpczRows(rawRows, specialtyMapper.map, specialtySlugToId);
    const incomingKeys = new Map(valid.map((r) => [r.registryKey, r]));

    const existing = await query<{ id: string; registry_key: string; name: string; specialty: string; email: string; is_claimed: boolean }>(
      `SELECT id, registry_key, name, specialty, email, is_claimed
       FROM public.providers
       WHERE registry_key IS NOT NULL AND deleted_at IS NULL AND verified_source = 'MDPCZ'`,
    );

    const existingKeys = new Set(existing.rows.map((r) => r.registry_key));

    for (const row of valid) {
      if (!existingKeys.has(row.registryKey)) {
        await query(
          `INSERT INTO public.registry_diff_items (
             run_id, entity_type, change_type, stable_key, raw_data
           ) VALUES ($1, 'provider', 'added', $2, $3)`,
          [runId, row.registryKey, JSON.stringify(row.raw)],
        );
        added++;
      } else {
        const ex = existing.rows.find((r) => r.registry_key === row.registryKey)!;
        const changes: Record<string, { old: string; new: string }> = {};
        if (ex.name !== row.name.fullName) changes.name = { old: ex.name, new: row.name.fullName };
        if ((ex.specialty ?? '') !== (row.specialtyNormalized ?? '')) {
          changes.specialty = { old: ex.specialty ?? '', new: row.specialtyNormalized ?? '' };
        }
        if (row.email && ex.email !== row.email) changes.email = { old: ex.email ?? '', new: row.email };
        if (Object.keys(changes).length > 0) {
          await query(
            `INSERT INTO public.registry_diff_items (
               run_id, entity_type, change_type, entity_id, stable_key, field_changes, raw_data
             ) VALUES ($1, 'provider', 'updated', $2, $3, $4, $5)`,
            [runId, ex.id, row.registryKey, JSON.stringify(changes), JSON.stringify(row.raw)],
          );
          updated++;
        }
      }
    }

    for (const ex of existing.rows) {
      if (!incomingKeys.has(ex.registry_key)) {
        await query(
          `INSERT INTO public.registry_diff_items (
             run_id, entity_type, change_type, entity_id, stable_key, field_changes, raw_data
           ) VALUES ($1, 'provider', 'removed', $2, $3, $4, $5)`,
          [
            runId,
            ex.id,
            ex.registry_key,
            JSON.stringify({ isClaimed: ex.is_claimed }),
            JSON.stringify({ note: 'Removed from MDPCZ file — not auto-deleted' }),
          ],
        );
        removed++;
      }
    }
  }

  await query(
    `UPDATE public.registry_diff_runs SET
       status = 'completed',
       added_count = $2,
       updated_count = $3,
       removed_count = $4,
       completed_at = timezone('utc', now())
     WHERE id = $1`,
    [runId, added, updated, removed],
  );

  if (added + updated + removed > 0) {
    await query(
      `INSERT INTO public.notifications (
         user_id, channel, status, title, body, payload
       )
       SELECT p.id, 'in_app', 'pending',
              'Registry changes detected',
              $1,
              $2::jsonb
       FROM public.profiles p
       WHERE p.primary_role = 'super_admin' AND p.is_active = true`,
      [
        `${sourceType} diff: ${added} added, ${updated} updated, ${removed} removed`,
        JSON.stringify({ runId, sourceType, added, updated, removed }),
      ],
    );
    await query(
      `UPDATE public.registry_diff_runs SET notified_at = timezone('utc', now()) WHERE id = $1`,
      [runId],
    );
  }

  logger.info('Registry diff complete', { runId, sourceType, added, updated, removed });
  return { runId, added, updated, removed };
}

const isDirectExecution =
  process.argv[1] != null &&
  resolve(process.argv[1]) === resolve(fileURLToPath(import.meta.url));

if (isDirectExecution) {
  const file = process.argv[2];
  const source = (process.argv[3]?.toUpperCase() ?? 'HPA') as ImportSource;
  if (!file) {
    console.error('Usage: tsx registry_diff.ts <file.xlsx> [HPA|MDPCZ]');
    process.exit(1);
  }
  runRegistryDiff(file, source)
    .then(() => closePool())
    .catch((err) => {
      logger.error(String(err));
      process.exit(1);
    });
}
