import { query } from '../lib/db.js';
import { ConflictError, ForbiddenError, NotFoundError } from '../lib/errors.js';
import { buildPaginationMeta, paginationOffset } from '../lib/pagination.js';

interface AppointmentRow {
  id: string;
  reference_number: string;
  facility_id: string;
  provider_id: string;
  patient_id: string;
  family_member_id: string | null;
  scheduled_at: Date;
  duration_minutes: number;
  status: string;
  notes: string | null;
  cancellation_reason: string | null;
  provider_name: string | null;
  facility_name: string | null;
  created_at: Date;
  updated_at: Date;
}

function mapAppointment(row: AppointmentRow) {
  return {
    id: row.id,
    referenceNumber: row.reference_number,
    facilityId: row.facility_id,
    providerId: row.provider_id,
    patientId: row.patient_id,
    familyMemberId: row.family_member_id,
    scheduledAt: row.scheduled_at.toISOString(),
    durationMinutes: row.duration_minutes,
    status: row.status,
    notes: row.notes,
    cancellationReason: row.cancellation_reason,
    providerName: row.provider_name,
    facilityName: row.facility_name,
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
  };
}

const APPOINTMENT_SELECT = `
  a.id, a.reference_number, a.facility_id, a.provider_id, a.patient_id,
  a.family_member_id, a.scheduled_at, a.duration_minutes, a.status,
  a.notes, a.cancellation_reason, a.created_at, a.updated_at,
  p.name AS provider_name, f.name AS facility_name
`;

const APPOINTMENT_FROM = `
  FROM public.appointments a
  JOIN public.providers p ON p.id = a.provider_id
  JOIN public.facilities f ON f.id = a.facility_id
`;

function generateReferenceNumber(): string {
  const date = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const random = Math.random().toString(36).slice(2, 8).toUpperCase();
  return `SH-${date}-${random}`;
}

export async function createAppointment(
  userId: string,
  data: {
    facilityId: string;
    providerId: string;
    serviceId?: string;
    familyMemberId?: string;
    scheduledAt: string;
    durationMinutes: number;
    notes?: string;
  },
) {
  if (data.familyMemberId) {
    const familyCheck = await query(
      'SELECT 1 FROM public.family_members WHERE id = $1 AND account_holder_id = $2',
      [data.familyMemberId, userId],
    );
    if (familyCheck.rowCount === 0) {
      throw new ForbiddenError('Family member does not belong to your account');
    }
  }

  const providerCheck = await query(
    `SELECT p.id
     FROM public.providers p
     LEFT JOIN public.provider_facility_links pfl
       ON pfl.provider_id = p.id AND pfl.facility_id = $2
     WHERE p.id = $1
       AND (p.facility_id = $2 OR pfl.facility_id = $2)
       AND p.is_active = true
       AND p.deleted_at IS NULL
       AND COALESCE(pfl.is_accepting_bookings, p.is_accepting_bookings) = true
       AND COALESCE(pfl.is_active, p.is_active) = true`,
    [data.providerId, data.facilityId],
  );
  if (providerCheck.rowCount === 0) {
    throw new ConflictError('Provider is not available for booking at this facility');
  }

  const referenceNumber = generateReferenceNumber();

  const metadata = data.serviceId ? JSON.stringify({ serviceId: data.serviceId }) : '{}';

  const result = await query<AppointmentRow>(
    `INSERT INTO public.appointments (
       reference_number, facility_id, provider_id, patient_id,
       family_member_id, scheduled_at, duration_minutes, status, notes, booked_by, metadata
     ) VALUES ($1, $2, $3, $4, $5, $6, $7, 'pending', $8, $4, $9::jsonb)
     RETURNING id, reference_number, facility_id, provider_id, patient_id,
               family_member_id, scheduled_at, duration_minutes, status,
               notes, cancellation_reason, created_at, updated_at,
               NULL::text AS provider_name, NULL::text AS facility_name`,
    [
      referenceNumber,
      data.facilityId,
      data.providerId,
      userId,
      data.familyMemberId ?? null,
      data.scheduledAt,
      data.durationMinutes,
      data.notes ?? null,
      metadata,
    ],
  );

  return getAppointmentById(userId, result.rows[0].id);
}

export async function listAppointments(
  userId: string,
  options: {
    page: number;
    limit: number;
    status?: string;
    providerId?: string;
    facilityId?: string;
    from?: string;
    to?: string;
  },
) {
  const conditions = ['a.patient_id = $1'];
  const params: unknown[] = [userId];
  let idx = 2;

  if (options.status) {
    conditions.push(`a.status = $${idx++}::public.appointment_status`);
    params.push(options.status);
  }
  if (options.providerId) {
    conditions.push(`a.provider_id = $${idx++}`);
    params.push(options.providerId);
  }
  if (options.facilityId) {
    conditions.push(`a.facility_id = $${idx++}`);
    params.push(options.facilityId);
  }
  if (options.from) {
    conditions.push(`a.scheduled_at >= $${idx++}`);
    params.push(options.from);
  }
  if (options.to) {
    conditions.push(`a.scheduled_at <= $${idx++}`);
    params.push(options.to);
  }

  const where = conditions.join(' AND ');
  const offset = paginationOffset(options.page, options.limit);

  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count ${APPOINTMENT_FROM} WHERE ${where}`,
    params,
  );
  const total = Number(countResult.rows[0]?.count ?? 0);

  const result = await query<AppointmentRow>(
    `SELECT ${APPOINTMENT_SELECT}
     ${APPOINTMENT_FROM}
     WHERE ${where}
     ORDER BY a.scheduled_at DESC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, options.limit, offset],
  );

  return {
    appointments: result.rows.map(mapAppointment),
    pagination: buildPaginationMeta(options.page, options.limit, total),
  };
}

export async function getAppointmentById(userId: string, appointmentId: string) {
  const result = await query<AppointmentRow>(
    `SELECT ${APPOINTMENT_SELECT}
     ${APPOINTMENT_FROM}
     WHERE a.id = $1 AND a.patient_id = $2`,
    [appointmentId, userId],
  );

  if (!result.rows[0]) throw new NotFoundError('Appointment', appointmentId);
  return mapAppointment(result.rows[0]);
}

export async function updateAppointment(
  userId: string,
  appointmentId: string,
  data: {
    scheduledAt?: string;
    durationMinutes?: number;
    status?: string;
    notes?: string;
    cancellationReason?: string;
  },
) {
  await getAppointmentById(userId, appointmentId);

  const fields: string[] = [];
  const values: unknown[] = [appointmentId, userId];
  let idx = 3;

  const mapping: Record<string, unknown> = {
    scheduled_at: data.scheduledAt,
    duration_minutes: data.durationMinutes,
    status: data.status,
    notes: data.notes,
    cancellation_reason: data.cancellationReason,
  };

  for (const [column, value] of Object.entries(mapping)) {
    if (value !== undefined) {
      fields.push(`${column} = $${idx++}`);
      values.push(value);
    }
  }

  if (fields.length === 0) {
    return getAppointmentById(userId, appointmentId);
  }

  await query(
    `UPDATE public.appointments
     SET ${fields.join(', ')}, updated_at = timezone('utc', now())
     WHERE id = $1 AND patient_id = $2`,
    values,
  );

  return getAppointmentById(userId, appointmentId);
}

export async function cancelAppointment(userId: string, appointmentId: string) {
  return updateAppointment(userId, appointmentId, {
    status: 'cancelled',
    cancellationReason: 'Cancelled by patient',
  });
}
