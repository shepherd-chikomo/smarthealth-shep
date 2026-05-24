import { env } from '../config.js';
import { applyRetentionPolicies } from '../services/retention.service.js';

let intervalHandle: ReturnType<typeof setInterval> | null = null;

const RETENTION_INTERVAL_MS = 24 * 60 * 60 * 1000;

export function startRetentionWorker(): void {
  if (intervalHandle) return;

  const run = async () => {
    try {
      const results = await applyRetentionPolicies();
      const total = results.reduce((sum, r) => sum + r.deletedCount, 0);
      if (total > 0) {
        console.info('[retention] Purged records', results);
      }
    } catch (err) {
      console.error('[retention] Failed to apply retention policies', err);
    }
  };

  if (env.NODE_ENV !== 'test') {
    void run();
    intervalHandle = setInterval(run, RETENTION_INTERVAL_MS);
  }
}

export function stopRetentionWorker(): void {
  if (intervalHandle) {
    clearInterval(intervalHandle);
    intervalHandle = null;
  }
}
