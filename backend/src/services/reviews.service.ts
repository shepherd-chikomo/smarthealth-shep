import { query } from '../lib/db.js';
import { ConflictError, NotFoundError } from '../lib/errors.js';
import { buildPaginationMeta, paginationOffset } from '../lib/pagination.js';

interface ReviewRow {
  id: string;
  provider_id: string;
  patient_id: string;
  rating: number;
  title: string | null;
  comment: string | null;
  is_verified_visit: boolean;
  created_at: Date;
  updated_at: Date;
}

function mapReview(row: ReviewRow) {
  return {
    id: row.id,
    providerId: row.provider_id,
    patientId: row.patient_id,
    rating: row.rating,
    title: row.title,
    comment: row.comment,
    isVerifiedVisit: row.is_verified_visit,
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
  };
}

export async function createReview(
  userId: string,
  data: {
    providerId: string;
    rating: number;
    title?: string;
    comment?: string;
    appointmentId?: string;
  },
) {
  const providerCheck = await query(
    'SELECT 1 FROM public.providers WHERE id = $1 AND is_active = true',
    [data.providerId],
  );
  if (providerCheck.rowCount === 0) {
    throw new NotFoundError('Provider', data.providerId);
  }

  let isVerifiedVisit = false;
  if (data.appointmentId) {
    const appt = await query(
      `SELECT 1 FROM public.appointments
       WHERE id = $1 AND patient_id = $2 AND provider_id = $3 AND status = 'completed'`,
      [data.appointmentId, userId, data.providerId],
    );
    isVerifiedVisit = (appt.rowCount ?? 0) > 0;
  }

  const existing = await query(
    `SELECT 1 FROM public.provider_reviews
     WHERE provider_id = $1 AND patient_id = $2 AND deleted_at IS NULL`,
    [data.providerId, userId],
  );
  if ((existing.rowCount ?? 0) > 0) {
    throw new ConflictError('You have already reviewed this provider');
  }

  const result = await query<ReviewRow>(
    `INSERT INTO public.provider_reviews (
       provider_id, patient_id, appointment_id, rating, title, comment, is_verified_visit
     ) VALUES ($1, $2, $3, $4, $5, $6, $7)
     RETURNING id, provider_id, patient_id, rating, title, comment,
               is_verified_visit, created_at, updated_at`,
    [
      data.providerId,
      userId,
      data.appointmentId ?? null,
      data.rating,
      data.title ?? null,
      data.comment ?? null,
      isVerifiedVisit,
    ],
  );

  return mapReview(result.rows[0]);
}

export async function listProviderReviews(
  providerId: string,
  options: { page: number; limit: number },
) {
  const providerCheck = await query('SELECT 1 FROM public.providers WHERE id = $1', [providerId]);
  if (providerCheck.rowCount === 0) {
    throw new NotFoundError('Provider', providerId);
  }

  const offset = paginationOffset(options.page, options.limit);

  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count
     FROM public.provider_reviews
     WHERE provider_id = $1 AND deleted_at IS NULL`,
    [providerId],
  );
  const total = Number(countResult.rows[0]?.count ?? 0);

  const result = await query<ReviewRow>(
    `SELECT id, provider_id, patient_id, rating, title, comment,
            is_verified_visit, created_at, updated_at
     FROM public.provider_reviews
     WHERE provider_id = $1 AND deleted_at IS NULL
     ORDER BY created_at DESC
     LIMIT $2 OFFSET $3`,
    [providerId, options.limit, offset],
  );

  return {
    reviews: result.rows.map(mapReview),
    pagination: buildPaginationMeta(options.page, options.limit, total),
  };
}
