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

export function verifyAccessToken(token: string): AuthenticatedUser {
  try {
    const payload = jwt.verify(token, env.SUPABASE_JWT_SECRET, {
      algorithms: ['HS256'],
    }) as JwtPayload;

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
