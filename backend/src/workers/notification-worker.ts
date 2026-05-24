import { env } from '../config.js';
import { processPendingNotifications } from '../services/notification-dispatch.service.js';

let timer: ReturnType<typeof setInterval> | null = null;

export function startNotificationWorker(): void {
  if (timer) return;

  const tick = async () => {
    try {
      const count = await processPendingNotifications();
      if (count > 0) {
        console.info(`[notification-worker] processed ${count} notification(s)`);
      }
    } catch (error) {
      console.error('[notification-worker] error', error);
    }
  };

  void tick();
  timer = setInterval(tick, env.NOTIFICATION_WORKER_INTERVAL_MS);
  console.info(`[notification-worker] started (interval ${env.NOTIFICATION_WORKER_INTERVAL_MS}ms)`);
}

export function stopNotificationWorker(): void {
  if (timer) {
    clearInterval(timer);
    timer = null;
  }
}
