import { query } from '../lib/db.js';
import { NotFoundError } from '../lib/errors.js';

export interface EncounterSummaryRecord {
  id: string;
  appointmentId: string | null;
  consultationId: string;
  providerId: string | null;
  chiefComplaint: string | null;
  assessment: string | null;
  plan: string | null;
  prescriptionsSummary: string | null;
  createdAt: string;
}

function mapRow(row: {
  id: string;
  appointment_id: string | null;
  consultation_id: string;
  provider_id: string | null;
  chief_complaint: string | null;
  assessment: string | null;
  plan: string | null;
  prescriptions_summary: string | null;
  created_at: Date;
}): EncounterSummaryRecord {
  return {
    id: row.id,
    appointmentId: row.appointment_id,
    consultationId: row.consultation_id,
    providerId: row.provider_id,
    chiefComplaint: row.chief_complaint,
    assessment: row.assessment,
    plan: row.plan,
    prescriptionsSummary: row.prescriptions_summary,
    createdAt: row.created_at.toISOString(),
  };
}

export async function createEncounterSummaryFromConsultation(
  consultationId: string,
  tenantId: string,
): Promise<EncounterSummaryRecord | null> {
  const consultation = await query<{
    id: string;
    patient_id: string;
    provider_id: string;
    appointment_id: string | null;
    chief_complaint: string | null;
    assessment: string | null;
    plan: string | null;
  }>(
    `SELECT id, patient_id, provider_id, appointment_id, chief_complaint, assessment, plan
     FROM public.consultations
     WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
    [consultationId, tenantId],
  );
  const row = consultation.rows[0];
  if (!row) return null;

  let receiveSummary = false;
  let appointmentId = row.appointment_id;
  if (appointmentId) {
    const appt = await query<{ metadata: Record<string, unknown> }>(
      `SELECT metadata FROM public.appointments WHERE id = $1`,
      [appointmentId],
    );
    receiveSummary = appt.rows[0]?.metadata?.receiveEncounterSummary === true;
  } else {
    const appt = await query<{ id: string; metadata: Record<string, unknown> }>(
      `SELECT id, metadata FROM public.appointments
       WHERE patient_id = $1 AND tenant_id = $2 AND deleted_at IS NULL
         AND COALESCE((metadata->>'receiveEncounterSummary')::boolean, false) = true
         AND scheduled_at::date <= timezone('utc', now())::date
       ORDER BY scheduled_at DESC LIMIT 1`,
      [row.patient_id, tenantId],
    );
    if (appt.rows[0]) {
      receiveSummary = true;
      appointmentId = appt.rows[0].id;
    }
  }

  if (!receiveSummary) return null;

  const rx = await query<{ medications: unknown; instructions: string | null }>(
    `SELECT medications, instructions FROM public.prescriptions
     WHERE consultation_id = $1 AND deleted_at IS NULL
     ORDER BY created_at DESC LIMIT 1`,
    [consultationId],
  );

  let prescriptionsSummary: string | null = null;
  const rxRow = rx.rows[0];
  if (rxRow) {
    const meds = Array.isArray(rxRow.medications)
      ? rxRow.medications
          .map((m) =>
            typeof m === 'object' && m && 'name' in m
              ? String((m as { name: string }).name)
              : String(m),
          )
          .join(', ')
      : null;
    prescriptionsSummary = [meds, rxRow.instructions].filter(Boolean).join(' — ') || null;
  }

  const existing = await query<{ id: string }>(
    `SELECT id FROM public.encounter_summaries WHERE consultation_id = $1`,
    [consultationId],
  );
  if (existing.rows[0]) {
    const full = await query<{
      id: string;
      appointment_id: string | null;
      consultation_id: string;
      provider_id: string | null;
      chief_complaint: string | null;
      assessment: string | null;
      plan: string | null;
      prescriptions_summary: string | null;
      created_at: Date;
    }>(
      `SELECT id, appointment_id, consultation_id, provider_id,
              chief_complaint, assessment, plan, prescriptions_summary, created_at
       FROM public.encounter_summaries WHERE consultation_id = $1`,
      [consultationId],
    );
    return full.rows[0] ? mapRow(full.rows[0]) : null;
  }

  const inserted = await query<{
    id: string;
    appointment_id: string | null;
    consultation_id: string;
    provider_id: string | null;
    chief_complaint: string | null;
    assessment: string | null;
    plan: string | null;
    prescriptions_summary: string | null;
    created_at: Date;
  }>(
    `INSERT INTO public.encounter_summaries (
       tenant_id, patient_id, appointment_id, consultation_id, provider_id,
       chief_complaint, assessment, plan, prescriptions_summary
     ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
     RETURNING id, appointment_id, consultation_id, provider_id,
               chief_complaint, assessment, plan, prescriptions_summary, created_at`,
    [
      tenantId,
      row.patient_id,
      appointmentId,
      consultationId,
      row.provider_id,
      row.chief_complaint,
      row.assessment,
      row.plan,
      prescriptionsSummary,
    ],
  );

  return inserted.rows[0] ? mapRow(inserted.rows[0]) : null;
}

export async function getEncounterSummaryForAppointment(
  patientId: string,
  appointmentId: string,
): Promise<EncounterSummaryRecord> {
  const result = await query<{
    id: string;
    appointment_id: string | null;
    consultation_id: string;
    provider_id: string | null;
    chief_complaint: string | null;
    assessment: string | null;
    plan: string | null;
    prescriptions_summary: string | null;
    created_at: Date;
  }>(
    `SELECT id, appointment_id, consultation_id, provider_id,
            chief_complaint, assessment, plan, prescriptions_summary, created_at
     FROM public.encounter_summaries
     WHERE patient_id = $1 AND appointment_id = $2
     ORDER BY created_at DESC LIMIT 1`,
    [patientId, appointmentId],
  );
  if (!result.rows[0]) {
    throw new NotFoundError('Encounter summary', appointmentId);
  }
  return mapRow(result.rows[0]);
}
