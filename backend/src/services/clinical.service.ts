import { query } from '../lib/db.js';
import { assertFacilityAccess } from '../lib/facility-access.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import {
  extractDisclosureFromAppointment,
  type AppointmentDisclosureRow,
} from '../lib/care-disclosure.js';
import { logMedicalAccess } from '../lib/medical-access-log.js';
import type { RequestContext } from '../lib/request-context.js';
import { ForbiddenError, NotFoundError, ValidationError } from '../lib/errors.js';
import * as consentService from './consent.service.js';
import { createEncounterSummaryFromConsultation } from './encounter-summary.service.js';
import { hasOngoingCareConsent } from './ongoing-care.service.js';

async function hasCareRelationship(
  patientId: string,
  facilityId: string,
): Promise<boolean> {
  const result = await query<{ exists: boolean }>(
    `SELECT (
       EXISTS (
         SELECT 1 FROM public.appointments a
         WHERE a.patient_id = $1 AND a.tenant_id = $2 AND a.deleted_at IS NULL
           AND a.status NOT IN ('cancelled')
           AND (
             a.scheduled_at >= timezone('utc', now()) - interval '12 months'
             OR a.status IN ('checked_in', 'in_progress', 'completed')
           )
       )
       OR EXISTS (
         SELECT 1 FROM public.walk_in_sessions w
         WHERE w.patient_id = $1 AND w.facility_id = $2
           AND w.created_at >= timezone('utc', now()) - interval '12 months'
       )
     ) AS exists`,
    [patientId, facilityId],
  );
  return result.rows[0]?.exists ?? false;
}

async function loadActiveDisclosure(
  patientId: string,
  facilityId: string,
): Promise<ReturnType<typeof extractDisclosureFromAppointment>> {
  const hasConsent = await consentService.hasActiveConsent(
    patientId,
    'facility_phi_share',
    facilityId,
  );
  if (!hasConsent) return null;

  const appt = await query<AppointmentDisclosureRow>(
    `SELECT id, metadata, scheduled_at
     FROM public.appointments
     WHERE patient_id = $1 AND tenant_id = $2 AND deleted_at IS NULL
       AND metadata ? 'sharedProfileSnapshot'
     ORDER BY scheduled_at DESC
     LIMIT 1`,
    [patientId, facilityId],
  );

  return extractDisclosureFromAppointment(appt.rows[0]);
}

