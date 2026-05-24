import { env } from '../config.js';
import { refreshAnalyticsAggregates } from '../services/analytics.service.js';

let timer: ReturnType<typeof setInterval> | null = null;

export function startAnalyticsWorker(): void {
  if (timer) return;

  const tick = async () => {
    try {
      await refreshAnalyticsAggregates();
      console.info('[analytics-worker] aggregates refreshed');
    } catch (error) {
      console.error('[analytics-worker] refresh failed', error);
    }
  };

  // Initial refresh after startup delay
  setTimeout(() => void tick(), 10_000);
  timer = setInterval(tick, env.ANALYTICS_REFRESH_INTERVAL_MS);
  console.info(`[analytics-worker] started (interval ${env.ANALYTICS_REFRESH_INTERVAL_MS}ms)`);
}

export function stopAnalyticsWorker(): void {
  if (timer) {
    clearInterval(timer);
    timer = null;
  }
}
