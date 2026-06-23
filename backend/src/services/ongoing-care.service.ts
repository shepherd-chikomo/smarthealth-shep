import { query } from '../lib/db.js';

/** Sync patient-disclosed snapshot into facility-scoped clinical tables (Tier 2). */
export async function syncOngoingCareFromSnapshot(
  patientId: string,
  facilityId: string,
  snapshot: Record<string, unknown>,
): Promise<void> {
  const allergies = snapshot.allergies;
  if (typeof allergies === 'string' && allergies.trim()) {
    const existing = await query<{ id: string }>(
      `SELECT id FROM public.allergies
       WHERE patient_id = $1 AND tenant_id = $2 AND deleted_at IS NULL
         AND lower(allergen) = lower($3)
       LIMIT 1`,
      [patientId, facilityId, allergies.trim()],
    );
    if (existing.rows.length === 0) {
      await query(
        `INSERT INTO public.allergies (patient_id, tenant_id, allergen, severity, is_active)
         VALUES ($1, $2, $3, 'moderate', true)`,
        [patientId, facilityId, allergies.trim()],
      );
    }
  }

  const conditions = snapshot.conditions;
  if (Array.isArray(conditions)) {
    for (const raw of conditions) {
      const name = typeof raw === 'string' ? raw.trim() : '';
      if (!name) continue;
      const existing = await query<{ id: string }>(
        `SELECT id FROM public.chronic_conditions
         WHERE patient_id = $1 AND tenant_id = $2 AND deleted_at IS NULL
           AND lower(condition_name) = lower($3)
         LIMIT 1`,
        [patientId, facilityId, name],
      );
      if (existing.rows.length === 0) {
        await query(
          `INSERT INTO public.chronic_conditions (
             patient_id, tenant_id, condition_name, status
           ) VALUES ($1, $2, $3, 'active')`,
          [patientId, facilityId, name],
        );
      }
    }
  }
}

export async function hasOngoingCareConsent(
  patientId: string,
  facilityId: string,
): Promise<boolean> {
  const result = await query<{ exists: boolean }>(
    `SELECT EXISTS (
       SELECT 1 FROM public.patient_consents
       WHERE patient_id = $1 AND consent_type = 'facility_ongoing_care'
         AND withdrawn_at IS NULL
         AND metadata->>'facilityId' = $2
     ) AS exists`,
    [patientId, facilityId],
  );
  return result.rows[0]?.exists ?? false;
}
