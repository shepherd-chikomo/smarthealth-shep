import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['tests/**/*.test.ts'],
    testTimeout: 30_000,
    env: {
      NODE_ENV: 'test',
      DATABASE_URL: 'postgresql://postgres:postgres@127.0.0.1:54322/postgres',
      SUPABASE_URL: 'http://127.0.0.1:54321',
      SUPABASE_ANON_KEY: 'test-anon-key',
      SUPABASE_JWT_SECRET: 'test-jwt-secret-for-unit-tests-only',
      SUPABASE_SERVICE_ROLE_KEY: 'test-service-role-key',
    },
  },
});
