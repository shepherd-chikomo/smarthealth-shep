import { query } from '../lib/db.js';
import { NotFoundError } from '../lib/errors.js';
import { buildPaginationMeta, paginationOffset } from '../lib/pagination.js';
import { dispatchNotification } from './notification-dispatch.service.js';

interface NotificationRow {
  id: string;
  title: string;
  body: string;
  channel: string;
  status: string;
  category: string;
  action_url: string | null;
  payload: Record<string, unknown>;
  read_at: Date | null;
  dismissed_at: Date | null;
  created_at: Date;
}

function mapNotification(row: NotificationRow) {
  return {
    id: row.id,
    title: row.title,
    body: row.body,
    channel: row.channel,
    status: row.status,
    category: row.category,
    actionUrl: row.action_url,
    payload: row.payload,
    readAt: row.read_at?.toISOString() ?? null,
    dismissedAt: row.dismissed_at?.toISOString() ?? null,
    createdAt: row.created_at.toISOString(),
  };
}

export async function listNotifications(
  userId: string,
  options: { page: number; limit: number; unreadOnly?: boolean; channel?: string; category?: string },
) {
  const conditions = ['user_id = $1'];
  const params: unknown[] = [userId];
  let idx = 2;

  if (options.unreadOnly) {
    conditions.push('read_at IS NULL');
  }
  if (options.channel) {
    conditions.push(`channel = $${idx++}::public.notification_channel`);
    params.push(options.channel);
  }
  if (options.category) {
    conditions.push(`category = $${idx++}::public.notification_category`);
    params.push(options.category);
  }

  const where = conditions.join(' AND ');
  const offset = paginationOffset(options.page, options.limit);

  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.notifications WHERE ${where}`,
    params,
  );
  const total = Number(countResult.rows[0]?.count ?? 0);

  const result = await query<NotificationRow>(
    `SELECT id, title, body, channel, status, category::text, action_url, payload, read_at, dismissed_at, created_at
     FROM public.notifications
     WHERE ${where}
     ORDER BY created_at DESC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, options.limit, offset],
  );

  return {
    notifications: result.rows.map(mapNotification),
    pagination: buildPaginationMeta(options.page, options.limit, total),
  };
}

export async function markNotificationRead(userId: string, notificationId: string) {
  const result = await query<NotificationRow>(
    `UPDATE public.notifications
     SET read_at = timezone('utc', now()), status = 'read'
     WHERE id = $1 AND user_id = $2
     RETURNING id, title, body, channel, status, category::text, action_url, payload, read_at, dismissed_at, created_at`,
    [notificationId, userId],
  );

  if (!result.rows[0]) throw new NotFoundError('Notification', notificationId);
  return mapNotification(result.rows[0]);
}

export async function markAllNotificationsRead(userId: string) {
  await query(
    `UPDATE public.notifications
     SET read_at = timezone('utc', now()), status = 'read'
     WHERE user_id = $1 AND read_at IS NULL`,
    [userId],
  );
  return { message: 'All notifications marked as read' };
}

export async function registerPushToken(
  userId: string,
  data: { token: string; platform: 'ios' | 'android' | 'web'; deviceId?: string; appVersion?: string },
) {
  await query(
    `INSERT INTO public.push_tokens (user_id, token, platform, device_id, app_version, last_used_at)
     VALUES ($1, $2, $3, $4, $5, timezone('utc', now()))
     ON CONFLICT (user_id, token) DO UPDATE SET
       platform = EXCLUDED.platform,
       device_id = COALESCE(EXCLUDED.device_id, push_tokens.device_id),
       app_version = COALESCE(EXCLUDED.app_version, push_tokens.app_version),
       is_active = true,
       last_used_at = timezone('utc', now()),
       updated_at = timezone('utc', now())`,
    [userId, data.token, data.platform, data.deviceId ?? null, data.appVersion ?? null],
  );
  return { message: 'Token registered' };
}

export async function deactivatePushToken(userId: string, token: string) {
  await query(
    `UPDATE public.push_tokens SET is_active = false, updated_at = timezone('utc', now())
     WHERE user_id = $1 AND token = $2`,
    [userId, token],
  );
  return { message: 'Token deactivated' };
}

