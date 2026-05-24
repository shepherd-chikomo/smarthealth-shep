import type { FastifyReply, FastifyRequest } from 'fastify';
import { getAuthenticatedUser } from '../lib/auth.js';
import { ForbiddenError, UnauthorizedError } from '../lib/errors.js';
import { isStaffRole, requireAdmin, requireStaff, requireSuperAdmin } from '../lib/rbac.js';

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

export async function requireStaffAuth(request: FastifyRequest, reply: FastifyReply) {
  if (!(await attachUser(request, reply))) return;
  try {
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
