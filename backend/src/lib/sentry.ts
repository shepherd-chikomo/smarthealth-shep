import * as Sentry from '@sentry/node';
import { env } from '../config.js';

let initialized = false;

export function initSentry(): void {
  if (initialized || !env.SENTRY_DSN) return;

  Sentry.init({
    dsn: env.SENTRY_DSN,
    environment: env.NODE_ENV,
    tracesSampleRate: env.NODE_ENV === 'production' ? 0.1 : 1.0,
  });
  initialized = true;
}

export function captureException(error: unknown): void {
  if (!initialized) return;
  Sentry.captureException(error);
}

export { Sentry };
