import { config as loadEnv } from 'dotenv';
import { z } from 'zod';

loadEnv();

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(3000),
  API_PREFIX: z.string().default('/v1'),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),
  DATABASE_URL: z.string().min(1),
  SUPABASE_URL: z.string().url(),
  /** Browser-reachable base URL for public storage assets (defaults to SUPABASE_URL). */
  SUPABASE_PUBLIC_URL: z.string().url().optional(),
  SUPABASE_ANON_KEY: z.string().min(1),
  SUPABASE_JWT_SECRET: z.string().min(1),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),
  RATE_LIMIT_MAX: z.coerce.number().default(100),
  RATE_LIMIT_WINDOW_MS: z.coerce.number().default(60_000),
  PAYMENTS_WEBHOOK_SECRET: z.string().default('dev-webhook-secret'),
  NOTIFICATION_DISPATCH_SECRET: z.string().default('dev-notification-dispatch-secret'),
  NOTIFICATION_WORKER_INTERVAL_MS: z.coerce.number().default(30_000),
  ANALYTICS_REFRESH_SECRET: z.string().default('dev-analytics-refresh-secret'),
  ANALYTICS_REFRESH_INTERVAL_MS: z.coerce.number().default(3_600_000),
  FIELD_ENCRYPTION_KEY: z.string().min(32).optional(),
  METRICS_TOKEN: z.string().min(16).optional(),
  REDIS_URL: z.string().optional(),
  SENTRY_DSN: z.preprocess(
    (v) => (v === '' || v === undefined ? undefined : v),
    z.string().url().optional(),
  ),
  RETENTION_WORKER_ENABLED: z
    .enum(['true', 'false'])
    .default('true')
    .transform((v) => v === 'true'),
  AUTH_MAX_FAILURES: z.coerce.number().default(5),
  AUTH_LOCKOUT_MINUTES: z.coerce.number().default(15),
  // Firebase Cloud Messaging (service account)
  FIREBASE_PROJECT_ID: z.string().optional(),
  FIREBASE_CLIENT_EMAIL: z.string().optional(),
  FIREBASE_PRIVATE_KEY: z.string().optional(),
  // SMS fallback (Twilio)
  TWILIO_ACCOUNT_SID: z.string().optional(),
  TWILIO_AUTH_TOKEN: z.string().optional(),
  TWILIO_FROM_NUMBER: z.string().optional(),
  // Email fallback (Resend)
  RESEND_API_KEY: z.string().optional(),
  EMAIL_FROM: z.string().optional(),
  // Google Maps Platform (Geocoding + Places — optional, for geocode pilot/backfill)
  GOOGLE_MAPS_API_KEY: z.string().min(1).optional(),
});

export type Env = z.infer<typeof envSchema>;

function parseEnv(): Env {
  const result = envSchema.safeParse(process.env);
  if (!result.success) {
    const formatted = result.error.issues
      .map((issue) => `${issue.path.join('.')}: ${issue.message}`)
      .join('\n');
    throw new Error(`Invalid environment configuration:\n${formatted}`);
  }

  const data = result.data;
  if (data.NODE_ENV === 'production' && !data.FIELD_ENCRYPTION_KEY) {
    throw new Error(
      'Invalid environment configuration:\nFIELD_ENCRYPTION_KEY: required in production',
    );
  }

  return data;
}

export const env = parseEnv();
