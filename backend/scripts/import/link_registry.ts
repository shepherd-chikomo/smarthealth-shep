import type pg from 'pg';
import { logger } from './logger.js';
import { reverseNameKey, buildProviderRegistryKey } from './normalize_registry.js';
import { fetchImportResolutionRule } from './import_resolution_rules.js';

export async function linkRegistryDirectMatch(
  client: pg.PoolClient,
  batchId: string,
  providerNameIndex: Map<string, string>,
  dryRun: boolean,
): Promise<{ linked: number; manualAssociation: number; unlinkedPractitioners: number }> {
  const intents = await client.query<{
    facility_id: string;
    normalized_full_name: string;
  }>(
    `SELECT frih.facility_id, frih.normalized_full_name
     FROM public.facility_role_holder_intents frih
     JOIN public.facilities f ON f.id = frih.facility_id
     WHERE f.import_batch_id = $1`,
    [batchId],
  );

  let linked = 0;
  let manualAssociation = 0;

  for (const intent of intents.rows) {
    const linkRule = await fetchImportResolutionRule(
      client,
      'practitioner_facility_link',
      intent.normalized_full_name,
    );
    if (linkRule?.payload?.providerId && linkRule.payload?.facilityId) {
      const providerId = String(linkRule.payload.providerId);
      const facilityId = String(linkRule.payload.facilityId);
      if (!dryRun) {
        await client.query(
          `INSERT INTO public.provider_facility_links (
             provider_id, facility_id, link_type, is_primary, is_facility_role_holder,
             match_confidence, import_batch_id
           ) VALUES ($1, $2, 'primary', true, true, 'HIGH', $3)
           ON CONFLICT (provider_id, facility_id) DO UPDATE SET
             link_type = 'primary', is_facility_role_holder = true, is_primary = true`,
          [providerId, facilityId, batchId],
        );
        await client.query(
          `UPDATE public.providers SET facility_id = COALESCE(facility_id, $2), tenant_id = COALESCE(tenant_id, $2)
           WHERE id = $1`,
          [providerId, facilityId],
        );
      }
      linked++;
      continue;
    }

    const providerId =
      providerNameIndex.get(intent.normalized_full_name) ??
      providerNameIndex.get(reverseNameKey(intent.normalized_full_name));

    if (!providerId) {
      manualAssociation++;
      if (!dryRun) {
        const existing = await client.query<{ id: string }>(
          `SELECT id FROM public.import_review_queue
           WHERE queue_type = 'manual_association' AND facility_id = $1 AND status = 'pending'
           LIMIT 1`,
          [intent.facility_id],
        );
        if (!existing.rows[0]) {
          await client.query(
            `INSERT INTO public.import_review_queue (
               queue_type, facility_id, import_batch_id, notes
             ) VALUES ('manual_association', $1, $2, $3)`,
            [
              intent.facility_id,
              batchId,
              `No direct MDPCZ name match for: ${intent.normalized_full_name}`,
            ],
          );
        }
      }
      continue;
    }

    if (dryRun) {
      linked++;
      continue;
    }

    await client.query(
      `INSERT INTO public.provider_facility_links (
         provider_id, facility_id, link_type, is_primary, is_facility_role_holder,
         match_confidence, import_batch_id
       ) VALUES ($1, $2, 'primary', true, true, 'HIGH', $3)
       ON CONFLICT (provider_id, facility_id) DO UPDATE SET
         link_type = 'primary',
         is_facility_role_holder = true,
         is_primary = true`,
      [providerId, intent.facility_id, batchId],
    );

    await client.query(
      `UPDATE public.providers SET
         facility_id = COALESCE(facility_id, $2),
         tenant_id = COALESCE(tenant_id, $2)
       WHERE id = $1`,
      [providerId, intent.facility_id],
    );

    await client.query(
      `UPDATE public.import_review_queue SET status = 'resolved', resolution_notes = 'Auto-linked via direct name match'
       WHERE facility_id = $1 AND queue_type = 'manual_association' AND status = 'pending'`,
      [intent.facility_id],
    );

    linked++;
  }

  let unlinkedPractitioners = 0;

  if (!dryRun) {
    const unlinked = await client.query<{ id: string; registration_number: string | null; registry_key: string | null }>(
      `SELECT p.id, p.registration_number, p.registry_key FROM public.providers p
       WHERE p.import_batch_id = $1
         AND p.deleted_at IS NULL
         AND NOT EXISTS (
           SELECT 1 FROM public.provider_facility_links pfl WHERE pfl.provider_id = p.id
         )`,
      [batchId],
    );

    for (const row of unlinked.rows) {
      const stableKey = row.registry_key
        ?? (row.registration_number ? buildProviderRegistryKey(row.registration_number) : row.id);
      const noLinkRule = await fetchImportResolutionRule(client, 'practitioner_no_link', stableKey);
      if (noLinkRule) continue;

      const linkRule = await fetchImportResolutionRule(client, 'practitioner_facility_link', stableKey);
      if (linkRule?.payload?.facilityId && linkRule.payload?.providerId) {
        await client.query(
          `INSERT INTO public.provider_facility_links (
             provider_id, facility_id, link_type, is_primary, is_facility_role_holder, match_confidence
           ) VALUES ($1, $2, 'primary', true, true, 'HIGH')
           ON CONFLICT (provider_id, facility_id) DO NOTHING`,
          [String(linkRule.payload.providerId), String(linkRule.payload.facilityId)],
        );
        continue;
      }

      unlinkedPractitioners++;
      await client.query(
        `INSERT INTO public.import_review_queue (
           queue_type, provider_id, import_batch_id, notes
         ) VALUES ('unlinked_practitioner', $1, $2, 'No facility link after cross-reference')`,
        [row.id, batchId],
      );
    }
  } else {
    unlinkedPractitioners = providerNameIndex.size - linked;
  }

  logger.info(`Linking: ${linked} linked, ${manualAssociation} manual association, ${unlinkedPractitioners} unlinked practitioners`);

  return { linked, manualAssociation, unlinkedPractitioners };
}
