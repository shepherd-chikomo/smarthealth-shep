import { createPublicKey, type JsonWebKey, type KeyObject } from 'node:crypto';
import jwt from 'jsonwebtoken';
import type { FastifyRequest } from 'fastify';
import { env } from '../config.js';
import { UnauthorizedError } from './errors.js';

export interface JwtPayload {
  sub: string;
  email?: string;
  phone?: string;
  role?: string;
  user_role?: string;
  aud?: string;
  exp?: number;
  iat?: number;
}

export interface AuthenticatedUser {
  id: string;
  email?: string;
  phone?: string;
  role: string;
}

/**
 * Supabase Auth (GoTrue) signs access tokens with asymmetric keys (ES256/RS256)
 * by default; the legacy shared HS256 secret is kept as a fallback. Public keys
 * are fetched from the JWKS endpoint and cached, keyed by `kid`.
 */
const jwksCache = new Map<string, KeyObject>();
let lastJwksFetch = 0;

function jwksUrl(): string {
  if (env.SUPABASE_URL.includes('kong')) {
    return 'http://auth:9999/.well-known/jwks.json';
  }
  return `${env.SUPABASE_URL.replace(/\/$/, '')}/auth/v1/.well-known/jwks.json`;
}

export async function refreshJwks(force = false): Promise<void> {
  const now = Date.now();
  if (!force && now - lastJwksFetch < 5_000) return;
  lastJwksFetch = now;
  try {
    const res = await fetch(jwksUrl(), { headers: { apikey: env.SUPABASE_ANON_KEY } });
    if (!res.ok) return;
    const data = (await res.json()) as { keys?: Array<Record<string, unknown> & { kid?: string }> };
    for (const jwk of data.keys ?? []) {
      if (!jwk.kid) continue;
      try {
        jwksCache.set(jwk.kid, createPublicKey({ key: jwk as JsonWebKey, format: 'jwk' }));
      } catch {
        // Skip keys that cannot be parsed.
      }
    }
  } catch {
    // Network/endpoint errors fall back to HS256 verification below.
  }
}

export function verifyAccessToken(token: string): AuthenticatedUser {
  try {
    const decoded = jwt.decode(token, { complete: true });
    const alg = decoded?.header?.alg;
    const kid = typeof decoded?.header?.kid === 'string' ? decoded.header.kid : undefined;

    let payload: JwtPayload;
    if (alg && alg !== 'HS256') {
      const key = kid ? jwksCache.get(kid) : undefined;
      if (!key) {
        // Trigger a background refresh so subsequent requests can verify.
        void refreshJwks();
        throw new UnauthorizedError('Invalid or expired access token');
      }
      payload = jwt.verify(token, key, { algorithms: [alg as jwt.Algorithm] }) as JwtPayload;
    } else {
      payload = jwt.verify(token, env.SUPABASE_JWT_SECRET, {
        algorithms: ['HS256'],
      }) as JwtPayload;
    }

    if (!payload.sub) {
      throw new UnauthorizedError('Invalid token: missing subject');
    }

    return {
      id: payload.sub,
      email: payload.email,
      phone: payload.phone,
      role: payload.user_role ?? payload.role ?? 'patient',
    };
  } catch (error) {
    if (error instanceof UnauthorizedError) throw error;
    throw new UnauthorizedError('Invalid or expired access token');
  }
}

export function extractBearerToken(request: FastifyRequest): string {
  const header = request.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    throw new UnauthorizedError('Missing Bearer token');
  }
  return header.slice(7).trim();
}

export function getAuthenticatedUser(request: FastifyRequest): AuthenticatedUser {
  const token = extractBearerToken(request);
  return verifyAccessToken(token);
}

export function optionalAuthenticatedUser(
  request: FastifyRequest,
): AuthenticatedUser | null {
  const header = request.headers.authorization;
  if (!header?.startsWith('Bearer ')) return null;
  try {
    return verifyAccessToken(header.slice(7).trim());
  } catch {
    return null;
  }
}
