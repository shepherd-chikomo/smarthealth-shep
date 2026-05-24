import { describe, expect, it, beforeAll, afterAll } from 'vitest';
import type { FastifyInstance } from 'fastify';

const hasEnv =
  process.env.DATABASE_URL &&
  process.env.SUPABASE_JWT_SECRET &&
  process.env.SUPABASE_URL;

describe.skipIf(!hasEnv)('API integration', () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    const { buildApp } = await import('../src/app.js');
    app = await buildApp();
    await app.ready();
  });

  afterAll(async () => {
    await app.close();
    const { pool } = await import('../src/lib/db.js');
    await pool.end();
  });

  it('GET /health returns ok', async () => {
    const response = await app.inject({ method: 'GET', url: '/health' });
    expect(response.statusCode).toBe(200);
    const body = response.json();
    expect(body.status).toBeDefined();
  });

  it('GET /v1/providers returns paginated list', async () => {
    const response = await app.inject({ method: 'GET', url: '/v1/providers?page=1&limit=5' });
    expect(response.statusCode).toBe(200);
    const body = response.json();
    expect(Array.isArray(body.providers)).toBe(true);
    expect(body.pagination.page).toBe(1);
  });

  it('GET /v1/facilities returns paginated list', async () => {
    const response = await app.inject({ method: 'GET', url: '/v1/facilities' });
    expect(response.statusCode).toBe(200);
    expect(response.json().facilities).toBeDefined();
  });

  it('GET /v1/emergency/services returns services', async () => {
    const response = await app.inject({ method: 'GET', url: '/v1/emergency/services' });
    expect(response.statusCode).toBe(200);
    expect(response.json().services).toBeDefined();
  });

  it('GET /docs serves OpenAPI UI', async () => {
    const response = await app.inject({ method: 'GET', url: '/docs' });
    expect(response.statusCode).toBe(200);
  });

  it('protected route returns 401 without token', async () => {
    const response = await app.inject({ method: 'GET', url: '/v1/patients/me' });
    expect(response.statusCode).toBe(401);
  });
});

describe('OpenAPI generation', () => {
  it('generates swagger document', async () => {
    process.env.DATABASE_URL ??= 'postgresql://postgres:postgres@127.0.0.1:54322/postgres';
    process.env.SUPABASE_URL ??= 'http://127.0.0.1:54321';
    process.env.SUPABASE_ANON_KEY ??= 'test-anon-key';
    process.env.SUPABASE_JWT_SECRET ??= 'test-jwt-secret-for-openapi-generation';
    process.env.SUPABASE_SERVICE_ROLE_KEY ??= 'test-service-role-key';

    const { buildApp } = await import('../src/app.js');
    const app = await buildApp();
    await app.ready();

    const spec = app.swagger();
    expect(spec.openapi).toBe('3.0.3');
    expect(spec.paths).toBeDefined();
    expect(spec.paths['/v1/providers']).toBeDefined();
    expect(spec.paths['/v1/auth/otp/send']).toBeDefined();

    await app.close();
  });
});
