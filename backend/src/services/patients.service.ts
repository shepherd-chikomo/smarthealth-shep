import { query } from '../lib/db.js';
import { NotFoundError } from '../lib/errors.js';
import { logMedicalAccess } from '../lib/medical-access-log.js';
import type { RequestContext } from '../lib/request-context.js';
import { sanitizeUserInput } from '../lib/sanitize.js';
interface ProfileRow {
  id: string;
  first_name: string | null;
  last_name: string | null;
  display_name: string | null;
  phone: string | null;
  email: string | null;
  date_of_birth: string | null;
  gender: string | null;
  preferred_language: string;
  timezone: string;
  avatar_path: string | null;
  created_at: Date;
  updated_at: Date;
}

interface FamilyRow {
  id: string;
  first_name: string;
  last_name: string | null;
  relationship: string;
  date_of_birth: string | null;
  gender: string | null;
  medical_conditions: string[];
  allergies: string | null;
  is_primary_account_holder: boolean;
  created_at: Date;
  updated_at: Date;
}

function mapProfile(row: ProfileRow) {
  return {
    id: row.id,
    firstName: row.first_name,
    lastName: row.last_name,
    displayName: row.display_name,
    phone: row.phone,
    email: row.email,
    dateOfBirth: row.date_of_birth,
    gender: row.gender,
    preferredLanguage: row.preferred_language,
    timezone: row.timezone,
    avatarPath: row.avatar_path,
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
  };
}

function mapFamily(row: FamilyRow) {
  return {
    id: row.id,
    firstName: row.first_name,
    lastName: row.last_name,
    relationship: row.relationship,
    dateOfBirth: row.date_of_birth,
    gender: row.gender,
    medicalConditions: row.medical_conditions ?? [],
    allergies: row.allergies,
    isPrimaryAccountHolder: row.is_primary_account_holder,
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
  };
}

export async function getPatientProfile(userId: string, context?: RequestContext) {
  const result = await query<ProfileRow>(
    `SELECT id, first_name, last_name, display_name, phone, email,
            date_of_birth, gender, preferred_language, timezone, avatar_path,
            created_at, updated_at
     FROM public.profiles
     WHERE id = $1 AND is_active = true`,
    [userId],
  );

  const row = result.rows[0];
  if (!row) throw new NotFoundError('Patient profile', userId);

  await logMedicalAccess({
    actorId: userId,
    patientId: userId,
    resourceType: 'patient_profile',
    resourceId: userId,
    context,
  });

  return mapProfile(row);
}

export async function updatePatientProfile(
  userId: string,
  data: {
    firstName?: string;
    lastName?: string;
    phone?: string;
    email?: string;
    dateOfBirth?: string;
    gender?: string;
    preferredLanguage?: string;
    timezone?: string;
  },
) {
  const fields: string[] = [];
  const values: unknown[] = [userId];
  let idx = 2;

  const mapping: Record<string, unknown> = {
    first_name: data.firstName,
    last_name: data.lastName,
    phone: data.phone,
    email: data.email,
    date_of_birth: data.dateOfBirth,
    gender: data.gender,
    preferred_language: data.preferredLanguage,
    timezone: data.timezone,
  };

  for (const [column, value] of Object.entries(mapping)) {
    if (value !== undefined) {
      fields.push(`${column} = $${idx++}`);
      values.push(typeof value === 'string' ? sanitizeUserInput(value) : value);
    }
  }

  if (fields.length === 0) {
    return getPatientProfile(userId);
  }

  const result = await query<ProfileRow>(
    `UPDATE public.profiles
     SET ${fields.join(', ')}, updated_at = timezone('utc', now())
     WHERE id = $1
     RETURNING id, first_name, last_name, display_name, phone, email,
               date_of_birth, gender, preferred_language, timezone, avatar_path,
               created_at, updated_at`,
    values,
  );

  return mapProfile(result.rows[0]);
}