export async function getPatientChart(
  user: AuthenticatedUser,
  facilityId: string,
  patientId: string,
  context?: RequestContext,
) {
  await assertFacilityAccess(user, facilityId, ['doctor', 'receptionist', 'facility_admin']);

  const hasRelationship = await hasCareRelationship(patientId, facilityId);
  if (!hasRelationship) {
    throw new ForbiddenError('No active care relationship with this patient');
  }

  const profile = await query<{
    id: string;
    first_name: string | null;
    last_name: string | null;
    phone: string | null;
    email: string | null;
    national_id: string | null;
    date_of_birth: string | null;
    gender: string | null;
  }>(
    `SELECT id, first_name, last_name, phone, email, national_id, date_of_birth, gender
     FROM public.profiles WHERE id = $1`,
    [patientId],
  );

  if (profile.rows.length === 0) {
    throw new NotFoundError('Patient not found');
  }

  const disclosure = await loadActiveDisclosure(patientId, facilityId);
  const ongoingCare = await hasOngoingCareConsent(patientId, facilityId);

  let allergies: unknown[] = [];
  let conditions: unknown[] = [];

  if (ongoingCare) {
    const allergyRows = await query(
      `SELECT id, allergen, severity, is_active FROM public.allergies
       WHERE patient_id = $1 AND tenant_id = $2 AND deleted_at IS NULL AND is_active = true`,
      [patientId, facilityId],
    );
    allergies = allergyRows.rows;

    const conditionRows = await query(
      `SELECT id, condition_name, icd10_code, icd11_code, status FROM public.chronic_conditions
       WHERE patient_id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
      [patientId, facilityId],
    );
    conditions = conditionRows.rows;
  }

  const consultations = await query(
    `SELECT id, status, chief_complaint, assessment, plan, started_at, completed_at, provider_id
     FROM public.consultations
     WHERE patient_id = $1 AND tenant_id = $2 AND deleted_at IS NULL
     ORDER BY created_at DESC LIMIT 50`,
    [patientId, facilityId],
  );

  const prescriptions = await query(
    `SELECT id, medications, instructions, issued_at, status
     FROM public.prescriptions
     WHERE patient_id = $1 AND tenant_id = $2 AND deleted_at IS NULL
     ORDER BY created_at DESC LIMIT 50`,
    [patientId, facilityId],
  );

  await logMedicalAccess({
    actorId: user.id,
    patientId,
    resourceType: 'patient_chart',
    resourceId: patientId,
    action: 'read',
    tenantId: facilityId,
    context,
    details: {
      disclosureActive: disclosure != null,
      ongoingCare,
      appointmentId: disclosure?.appointmentId ?? null,
    },
  });

  const p = profile.rows[0]!;
  return {
    patient: {
      id: p.id,
      firstName: p.first_name,
      lastName: p.last_name,
      phone: p.phone,
      email: p.email,
      nationalId: p.national_id,
      dateOfBirth: p.date_of_birth,
      gender: p.gender,
    },
    disclosure: disclosure
      ? {
          active: true,
          purpose: disclosure.purpose,
          validUntil: disclosure.validUntil,
          appointmentId: disclosure.appointmentId,
          shareProfile: disclosure.shareProfile,
        }
      : { active: false },
    sharedProfileSnapshot: disclosure?.sharedProfileSnapshot ?? null,
    allergies,
    conditions,
    timeline: consultations.rows.map((c) => ({
      type: 'consultation',
      ...c,
    })),
    prescriptions: prescriptions.rows,
  };
}

export async function createConsultation(
  user: AuthenticatedUser,
  facilityId: string,
  body: {
    patientId: string;
    providerId: string;
    appointmentId?: string;
    walkInSessionId?: string;
  },
) {
  await assertFacilityAccess(user, facilityId, ['doctor', 'facility_admin']);

  const result = await query<{ id: string }>(
    `INSERT INTO public.consultations (
       facility_id, tenant_id, provider_id, patient_id,
       appointment_id, walk_in_session_id, status, started_at
     ) VALUES ($1, $1, $2, $3, $4, $5, 'in_progress', timezone('utc', now()))
     RETURNING id`,
    [
      facilityId,
      body.providerId,
      body.patientId,
      body.appointmentId ?? null,
      body.walkInSessionId ?? null,
    ],
  );

  return { id: result.rows[0]!.id };
}

export async function updateConsultation(
  user: AuthenticatedUser,
  facilityId: string,
  consultationId: string,
  patch: Record<string, unknown>,
) {
  await assertFacilityAccess(user, facilityId, ['doctor', 'facility_admin']);

  const allowed = [
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
    'follow_up_date',
  ] as const;

  const sets: string[] = [];
  const values: unknown[] = [consultationId, facilityId];
  let idx = 3;

  for (const key of allowed) {
    if (patch[key] !== undefined) {
      sets.push(`${key} = $${idx}`);
      values.push(patch[key]);
      idx++;
    }
  }

  if (sets.length === 0) {
    throw new ValidationError('No valid fields to update');
  }

  const result = await query(
    `UPDATE public.consultations SET ${sets.join(', ')}, updated_at = timezone('utc', now())
     WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
     RETURNING *`,
    values,
  );

  if (result.rows.length === 0) {
    throw new NotFoundError('Consultation not found');
  }

  return result.rows[0];
}

export async function completeConsultation(
  user: AuthenticatedUser,
  facilityId: string,
  consultationId: string,
) {
  await assertFacilityAccess(user, facilityId, ['doctor', 'facility_admin']);

  const result = await query(
    `UPDATE public.consultations
     SET status = 'completed', completed_at = timezone('utc', now()), updated_at = timezone('utc', now())
     WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
     RETURNING *`,
    [consultationId, facilityId],
  );

  if (result.rows.length === 0) {
    throw new NotFoundError('Consultation not found');
  }

  const consultation = result.rows[0] as {
    id: string;
    patient_id: string;
    tenant_id: string;
    provider_id: string;
    appointment_id: string | null;
  };

  const summary = await createEncounterSummaryFromConsultation(
    consultationId,
    facilityId,
  );
  await notifyEncounterSummaryReady(consultation, summary?.appointmentId ?? null);

  return consultation;
}

async function notifyEncounterSummaryReady(
  consultation: {
    id: string;
    patient_id: string;
    tenant_id: string;
  },
  appointmentId: string | null,
) {
  if (!appointmentId) {
    const appt = await query<{ id: string }>(
      `SELECT id FROM public.appointments
       WHERE patient_id = $1 AND tenant_id = $2 AND deleted_at IS NULL
         AND COALESCE((metadata->>'receiveEncounterSummary')::boolean, false) = true
         AND scheduled_at::date <= timezone('utc', now())::date
       ORDER BY scheduled_at DESC
       LIMIT 1`,
      [consultation.patient_id, consultation.tenant_id],
    );
    appointmentId = appt.rows[0]?.id ?? null;
  }

  if (!appointmentId) return;

  await query(
    `SELECT public.enqueue_notification(
      p_user_id := $1,
      p_tenant_id := $2,
      p_category := 'provider_message'::public.notification_category,
      p_title := 'Visit summary ready',
      p_body := 'Your practitioner has shared notes from your recent visit.',
      p_action_url := $3,
      p_payload := $4::jsonb,
      p_dedupe_key := $5,
      p_priority := 2::smallint
    )`,
    [
      consultation.patient_id,
      consultation.tenant_id,
      `/appointments/${appointmentId}`,
      JSON.stringify({
        consultationId: consultation.id,
        appointmentId,
      }),
      `encounter_summary:${consultation.id}`,
    ],
  );
}

export async function addDiagnosis(
  user: AuthenticatedUser,
  facilityId: string,
  consultationId: string,
  body: {
    description: string;
    icd10Code?: string;
    icd11Code?: string;
    isPrimary?: boolean;
    providerId: string;
    patientId: string;
  },
) {
  await assertFacilityAccess(user, facilityId, ['doctor', 'facility_admin']);

  const result = await query<{ id: string }>(
    `INSERT INTO public.diagnoses (
       consultation_id, tenant_id, patient_id, provider_id,
       description, icd10_code, icd11_code, is_primary
     ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
     RETURNING id`,
    [
      consultationId,
      facilityId,
      body.patientId,
      body.providerId,
      body.description,
      body.icd10Code ?? null,
      body.icd11Code ?? null,
      body.isPrimary ?? false,
    ],
  );

  return { id: result.rows[0]!.id };
}

export async function recordVitals(
  user: AuthenticatedUser,
  facilityId: string,
  body: {
    consultationId?: string;
    patientId: string;
    temperatureCelsius?: number;
    pulseBpm?: number;
    bloodPressureSystolic?: number;
    bloodPressureDiastolic?: number;
    oxygenSaturation?: number;
    weightKg?: number;
    heightCm?: number;
  },
) {
  await assertFacilityAccess(user, facilityId, ['doctor', 'receptionist', 'facility_admin']);

  const result = await query<{ id: string }>(
    `INSERT INTO public.vitals (
       consultation_id, tenant_id, patient_id, recorded_by,
       temperature_celsius, pulse_bpm, blood_pressure_systolic,
       blood_pressure_diastolic, oxygen_saturation, weight_kg, height_cm
     ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
     RETURNING id`,
    [
      body.consultationId ?? null,
      facilityId,
      body.patientId,
      user.id,
      body.temperatureCelsius ?? null,
      body.pulseBpm ?? null,
      body.bloodPressureSystolic ?? null,
      body.bloodPressureDiastolic ?? null,
      body.oxygenSaturation ?? null,
      body.weightKg ?? null,
      body.heightCm ?? null,
    ],
  );

  return { id: result.rows[0]!.id };
}

export async function createPrescription(
  user: AuthenticatedUser,
  facilityId: string,
  body: {
    consultationId: string;
    patientId: string;
    providerId: string;
    medication: string;
    dosage?: string;
    frequency?: string;
    duration?: string;
    instructions?: string;
  },
) {
  await assertFacilityAccess(user, facilityId, ['doctor', 'facility_admin']);

  const result = await query<{ id: string }>(
    `INSERT INTO public.prescriptions (
       facility_id, tenant_id, patient_id, provider_id, consultation_id,
       medications, instructions, status, issued_at
     ) VALUES ($1, $1, $2, $3, $4, $5::jsonb, $6, 'issued', timezone('utc', now()))
     RETURNING id`,
    [
      facilityId,
      body.patientId,
      body.providerId,
      body.consultationId,
      JSON.stringify([
        {
          name: body.medication,
          dosage: body.dosage ?? null,
          frequency: body.frequency ?? null,
          duration: body.duration ?? null,
        },
      ]),
      body.instructions ?? null,
    ],
  );

  return { id: result.rows[0]!.id };
}

export async function searchIcd11(q: string, limit = 20) {
  const result = await query<{ code: string; description: string }>(
    `SELECT code, description FROM public.icd11_codes
     WHERE code ILIKE $1 OR description ILIKE $1
     ORDER BY code LIMIT $2`,
    [`%${q}%`, limit],
  );
  return result.rows;
}

export async function getEdlizForDiagnosis(icd11Code: string) {
  const result = await query(
    `SELECT id, icd11_code, first_line, alternative, recommended_dosage, recommended_formulation
     FROM public.edliz_formulary WHERE icd11_code = $1`,
    [icd11Code],
  );
  return result.rows;
}

export async function getClaimsSummary(
  user: AuthenticatedUser,
  facilityId: string,
) {
  await assertFacilityAccess(user, facilityId, ['doctor', 'facility_admin', 'receptionist']);

  const result = await query<{ status: string; count: string; total: string }>(
    `SELECT status, COUNT(*)::text AS count, COALESCE(SUM(amount), 0)::text AS total
     FROM public.insurance_claims
     WHERE tenant_id = $1
     GROUP BY status`,
    [facilityId],
  );

  return result.rows.map((r) => ({
    status: r.status,
    count: Number(r.count),
    total: Number(r.total),
  }));
}

export async function listClaims(
  user: AuthenticatedUser,
  facilityId: string,
  status?: string,
) {
  await assertFacilityAccess(user, facilityId, ['doctor', 'facility_admin', 'receptionist']);

  const result = await query(
    status
      ? `SELECT * FROM public.insurance_claims WHERE tenant_id = $1 AND status = $2 ORDER BY updated_at DESC LIMIT 100`
      : `SELECT * FROM public.insurance_claims WHERE tenant_id = $1 ORDER BY updated_at DESC LIMIT 100`,
    status ? [facilityId, status] : [facilityId],
  );

  return result.rows;
}

export async function recordClinicalAudit(
  user: AuthenticatedUser,
  facilityId: string,
  action: string,
  subjectId?: string,
  details: Record<string, unknown> = {},
) {
  await query(
    `INSERT INTO audit.medical_access_logs (
       actor_id, patient_id, resource_type, resource_id, action, tenant_id, details
     ) VALUES ($1, $2, 'clinical', $3, 'read', $4, $5)`,
    [
      user.id,
      subjectId ?? user.id,
      subjectId ?? null,
      facilityId,
      JSON.stringify({ ...details, clinicalAction: action }),
    ],
  );
}
