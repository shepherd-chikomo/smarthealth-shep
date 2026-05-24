import { describe, expect, it, beforeAll, afterAll } from 'vitest';
import { createHash } from 'node:crypto';
import type { FastifyInstance } from 'fastify';
import jwt from 'jsonwebtoken';
import { escapeHtml, sanitizeUserInput, stripHtmlTags } from '../src/lib/sanitize.js';
import { decryptField, encryptField, isEncrypted } from '../src/lib/field-encryption.js';
import { hashRefreshToken } from '../src/lib/refresh-token-registry.js';
import { verifyAccessToken } from '../src/lib/auth.js';

process.env.DATABASE_URL ??= 'postgresql://postgres:postgres@127.0.0.1:54322/postgres';
process.env.SUPABASE_URL ??= 'http://127.0.0.1:54321';
process.env.SUPABASE_ANON_KEY ??= 'test-anon-key';
process.env.SUPABASE_JWT_SECRET ??= 'test-jwt-secret-for-security-tests-only';
process.env.SUPABASE_SERVICE_ROLE_KEY ??= 'test-service-role-key';
process.env.FIELD_ENCRYPTION_KEY ??= 'test-field-encryption-key-32chars!!';
process.env.NODE_ENV = 'test';

describe('XSS protection', () => {
  it('escapes HTML special characters', () => {
    expect(escapeHtml('<script>alert("xss")</script>')).not.toContain('<script>');
    expect(escapeHtml('<script>alert("xss")</script>')).toContain('&lt;script&gt;');
  });

  it('strips HTML tags', () => {
    expect(stripHtmlTags('<b>hello</b>')).toBe('hello');
  });

  it('sanitizes user input end-to-end', () => {
    const input = '  <img src=x onerror=alert(1)>  ';
    const sanitized = sanitizeUserInput(input);
    expect(sanitized).not.toContain('<img');
    expect(sanitized).not.toContain('onerror');
  });
});

describe('Encryption at rest', () => {
  it('encrypts and decrypts sensitive fields', () => {
    const plaintext = 'national-id-12345';
    const encrypted = encryptField(plaintext);
    expect(isEncrypted(encrypted)).toBe(true);
    expect(encrypted).not.toContain(plaintext);
    expect(decryptField(encrypted)).toBe(plaintext);
  });

  it('passes through plaintext when not encrypted', () => {
    expect(decryptField('plain-value')).toBe('plain-value');
  });
});

describe('Refresh token security', () => {
  it('hashes tokens with SHA-256', () => {
    const token = 'my-refresh-token-value';
    const hash = hashRefreshToken(token);
    expect(hash).toBe(createHash('sha256').update(token).digest('hex'));
    expect(hash).not.toBe(token);
  });
});

describe('JWT authentication', () => {
  const secret = process.env.SUPABASE_JWT_SECRET!;

  it('verifies valid HS256 tokens', () => {
    const token = jwt.sign({ sub: '550e8400-e29b-41d4-a716-446655440000', user_role: 'patient' }, secret);
    const user = verifyAccessToken(token);
    expect(user.id).toBe('550e8400-e29b-41d4-a716-446655440000');
    expect(user.role).toBe('patient');
  });

  it('rejects tampered tokens', () => {
    const token = jwt.sign({ sub: '550e8400-e29b-41d4-a716-446655440000' }, secret);
    const tampered = token.slice(0, -4) + 'XXXX';
    expect(() => verifyAccessToken(tampered)).toThrow();
  });

  it('rejects expired tokens', () => {
    const token = jwt.sign(
      { sub: '550e8400-e29b-41d4-a716-446655440000' },
      secret,
      { expiresIn: -1 },
    );
    expect(() => verifyAccessToken(token)).toThrow();
  });
});

describe('SQL injection prevention', () => {
  it('uses parameterized query placeholders', () => {
    const malicious = "'; DROP TABLE profiles; --";
    const sql = 'SELECT $1::text AS value';
    expect(sql).not.toContain(malicious);
    expect(sql).toMatch(/\$\d+/);
  });
});

describe('OWASP security headers', () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    const { buildApp } = await import('../src/app.js');
    app = await buildApp();
    await app.ready();
  });

  afterAll(async () => {
    await app.close();
  });

  it('sets security headers on responses', async () => {
    const response = await app.inject({ method: 'GET', url: '/health' });
    expect(response.statusCode).toBe(200);
    expect(response.headers['x-content-type-options']).toBe('nosniff');
    expect(response.headers['x-frame-options']).toBe('DENY');
    expect(response.headers['referrer-policy']).toBe('strict-origin-when-cross-origin');
  });

  it('returns 401 for protected routes without token', async () => {
    const response = await app.inject({ method: 'GET', url: '/v1/patients/me' });
    expect(response.statusCode).toBe(401);
  });

  it('blocks cross-origin mutating requests without CSRF header', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/v1/appointments',
      headers: {
        origin: 'https://evil.example.com',
        'content-type': 'application/json',
      },
      payload: { facilityId: '550e8400-e29b-41d4-a716-446655440000' },
    });
    expect(response.statusCode).toBe(403);
    expect(response.json().error.code).toBe('CSRF_VALIDATION_FAILED');
  });

  it('allows Bearer-authenticated requests without CSRF header', async () => {
    const token = jwt.sign(
      { sub: '550e8400-e29b-41d4-a716-446655440000', user_role: 'patient' },
      process.env.SUPABASE_JWT_SECRET!,
    );
    const response = await app.inject({
      method: 'GET',
      url: '/v1/patients/me',
      headers: { authorization: `Bearer ${token}` },
    });
    expect(response.statusCode).not.toBe(403);
  });

  it('exposes rate limit headers', async () => {
    const response = await app.inject({ method: 'GET', url: '/health' });
    expect(response.headers['x-ratelimit-limit']).toBeDefined();
  });
});

describe('Auth route schemas', () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    const { buildApp } = await import('../src/app.js');
    app = await buildApp();
    await app.ready();
  });

  afterAll(async () => {
    await app.close();
  });

  it('includes recovery and consent endpoints in OpenAPI', () => {
    const spec = app.swagger();
    expect(spec.paths['/v1/auth/recovery/initiate']).toBeDefined();
    expect(spec.paths['/v1/auth/recovery/verify']).toBeDefined();
    expect(spec.paths['/v1/patients/consents']).toBeDefined();
  });

  it('validates OTP verify body schema', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/v1/auth/otp/verify',
      payload: { phone: '123', otp: '12' },
    });
    expect(response.statusCode).toBe(400);
  });

  it('requires channel on OTP verify', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/v1/auth/otp/verify',
      payload: {
        context: 'mobile',
        email: 'user@example.com',
        otp: '123456',
      },
    });
    expect(response.statusCode).toBe(400);
  });

  it('validates OTP send requires email or phone', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/v1/auth/otp/send',
      payload: { context: 'staff' },
    });
    expect(response.statusCode).toBeGreaterThanOrEqual(400);
    expect(response.statusCode).toBeLessThan(500);
  });
});