export async function listPreferences(userId: string) {
  const result = await query<{
    id: string;
    channel: string;
    category: string;
    is_enabled: boolean;
    quiet_hours_start: string | null;
    quiet_hours_end: string | null;
  }>(
    `SELECT id, tenant_id, channel::text, category, is_enabled,
            quiet_hours_start, quiet_hours_end, metadata
     FROM public.notification_preferences
     WHERE user_id = $1
     ORDER BY category, channel`,
    [userId],
  );
  return { preferences: result.rows };
}

export async function updatePreference(
  userId: string,
  data: {
    channel: string;
    category: string;
    tenantId?: string;
    isEnabled: boolean;
    quietHoursStart?: string | null;
    quietHoursEnd?: string | null;
  },
) {
  const result = await query(
    `INSERT INTO public.notification_preferences (
       user_id, tenant_id, channel, category, is_enabled, quiet_hours_start, quiet_hours_end
     ) VALUES ($1, $2, $3::public.notification_channel, $4, $5, $6, $7)
     ON CONFLICT (user_id, tenant_id, channel, category) DO UPDATE SET
       is_enabled = EXCLUDED.is_enabled,
       quiet_hours_start = EXCLUDED.quiet_hours_start,
       quiet_hours_end = EXCLUDED.quiet_hours_end,
       updated_at = timezone('utc', now())
     RETURNING id, channel::text, category, is_enabled, quiet_hours_start, quiet_hours_end`,
    [
      userId,
      data.tenantId ?? null,
      data.channel,
      data.category,
      data.isEnabled,
      data.quietHoursStart ?? null,
      data.quietHoursEnd ?? null,
    ],
  );
  return { preference: result.rows[0] };
}

export async function createAndDispatch(input: {
  userId: string;
  tenantId?: string;
  category: string;
  title: string;
  body: string;
  actionUrl?: string;
  payload?: Record<string, unknown>;
  scheduledAt?: string;
  priority?: number;
}): Promise<{ id: string }> {
  const result = await query<{ id: string }>(
    `SELECT public.enqueue_notification(
       $1::uuid, $2::uuid, $3::public.notification_category,
       $4, $5, $6, $7::jsonb, $8::timestamptz, null, $9
     ) AS id`,
    [
      input.userId,
      input.tenantId ?? null,
      input.category,
      input.title,
      input.body,
      input.actionUrl ?? null,
      JSON.stringify(input.payload ?? {}),
      input.scheduledAt ?? null,
      input.priority ?? 0,
    ],
  );
  const id = result.rows[0].id;
  if (!input.scheduledAt) {
    await dispatchNotification(id);
  }
  return { id };
}

export async function getUnreadCount(userId: string): Promise<number> {
  const result = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.notifications
     WHERE user_id = $1 AND read_at IS NULL`,
    [userId],
  );
  return Number(result.rows[0]?.count ?? 0);
}

export async function getActiveDashboardBanner(userId: string) {
  const result = await query<NotificationRow>(
    `SELECT id, title, body, channel, status, category::text, action_url, payload, read_at, dismissed_at, created_at
     FROM public.notifications
     WHERE user_id = $1
       AND dismissed_at IS NULL
       AND (payload->>'requiresDashboardDismiss')::boolean IS TRUE
     ORDER BY created_at DESC
     LIMIT 1`,
    [userId],
  );
  const row = result.rows[0];
  if (!row) return { banner: null };
  return { banner: mapNotification(row) };
}

export async function dismissNotification(userId: string, notificationId: string) {
  const result = await query<NotificationRow>(
    `UPDATE public.notifications
     SET dismissed_at = timezone('utc', now()),
         read_at = COALESCE(read_at, timezone('utc', now())),
         status = CASE WHEN status = 'pending' THEN 'read' ELSE status END
     WHERE id = $1 AND user_id = $2
     RETURNING id, title, body, channel, status, category::text, action_url, payload, read_at, dismissed_at, created_at`,
    [notificationId, userId],
  );
  if (!result.rows[0]) throw new NotFoundError('Notification', notificationId);
  return mapNotification(result.rows[0]);
}
