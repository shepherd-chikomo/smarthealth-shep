import type { FastifyReply, FastifyRequest } from 'fastify';
import { z } from 'zod';
import { ForbiddenError, UnauthorizedError } from '../lib/errors.js';
import { getAuthenticatedUser } from '../lib/auth.js';
import { query } from '../lib/db.js';
import { isStaffRole } from '../lib/rbac.js';

declare module 'fastify' {
  interface FastifyRequest {
    facilityId?: string;
  }
}

export const facilityIdQuerySchema = z.object({
  facilityId: z.string().uuid(),
});

export const facilityListQuerySchema = z.object({
  facilityId: z.string().uuid(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: z.string().optional(),
  status: z.string().optional(),
});

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

function extractFacilityId(request: FastifyRequest): string | undefined {
  const header = request.headers['x-facility-id'];
  if (typeof header === 'string' && header) return header;
  const query = request.query as { facilityId?: string };
  return query.facilityId;
}

function isPortalProfileRoute(request: FastifyRequest): boolean {
  return request.url.split('?')[0].endsWith('/facility/me');
}

export async function requireFacilityStaffAuth(request: FastifyRequest, reply: FastifyReply) {
  if (isPortalProfileRoute(request)) {
    return;
  }

  if (!(await attachUser(request, reply))) return;

  try {
    let user = request.user!;
    if (!isStaffRole(user.role)) {
      const result = await query<{ primary_role: string }>(
        `SELECT primary_role::text FROM public.profiles WHERE id = $1`,
        [user.id],
      );
      const dbRole = result.rows[0]?.primary_role;
      if (dbRole && isStaffRole(dbRole)) {
        user = { ...user, role: dbRole };
        request.user = user;
      }
    }
    if (!isStaffRole(user.role)) {
      throw new ForbiddenError('Staff access required');
    }
  } catch (error) {
    if (error instanceof ForbiddenError) {
      return reply.status(403).send({ error: { code: error.code, message: error.message } });
    }
    throw error;
  }

  const facilityId = extractFacilityId(request);
  if (!facilityId) {
    return reply.status(400).send({
      error: { code: 'FACILITY_ID_REQUIRED', message: 'facilityId query param or X-Facility-Id header is required' },
    });
  }

  request.facilityId = facilityId;
}
