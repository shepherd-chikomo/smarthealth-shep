import type { FastifyRequest } from 'fastify';

export interface RequestContext {
  ipAddress: string | null;
  userAgent: string | null;
}

export function getRequestContext(request: FastifyRequest): RequestContext {
  const forwarded = request.headers['x-forwarded-for'];
  const ip =
    (typeof forwarded === 'string' ? forwarded.split(',')[0]?.trim() : null) ??
    request.ip ??
    null;

  const userAgent =
    typeof request.headers['user-agent'] === 'string'
      ? request.headers['user-agent']
      : null;

  return { ipAddress: ip, userAgent };
}
