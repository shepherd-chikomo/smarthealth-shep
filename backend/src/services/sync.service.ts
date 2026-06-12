import { query } from '../lib/db.js';
import { assertFacilityAccess } from '../lib/facility-access.js';
import type { AuthenticatedUser } from '../lib/auth.js';

export async function bootstrap(
  user: AuthenticatedUser,
  facilityId: string,
) {
  await assertFacilityAccess(user, facilityId, ['doctor', 'receptionist', 'facility_admin']);

  const queue = await query(
    `SELECT q.id, q.queue_status AS status, q.ticket_number AS position,
            q.registered_at AS "arrivedAt", q.patient_id AS "patientId",
            q.priority AS "triageStatus"
     FROM public.walk_in_sessions q
     WHERE q.facility_id = $1 AND q.deleted_at IS NULL
       AND q.queue_status NOT IN ('completed', 'cancelled')
     ORDER BY q.ticket_number ASC`,
    [facilityId],
  );

  const appointments = await query(
    `SELECT id, patient_id AS "patientId", provider_id AS "providerId",
            status, scheduled_at AS "scheduledAt", reference_number AS "referenceNumber"
     FROM public.appointments
     WHERE facility_id = $1 AND scheduled_at >= CURRENT_DATE
     ORDER BY scheduled_at ASC LIMIT 100`,
    [facilityId],
  );

  return {
    queue: queue.rows,
    appointments: appointments.rows,
    syncedAt: new Date().toISOString(),
  };
}

export async function delta(
  user: AuthenticatedUser,
  facilityId: string,
  since: Date,
) {
  await assertFacilityAccess(user, facilityId, ['doctor', 'receptionist', 'facility_admin']);

  const appointments = await query(
    `SELECT id, patient_id AS "patientId", provider_id AS "providerId",
            status, scheduled_at AS "scheduledAt", reference_number AS "referenceNumber",
            updated_at AS "updatedAt"
     FROM public.appointments
     WHERE facility_id = $1 AND updated_at > $2
     ORDER BY updated_at ASC`,
    [facilityId, since.toISOString()],
  );

  const queue = await query(
    `SELECT id, patient_id AS "patientId", queue_status AS status,
            ticket_number AS position, registered_at AS "arrivedAt",
            updated_at AS "updatedAt"
     FROM public.walk_in_sessions
     WHERE facility_id = $1 AND updated_at > $2 AND deleted_at IS NULL`,
    [facilityId, since.toISOString()],
  );

  return {
    appointments: appointments.rows,
    queue: queue.rows,
    cursor: new Date().toISOString(),
  };
}

export async function applyMutations(
  user: AuthenticatedUser,
  facilityId: string,
  mutations: Array<{
    entityType: string;
    entityId: string;
    operation: string;
    payload: Record<string, unknown>;
  }>,
) {
  await assertFacilityAccess(user, facilityId, ['doctor', 'receptionist', 'facility_admin']);

  const applied: string[] = [];

  for (const m of mutations) {
    if (m.entityType === 'consultation' && m.operation === 'update') {
      const patch = m.payload;
      const sets = Object.keys(patch)
        .filter((k) =>
          [
            'chief_complaint',
            'history_of_present_illness',
            'past_medical_history',
            'examination_notes',
            'assessment',
            'plan',
          ].includes(k),
        )
        .map((k, i) => `${k} = $${i + 3}`)
        .join(', ');

      if (sets) {
        const values = [
          m.entityId,
          facilityId,
          ...Object.keys(patch)
            .filter((k) =>
              [
                'chief_complaint',
                'history_of_present_illness',
                'past_medical_history',
                'examination_notes',
                'assessment',
                'plan',
              ].includes(k),
            )
            .map((k) => patch[k]),
        ];
        await query(
          `UPDATE public.consultations SET ${sets}, updated_at = timezone('utc', now())
           WHERE id = $1 AND tenant_id = $2`,
          values,
        );
        applied.push(m.entityId);
      }
    }

    if (m.entityType === 'queue' && m.operation === 'updateStatus') {
      await query(
        `UPDATE public.walk_in_sessions SET queue_status = $3::queue_status, updated_at = timezone('utc', now())
         WHERE id = $1 AND facility_id = $2`,
        [m.entityId, facilityId, m.payload.status],
      );
      applied.push(m.entityId);
    }
  }

  return { applied, count: applied.length };
}
