import type { FastifyReply, FastifyRequest } from 'fastify';
import { getAuthenticatedUser } from '../lib/auth.js';
import { UnauthorizedError } from '../lib/errors.js';
import { getRequestContext } from '../lib/request-context.js';
import { logSecurityEvent } from '../lib/security-events.js';

declare module 'fastify' {
  interface FastifyRequest {
    user?: ReturnType<typeof getAuthenticatedUser>;
  }
}

export async function requireAuth(request: FastifyRequest, reply: FastifyReply) {
  try {
    request.user = getAuthenticatedUser(request);
  } catch (error) {
    if (error instanceof UnauthorizedError) {
      await logSecurityEvent({
        eventType: 'auth_failure',
        action: 'bearer_verify',
        outcome: 'denied',
        context: getRequestContext(request),
        details: { route: request.url },
      });
      return reply.status(401).send({
        error: { code: error.code, message: error.message },
      });
    }
    throw error;
  }
}
