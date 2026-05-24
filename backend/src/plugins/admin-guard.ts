import type { FastifyReply, FastifyRequest } from 'fastify';
import { getAuthenticatedUser } from '../lib/auth.js';
import { query } from '../lib/db.js';
import { ForbiddenError, UnauthorizedError } from '../lib/errors.js';
import { isAdminRole, isStaffRole, requireAdmin, requireStaff, requireSuperAdmin } from '../lib/rbac.js';

declare module 'fastify' {
  interface FastifyRequest {
    user?: ReturnType<typeof getAuthenticatedUser>;
  }
}

async function attachUser(request: FastifyRequest, reply: FastifyReply): Promise<boolean> {
  try {
    request.user = getAuthenticatedUser(request);
    return true;
  } catch (error) {
    if (error instanceof UnauthorizedError) {
      reply.status(401).send({ error: { code: error.code, message: error.message } });
      return false;
    }
    throw error;
  }
}

/** JWT is minted before post-verify role updates; fall back to profiles.primary_role. */
async function syncRoleFromDatabase(request: FastifyRequest): Promise<void> {
  const user = request.user!;
  if (isStaffRole(user.role)) return;

  const result = await query<{ primary_role: string }>(
    `SELECT primary_role::text FROM public.profiles WHERE id = $1`,
    [user.id],
  );
  const dbRole = result.rows[0]?.primary_role;
  if (dbRole && isStaffRole(dbRole)) {
    request.user = { ...user, role: dbRole };
  }
}

async function syncAdminRoleFromDatabase(request: FastifyRequest): Promise<void> {
  const user = request.user!;
  if (isAdminRole(user.role)) return;

  const result = await query<{ primary_role: string }>(
    `SELECT primary_role::text FROM public.profiles WHERE id = $1`,
    [user.id],
  );
  const dbRole = result.rows[0]?.primary_role;
  if (dbRole && isAdminRole(dbRole)) {
    request.user = { ...user, role: dbRole };
  }
}

export async function requireStaffAuth(request: FastifyRequest, reply: FastifyReply) {
  if (!(await attachUser(request, reply))) return;
  try {
    await syncRoleFromDatabase(request);
    requireStaff(request.user!);
  } catch (error) {
    if (error instanceof ForbiddenError) {
      return reply.status(403).send({ error: { code: error.code, message: error.message } });
    }
    throw error;
  }
}

export async function requireAdminAuth(request: FastifyRequest, reply: FastifyReply) {
  if (!(await attachUser(request, reply))) return;
  try {
    await syncAdminRoleFromDatabase(request);
    requireAdmin(request.user!);
  } catch (error) {
    if (error instanceof ForbiddenError) {
      return reply.status(403).send({ error: { code: error.code, message: error.message } });
    }
    throw error;
  }
}

export async function requireSuperAdminAuth(request: FastifyRequest, reply: FastifyReply) {
  if (!(await attachUser(request, reply))) return;
  try {
    requireSuperAdmin(request.user!);
  } catch (error) {
    if (error instanceof ForbiddenError) {
      return reply.status(403).send({ error: { code: error.code, message: error.message } });
    }
    throw error;
  }
}

export function hasStaffAccess(role: string): boolean {
  return isStaffRole(role);
}