export async function listFamilyMembers(userId: string, context?: RequestContext) {
  const result = await query<FamilyRow>(
    `SELECT id, first_name, last_name, relationship, date_of_birth, gender,
            medical_conditions, allergies, is_primary_account_holder,
            created_at, updated_at
     FROM public.family_members
     WHERE account_holder_id = $1
     ORDER BY is_primary_account_holder DESC, created_at ASC`,
    [userId],
  );

  await logMedicalAccess({
    actorId: userId,
    patientId: userId,
    resourceType: 'family_members',
    action: 'read',
    context,
    details: { count: result.rows.length },
  });

  return result.rows.map(mapFamily);
}

export async function createFamilyMember(
  userId: string,
  data: {
    firstName: string;
    lastName?: string;
    relationship: string;
    dateOfBirth?: string;
    gender?: string;
    medicalConditions?: string[];
    allergies?: string;
  },
) {
  const result = await query<FamilyRow>(
    `INSERT INTO public.family_members (
       account_holder_id, first_name, last_name, relationship,
       date_of_birth, gender, medical_conditions, allergies
     ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
     RETURNING id, first_name, last_name, relationship, date_of_birth, gender,
               medical_conditions, allergies, is_primary_account_holder,
               created_at, updated_at`,
    [
      userId,
      data.firstName,
      data.lastName ?? null,
      data.relationship,
      data.dateOfBirth ?? null,
      data.gender ?? null,
      data.medicalConditions ?? [],
      data.allergies ?? null,
    ],
  );

  return mapFamily(result.rows[0]);
}

export async function updateFamilyMember(
  userId: string,
  memberId: string,
  data: Record<string, unknown>,
) {
  await assertFamilyMemberOwnership(userId, memberId);

  const mapping: Record<string, unknown> = {
    first_name: data.firstName,
    last_name: data.lastName,
    relationship: data.relationship,
    date_of_birth: data.dateOfBirth,
    gender: data.gender,
    medical_conditions: data.medicalConditions,
    allergies: data.allergies,
  };

  const fields: string[] = [];
  const values: unknown[] = [memberId, userId];
  let idx = 3;

  for (const [column, value] of Object.entries(mapping)) {
    if (value !== undefined) {
      fields.push(`${column} = $${idx++}`);
      values.push(value);
    }
  }

  if (fields.length === 0) {
    return getFamilyMember(userId, memberId);
  }

  const result = await query<FamilyRow>(
    `UPDATE public.family_members
     SET ${fields.join(', ')}, updated_at = timezone('utc', now())
     WHERE id = $1 AND account_holder_id = $2
     RETURNING id, first_name, last_name, relationship, date_of_birth, gender,
               medical_conditions, allergies, is_primary_account_holder,
               created_at, updated_at`,
    values,
  );

  return mapFamily(result.rows[0]);
}

export async function deleteFamilyMember(userId: string, memberId: string) {
  await assertFamilyMemberOwnership(userId, memberId);

  const result = await query(
    `DELETE FROM public.family_members
     WHERE id = $1 AND account_holder_id = $2 AND is_primary_account_holder = false
     RETURNING id`,
    [memberId, userId],
  );

  if (result.rowCount === 0) {
    throw new NotFoundError('Family member', memberId);
  }
}

async function getFamilyMember(userId: string, memberId: string) {
  const result = await query<FamilyRow>(
    `SELECT id, first_name, last_name, relationship, date_of_birth, gender,
            medical_conditions, allergies, is_primary_account_holder,
            created_at, updated_at
     FROM public.family_members
     WHERE id = $1 AND account_holder_id = $2`,
    [memberId, userId],
  );

  if (!result.rows[0]) throw new NotFoundError('Family member', memberId);
  return mapFamily(result.rows[0]);
}

async function assertFamilyMemberOwnership(userId: string, memberId: string) {
  const result = await query('SELECT 1 FROM public.family_members WHERE id = $1 AND account_holder_id = $2', [
    memberId,
    userId,
  ]);
  if (result.rowCount === 0) throw new NotFoundError('Family member', memberId);
}
