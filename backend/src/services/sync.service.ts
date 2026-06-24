import { query } from '../lib/db.js';
import { assertFacilityAccess } from '../lib/facility-access.js';
import type { AuthenticatedUser } from '../lib/auth.js';

async function patientsForIds(patientIds: string[]) {
  const unique = [...new Set(patientIds.filter(Boolean))];
  if (unique.length === 0) return [];

  const rows = await query(
    `SELECT pr.id, pr.first_name AS "firstName", pr.last_name AS "lastName",
            pr.phone, pr.email, pr.date_of_birth AS "dateOfBirth", pr.gender,
            pr.national_id AS "nationalId", pr.metadata
     FROM public.profiles pr
     WHERE pr.id = ANY($1::uuid[])`,
    [unique],
  );

  return rows.rows.map((r) => {
    const meta = (r.metadata ?? {}) as Record<string, unknown>;
    const medicalAid = meta.medicalAid as Record<string, unknown> | undefined;
    return {
      id: r.id,
      firstName: r.firstName,
      lastName: r.lastName,
      phone: r.phone,
      email: r.email,
      dateOfBirth: r.dateOfBirth,
      gender: r.gender,
      nationalId: r.nationalId,
      smarthealthPatientId: meta.smarthealthPatientId ?? null,
      insuranceInfo: medicalAid?.provider ?? medicalAid?.scheme ?? null,
      metadata: meta,
    };
  });
}

const CONSULTATION_FIELDS = [
  'chief_complaint',
  'history_of_present_illness',
  'past_medical_history',
  'surgical_history',
  'family_history',
  'social_history',
  'examination_notes',
  'assessment',
  'plan',
  'follow_up_plan',
] as const;

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

  const patientIds = [
    ...queue.rows.map((r) => r.patientId as string),
    ...appointments.rows.map((r) => r.patientId as string),
  ];
  const patients = await patientsForIds(patientIds);

  return {
    queue: queue.rows,
    appointments: appointments.rows,
    patients,
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
            priority AS "triageStatus", updated_at AS "updatedAt"
     FROM public.walk_in_sessions
     WHERE facility_id = $1 AND updated_at > $2 AND deleted_at IS NULL`,
    [facilityId, since.toISOString()],
  );

  const patientIds = [
    ...queue.rows.map((r) => r.patientId as string),
    ...appointments.rows.map((r) => r.patientId as string),
  ];
  const patients = await patientsForIds(patientIds);

  return {
    appointments: appointments.rows,
    queue: queue.rows,
    patients,
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
    if (m.entityType === 'consultation' && m.operation === 'create') {
      const patientId = m.payload.patient_id as string;
      const providerId = m.payload.provider_id as string;
      const result = await query<{ id: string }>(
        `INSERT INTO public.consultations (
           facility_id, tenant_id, provider_id, patient_id,
           appointment_id, walk_in_session_id, status, started_at
         ) VALUES ($1, $1, $2, $3, $4, $5, 'in_progress', timezone('utc', now()))
         RETURNING id`,
        [
          facilityId,
          providerId,
          patientId,
          (m.payload.appointment_id as string | undefined) ?? null,
          (m.payload.walk_in_session_id as string | undefined) ?? null,
        ],
      );
      applied.push(result.rows[0]!.id);
      continue;
    }

    if (m.entityType === 'consultation' && m.operation === 'update') {
      const patch = m.payload;
      const sets = CONSULTATION_FIELDS.filter((k) => patch[k] !== undefined)
        .map((k, i) => `${k} = $${i + 3}`)
        .join(', ');

      if (sets) {
        const values = [
          m.entityId,
          facilityId,
          ...CONSULTATION_FIELDS.filter((k) => patch[k] !== undefined).map(
            (k) => patch[k],
          ),
        ];
        await query(
          `UPDATE public.consultations SET ${sets}, updated_at = timezone('utc', now())
           WHERE id = $1 AND tenant_id = $2`,
          values,
        );
        applied.push(m.entityId);
      }
      continue;
    }

    if (m.entityType === 'consultation' && m.operation === 'complete') {
      await query(
        `UPDATE public.consultations
         SET status = 'completed', completed_at = timezone('utc', now()),
             updated_at = timezone('utc', now())
         WHERE id = $1 AND tenant_id = $2`,
        [m.entityId, facilityId],
      );
      applied.push(m.entityId);
      continue;
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
