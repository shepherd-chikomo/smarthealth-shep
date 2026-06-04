import { buildApp } from './app.js';
import { env } from './config.js';
import { refreshJwks } from './lib/auth.js';
import { pool } from './lib/db.js';
import { captureException, initSentry } from './lib/sentry.js';
import { startAnalyticsWorker, stopAnalyticsWorker } from './workers/analytics-worker.js';
import { startNotificationWorker, stopNotificationWorker } from './workers/notification-worker.js';
import { startRetentionWorker, stopRetentionWorker } from './workers/retention-worker.js';

async function main() {
  initSentry();
  const app = await buildApp();
  // Prime Supabase Auth JWKS (asymmetric token verification) and refresh periodically.
  await refreshJwks(true);
  const jwksTimer = setInterval(() => void refreshJwks(true), 10 * 60 * 1000);
  jwksTimer.unref();
  startNotificationWorker();
  startAnalyticsWorker();
  if (env.RETENTION_WORKER_ENABLED) startRetentionWorker();

  const shutdown = async (signal: string) => {
    app.log.info({ signal }, 'Shutting down');
    stopNotificationWorker();
    stopAnalyticsWorker();
    stopRetentionWorker();
    await app.close();
    await pool.end();
    process.exit(0);
  };
  process.on('SIGINT', () => void shutdown('SIGINT'));
  process.on('SIGTERM', () => void shutdown('SIGTERM'));

  try {
    await app.listen({ port: env.PORT, host: '0.0.0.0' });
    app.log.info(`SmartHealth API listening on http://0.0.0.0:${env.PORT}`);
    app.log.info(`OpenAPI docs: http://0.0.0.0:${env.PORT}/docs`);
    app.log.info(`API base: http://0.0.0.0:${env.PORT}${env.API_PREFIX}`);
  } catch (error) {
    captureException(error);
    app.log.error(error);
    process.exit(1);
  }
}

void main();
