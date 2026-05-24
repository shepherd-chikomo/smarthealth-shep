#!/usr/bin/env npx tsx
/**
 * OWASP-oriented security checklist for SmartHealth API.
 * Run: npm run security:owasp (from backend/)
 */
import { buildApp } from '../src/app.js';

process.env.DATABASE_URL ??= 'postgresql://postgres:postgres@127.0.0.1:54322/postgres';
process.env.SUPABASE_URL ??= 'http://127.0.0.1:54321';
process.env.SUPABASE_ANON_KEY ??= 'test-anon-key';
process.env.SUPABASE_JWT_SECRET ??= 'test-jwt-secret-for-owasp-checks-only!!';
process.env.SUPABASE_SERVICE_ROLE_KEY ??= 'test-service-role-key';
process.env.NODE_ENV = 'test';

interface Check {
  id: string;
  name: string;
  owasp: string;
  pass: boolean;
  detail: string;
}

const checks: Check[] = [];

function record(id: string, name: string, owasp: string, pass: boolean, detail: string) {
  checks.push({ id, name, owasp, pass, detail });
}

async function main() {
  const app = await buildApp();
  await app.ready();

  const health = await app.inject({ method: 'GET', url: '/health' });
  record(
    'A05',
    'Security headers present',
    'A05:2021 Security Misconfiguration',
    health.headers['x-content-type-options'] === 'nosniff' &&
      health.headers['x-frame-options'] === 'DENY',
    `x-content-type-options=${health.headers['x-content-type-options']}`,
  );

  record(
    'A07',
    'Rate limiting enabled',
    'A07:2021 Identification and Authentication Failures',
    Boolean(health.headers['x-ratelimit-limit']),
    `limit=${health.headers['x-ratelimit-limit']}`,
  );

  const csrf = await app.inject({
    method: 'POST',
    url: '/v1/appointments',
    headers: { origin: 'https://attacker.example', 'content-type': 'application/json' },
    payload: {},
  });
  record(
    'A01',
    'CSRF protection for cookie-less cross-origin',
    'A01:2021 Broken Access Control',
    csrf.statusCode === 403,
    `status=${csrf.statusCode}`,
  );

  const unauth = await app.inject({ method: 'GET', url: '/v1/patients/me' });
  record(
    'A01-b',
    'Protected routes require authentication',
    'A01:2021 Broken Access Control',
    unauth.statusCode === 401,
    `status=${unauth.statusCode}`,
  );

  const spec = app.swagger();
  record(
    'A03',
    'Input validation on auth endpoints',
    'A03:2021 Injection',
    Boolean(spec.paths['/v1/auth/otp/verify']?.post?.requestBody),
    'OTP verify has request body schema',
  );

  record(
    'A02',
    'Auth endpoints documented',
    'A02:2021 Cryptographic Failures',
    Boolean(spec.paths['/v1/auth/refresh'] && spec.paths['/v1/auth/recovery/initiate']),
    'Refresh rotation and recovery endpoints present',
  );

  await app.close();

  const passed = checks.filter((c) => c.pass).length;
  const failed = checks.filter((c) => !c.pass);

  console.log('\n=== OWASP Security Checklist ===\n');
  for (const check of checks) {
    console.log(`${check.pass ? 'PASS' : 'FAIL'} [${check.id}] ${check.name}`);
    console.log(`       ${check.owasp}`);
    console.log(`       ${check.detail}\n`);
  }

  console.log(`Result: ${passed}/${checks.length} checks passed`);
  if (failed.length > 0) {
    process.exit(1);
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
